#!/bin/bash
SUBMIT_DIR="$1"
BACKUP_DIR="./backup_unique"
REPORT_FILE="./report.txt"
ERROR_FILE="./errors.txt"
HASH_LOG="./hashes.txt"

> "$REPORT_FILE"
> "$ERROR_FILE"
> "$HASH_LOG"
mkdir -p "$BACKUP_DIR" 2>>"$ERROR_FILE"

if [ -z "$SUBMIT_DIR" ] || [ ! -d "$SUBMIT_DIR" ]; then
    echo "Error: Please provide a valid submissions directory." >>"$ERROR_FILE"
    exit 1
fi

total=0
duplicates=0
backed_up=0

for file in "$SUBMIT_DIR"/*; do
    if [ -f "$file" ]; then
        total=$((total+1))
        hash=$(md5sum "$file" 2>>"$ERROR_FILE" | awk '{print $1}')

        if [ -z "$hash" ]; then
            echo "Error: Could not hash $file" >>"$ERROR_FILE"
            continue
        fi

        if grep -q "^$hash " "$HASH_LOG" 2>>"$ERROR_FILE"; then
            duplicates=$((duplicates+1))
        else
            echo "$hash $file" >> "$HASH_LOG"
            cp "$file" "$BACKUP_DIR/" 2>>"$ERROR_FILE" && backed_up=$((backed_up+1))
        fi
    fi
done

{
    echo "Submission Processing Report"
    echo "-----------------------------"
    echo "Total files processed : $total"
    echo "Duplicate files found  : $duplicates"
    echo "Unique files backed up : $backed_up"
} > "$REPORT_FILE"

cat "$REPORT_FILE"
