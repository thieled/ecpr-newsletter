#!/usr/bin/env bash
set -euo pipefail

YEAR="$1"
ISSUE="$2"

ISSUE_DIR="issues/${YEAR}/${ISSUE}"
QMD_FILE="${ISSUE_DIR}/newsletter_${YEAR}_${ISSUE}.qmd"
HTML_FILE="${ISSUE_DIR}/newsletter_${YEAR}_${ISSUE}.html"

if [ ! -f "$QMD_FILE" ]; then
  echo "ERROR: QMD file not found: $QMD_FILE" >&2
  exit 1
fi

echo "Rendering newsletter ${YEAR}/${ISSUE}"

# --- force overwrite ---
if [ -f "$HTML_FILE" ]; then
  echo "Removing existing HTML: $HTML_FILE"
  rm -f "$HTML_FILE"
fi

# --- render ---
quarto render "$QMD_FILE" --to html --quiet

if [ ! -f "$HTML_FILE" ]; then
  echo "ERROR: Rendered HTML not found after render" >&2
  exit 1
fi

# --- inline CSS (Node / juice) ---
npx juice "$HTML_FILE" "$HTML_FILE"

echo "Rendered and inlined: $HTML_FILE"
