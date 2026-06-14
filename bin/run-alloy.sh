#!/usr/bin/env bash
set -euo pipefail

ALLOY_JAR="/Applications/Alloy.app/Contents/Resources/org.alloytools.alloy.dist.jar"

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <file.als> [file.als ...]" >&2
  exit 1
fi

for file in "$@"; do
  echo "Checking: $file"
  java -jar "$ALLOY_JAR" exec "$file"
done
