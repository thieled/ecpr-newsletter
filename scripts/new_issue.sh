#!/usr/bin/env bash
set -euo pipefail

YEAR="$1"
ISSUE="$2"
OVERWRITE="$3"

ISSUE_DIR="issues/${YEAR}/${ISSUE}"
TEMPLATE="template/newsletter_template.qmd"
PUBLICATIONS_SRC="template/publications"
PUBLICATIONS_DST="${ISSUE_DIR}/publications"
TARGET="${ISSUE_DIR}/newsletter_${YEAR}_${ISSUE}.qmd"

# --- validation -------------------------------------------------------------

if [[ -z "$YEAR" || -z "$ISSUE" ]]; then
  echo "ERROR: year and issue must be provided" >&2
  exit 1
fi

if [[ ! -f "$TEMPLATE" ]]; then
  echo "ERROR: Template not found at ${TEMPLATE}" >&2
  exit 1
fi

if [[ ! -d "$PUBLICATIONS_SRC" ]]; then
  echo "ERROR: publications directory not found at ${PUBLICATIONS_SRC}" >&2
  exit 1
fi

# --- overwrite handling ------------------------------------------------------

if [[ -d "$ISSUE_DIR" && "$OVERWRITE" != "true" ]]; then
  echo "ERROR: Issue directory already exists: ${ISSUE_DIR}" >&2
  echo "Set overwrite=true to recreate it." >&2
  exit 1
fi

if [[ "$OVERWRITE" == "true" && -d "$ISSUE_DIR" ]]; then
  rm -rf "$ISSUE_DIR"
fi

# --- directory structure -----------------------------------------------------

mkdir -p \
  "${ISSUE_DIR}/img" \
  "${ISSUE_DIR}/doc" \
  "${ISSUE_DIR}/summarize"

touch "${ISSUE_DIR}/img/.gitkeep"
touch "${ISSUE_DIR}/doc/.gitkeep"
touch "${ISSUE_DIR}/summarize/.gitkeep"

# --- copy publications ------------------------------------------------------

mkdir -p "${PUBLICATIONS_DST}"

cp "${PUBLICATIONS_SRC}/"* "${PUBLICATIONS_DST}/"

# --- copy + modify template -------------------------------------------------

sed \
  -e "s/^year:.*/year: ${YEAR}/" \
  -e "s/^issue:.*/issue: \"${ISSUE}\"/" \
  "$TEMPLATE" > "$TARGET"

echo "Created issue: ${TARGET}"
