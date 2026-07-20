#!/bin/bash
# process_submissions.sh
# Usage: ./process_submissions.sh <submissions_dir>

SRC_DIR="$1"
BACKUP_DIR="./unique_backup"
REPORT_FILE="./report.txt"
ERROR_FILE="./errors.log"

if [ -z "$SRC_DIR" ] || [ ! -d "$SRC_DIR" ]; then
    echo "Error: please provide a valid submissions directory" >> "$ERROR_FILE"
    echo "Usage: $0 <submissions_dir>"
    exit 1
fi

mkdir -p "$BACKUP_DIR" 2>>"$ERROR_FILE"

total=0
duplicates=0
backed_up=0

declare -A seen_hashes

for file in "$SRC_DIR"/*; do
    [ -f "$file" ] || continue
    total=$((total+1))

    hash=$(md5sum "$file" 2>>"$ERROR_FILE" | awk '{print $1}')

    if [ -z "$hash" ]; then
        echo "Error hashing file: $file" >> "$ERROR_FILE"
        continue
    fi

    if [ -n "${seen_hashes[$hash]}" ]; then
        duplicates=$((duplicates+1))
        echo "Duplicate: $file matches ${seen_hashes[$hash]}" >> "$REPORT_FILE.tmp"
    else
        seen_hashes[$hash]="$file"
        cp "$file" "$BACKUP_DIR/" 2>>"$ERROR_FILE"
        if [ $? -eq 0 ]; then
            backed_up=$((backed_up+1))
        else
            echo "Error backing up file: $file" >> "$ERROR_FILE"
        fi
    fi
done

{
    echo "===== Submission Processing Report ====="
    echo "Date: $(date)"
    echo "Total files processed : $total"
    echo "Duplicate files found  : $duplicates"
    echo "Unique files backed up : $backed_up"
    echo "-----------------------------------------"
    [ -f "$REPORT_FILE.tmp" ] && cat "$REPORT_FILE.tmp"
} > "$REPORT_FILE"

rm -f "$REPORT_FILE.tmp"

echo "Done. See $REPORT_FILE and $ERROR_FILE"
