#!/usr/bin/env bash

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

INPUT_DIR="$ROOT_DIR/tests/in"
EXPECTED_DIR="$ROOT_DIR/tests/expected"
OUTPUT_DIR="$ROOT_DIR/tests/out"

PROGRAM="$ROOT_DIR/build/tarefa3"

PREFIX="${1:-}"

if [[ -z "$PREFIX" ]]; then
    echo "Usage: $0 <test-prefix>"
    echo "Example: $0 teste"
    exit 1
fi

if [[ ! -x "$PROGRAM" ]]; then
    echo "Error: executable not found: $PROGRAM"
    echo "Run 'make' first."
    exit 1
fi

if [[ ! -d "$INPUT_DIR" || ! -d "$EXPECTED_DIR" ]]; then
    echo "Error: test directories not found."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

passed=0
failed=0
total=0

shopt -s nullglob

for input in "$INPUT_DIR"/"$PREFIX"*.txt; do
    filename="$(basename "$input" .txt)"

    expected="$EXPECTED_DIR/${filename}_saida.txt"
    output="$OUTPUT_DIR/${filename}.text"

    if [[ ! -f "$expected" ]]; then
        echo "[SKIP] $filename: expected output not found."
        continue
    fi

    total=$((total + 1))

    echo "----------------------------------------"
    echo "Testing: $filename"

    "$PROGRAM" < <(printf '%s\n%s\n' "$input" "$output")

    if diff -u "$expected" "$output"; then
        echo "[PASS] $filename"
        passed=$((passed + 1))
    else
        echo "[FAIL] $filename"
        failed=$((failed + 1))
    fi
done

echo
echo "[*] Test Summary"
echo "Total:  $total"
echo "Passed: $passed"
echo "Failed: $failed"

if (( total == 0 )); then
    echo "No tests found for prefix '$PREFIX'."
    exit 1
fi

if (( failed > 0 )); then
    exit 1
fi

exit 0
