#!/bin/sh
# Bumps pubspec.yaml's semantic version (the part before "+") to the next
# minor release — run this ONCE, right before building the AAB for a new
# Play Store submission. Turns e.g. 1.0.0+128 into 1.1.0+128.
#
# The build number after "+" is left untouched here — .githooks/pre-commit
# keeps auto-incrementing that on every commit as before, including the
# commit where you check in this version bump.
set -e
FILE="pubspec.yaml"
CURRENT=$(grep '^version:' "$FILE" | sed 's/version: //')
BASE="${CURRENT%+*}"
BUILD="${CURRENT#*+}"
MAJOR=$(echo "$BASE" | cut -d. -f1)
MINOR=$(echo "$BASE" | cut -d. -f2)
NEXT_MINOR=$((MINOR + 1))
NEW_BASE="${MAJOR}.${NEXT_MINOR}.0"
sed "s/^version: .*/version: ${NEW_BASE}+${BUILD}/" "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
echo "Version bumped: ${CURRENT} -> ${NEW_BASE}+${BUILD}"
