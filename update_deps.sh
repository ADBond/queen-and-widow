#!/usr/bin/env bash
set -euo pipefail

FILE="config.json"
ONLY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file) FILE="$2"; shift 2 ;;
    --only) ONLY="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ ! -f "$FILE" ]]; then
  echo "File not found: $FILE" >&2
  exit 1
fi

count=$(jq 'length' "$FILE")
tmp=$(mktemp)
cp "$FILE" "$tmp"

for i in $(seq 0 $((count - 1))); do
  name=$(jq -r ".[$i].name" "$tmp")

  if [[ -n "$ONLY" && "$name" != "$ONLY" ]]; then
    continue
  fi

  url=$(jq -r ".[$i].url" "$tmp")
  branch=$(jq -r ".[$i].branch" "$tmp")
  old_sha=$(jq -r ".[$i].sha" "$tmp")

  new_sha=$(git ls-remote "$url" "refs/heads/$branch" | cut -f1)

  if [[ -z "$new_sha" ]]; then
    echo "WARN: could not resolve $branch on $name" >&2
    continue
  fi

  if [[ "$new_sha" == "$old_sha" ]]; then
    continue
  fi

  jq --arg i "$i" --arg sha "$new_sha" '.[$i|tonumber].sha = $sha' "$tmp" > "${tmp}.next"
  mv "${tmp}.next" "$tmp"

  echo "$name $old_sha $new_sha"
done

mv "$tmp" "$FILE"
