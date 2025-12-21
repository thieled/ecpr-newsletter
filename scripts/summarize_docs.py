import os
import sys
import subprocess
from pathlib import Path

import tiktoken
from azure.ai.inference import ChatCompletionsClient
from azure.ai.inference.models import SystemMessage, UserMessage
from azure.core.credentials import AzureKeyCredential


MAX_INPUT_TOKENS = 1600
MODEL_NAME = "openai/gpt-5-nano"
ENDPOINT = "https://models.github.ai/inference"


def extract_text(path: Path) -> str:
    suffix = path.suffix.lower()

    if suffix == ".txt":
        return path.read_text(encoding="utf-8", errors="ignore")

    if suffix == ".docx":
        from docx import Document
        doc = Document(path)
        return "\n".join(p.text for p in doc.paragraphs)

    if suffix == ".pdf":
        from pypdf import PdfReader
        reader = PdfReader(path)
        return "\n".join(page.extract_text() or "" for page in reader.pages)

    if suffix == ".doc":
        result = subprocess.run(
            ["antiword", str(path)],
            capture_output=True,
            text=True,
            check=False,
        )
        return result.stdout

    return ""


def truncate_to_tokens(text: str, max_tokens: int) -> str:
    enc = tiktoken.get_encoding("cl100k_base")
    tokens = enc.encode(text)
    return enc.decode(tokens[:max_tokens])


def call_model(prompt: str) -> str:
    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        raise RuntimeError("GITHUB_TOKEN not available")

    client = ChatCompletionsClient(
        endpoint=ENDPOINT,
        credential=AzureKeyCredential(token),
    )

    response = client.complete(
        model=MODEL_NAME,
        messages=[
            SystemMessage(
                "You summarize documents and write short newsletter announcements."
            ),
            UserMessage(prompt),
        ],
    )

    content = response.choices[0].message.content
    if not content or not content.strip():
        raise RuntimeError("Model returned empty output")

    return content


def main(changed_files_list: str) -> None:
    paths = Path(changed_files_list).read_text().splitlines()

    print(f"Processing {len(paths)} document(s)")

    for file_path in paths:
        path = Path(file_path)
        print(f"→ Processing {path}")

        if not path.exists():
            print("  Skipped: file does not exist")
            continue

        raw_text = extract_text(path)
        if not raw_text.strip():
            print("  Warning: extracted text is empty, continuing anyway")

        truncated = truncate_to_tokens(raw_text, MAX_INPUT_TOKENS)

        prompt = f"""
        You are a professional science communicator writing engaging, precise, and enthusiastic
        newsletter announcements for the ECPR Political Communication Standing Group newsletter.
        
        Your task is to transform the input text into a WELL-STRUCTURED MARKDOWN ANNOUNCEMENT.
        
        Follow ALL instructions strictly.
        
        ---
        
        ## OUTPUT REQUIREMENTS (MANDATORY)
        
        1. Always produce TWO sections, in this exact order:
           - A LONG VERSION announcement
           - A SHORT OVERVIEW
        
        2. Use VALID Markdown and the following structural containers EXACTLY as shown.
        
        3. Write in a professional but stimulating tone suitable for an academic audience.
        
        4. If the input refers to:
           - a call for papers
           - a workshop
           - a conference
           - a job opening
           - a fellowship
           - or another academic opportunity
        
           adapt the wording accordingly, BUT KEEP THE SAME STRUCTURE.
        
        5. If some details (e.g. location, deadline, link) are missing or unclear,
           infer cautiously from the text or omit them gracefully (do NOT invent facts).
        
        ---
        
        ## REQUIRED OUTPUT FORMAT
        
        ### Long version
        
        Start with a clear, informative title.
        
        Then write a rich, well-flowing announcement (2–4 paragraphs) that:
        - explains what the opportunity/event is about
        - highlights its academic relevance
        - names key people and institutions when available
        - mentions dates, location, and deadlines when provided
        - ends with a clear call to action
        
        Wrap this section EXACTLY like this:
        
        ## <Descriptive title>
        
        ::: section
        
        <well-written long-form announcement text>
        
        <button class="readmore"><a href="<relevant link if available>">Read more</a></button>
        
        :::
        
        ---
        
        ### Short overview
        
        Then provide a concise, structured overview with the most important facts.
        
        Wrap this section EXACTLY like this:
        
        ## Call – Short
        
        ::: job
        **Title:** <title>
        **Location:** <location or "–">
        **Deadline:** <deadline or "–">
        **Description:** <1–2 sentence concise description>
        <button class="readmore"><a href="<relevant link if available>">Read more</a></button>
        :::
        
        """

        output = call_model(prompt)

        out_path = path.with_name(path.stem + "_summary.md")
        out_path.write_text(output.strip() + "\n", encoding="utf-8")

        print(f"  Wrote summary: {out_path}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: summarize_docs.py <changed_files.txt>")
        sys.exit(1)

    main(sys.argv[1])
