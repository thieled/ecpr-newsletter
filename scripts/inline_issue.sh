#!/usr/bin/env bash
set -euo pipefail

YEAR="$1"
ISSUE="$2"

ISSUE_DIR="issues/${YEAR}/${ISSUE}"
QMD="${ISSUE_DIR}/newsletter_${YEAR}_${ISSUE}.qmd"
HTML="${ISSUE_DIR}/newsletter_${YEAR}_${ISSUE}.html"

if [[ ! -f "$QMD" ]]; then
  echo "QMD file not found: $QMD"
  exit 1
fi

echo "Rendering with Quarto..."
quarto render "$QMD" --to html --quiet

if [[ ! -f "$HTML" ]]; then
  echo "Rendered HTML not found: $HTML"
  exit 1
fi

echo "Inlining CSS..."
npx --yes juice "$HTML" "$HTML"

echo "Rendered and inlined: $HTML"
