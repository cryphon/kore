#!/usr/bin/env bash
# ci/check_slots.sh - every user program image must fit in its fixed slot.
# A .bin larger than USER_SLOT_SIZE silently overlaps the next slot.
set -euo pipefail
cd "$(dirname "$0")/.."
source ci/lib.sh

slot=$(macro USER_SLOT_SIZE)
fail=0

mapfile -t bins < <(find bin -mindepth 2 -maxdepth 2 -name '*.bin' | sort)
if (( ${#bins[@]} == 0 )); then
    echo "::error::no bin/*/*.bin images found - was the build run?"
    exit 1
fi

echo "== slot size: $slot B"
for b in "${bins[@]}"; do
    size=$(stat -c %s "$b")
    printf '   %-28s %6d B  (%3d%%)\n' "$b" "$size" $(( size * 100 / slot ))
    if (( size > slot )); then
        echo "::error::$b is $size B, overflows its $slot B slot by $(( size - slot )) B"
        fail=1
    fi
done

exit $fail
