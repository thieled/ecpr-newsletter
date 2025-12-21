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

        prompt = (
            "Please do the following:\n\n"
            "1. Provide a concise summary of the document.\n"
            "2. Write a short newsletter-style announcement (3–5 sentences).\n\n"
            "Document text:\n\n"
            f"{truncated}"
        )

        output = call_model(prompt)

        out_path = path.with_name(path.stem + "_summary.md")
        out_path.write_text(output.strip() + "\n", encoding="utf-8")

        print(f"  Wrote summary: {out_path}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: summarize_docs.py <changed_files.txt>")
        sys.exit(1)

    main(sys.argv[1])
