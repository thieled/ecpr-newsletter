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

    return response.choices[0].message.content


def main(changed_files_list: str) -> None:
    paths = Path(changed_files_list).read_text().splitlines()

    for file_path in paths:
        path = Path(file_path)
        if not path.exists():
            continue

        raw_text = extract_text(path)
        if not raw_text.strip():
            continue

        truncated = tru
