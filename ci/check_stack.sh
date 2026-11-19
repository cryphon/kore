#!/usr/bin/env bash
# ci/check_stack.sh - per-function stack budget, from the .su files that
# -fstack-usage already produces.
#
# Fails when a function:
#   - uses more than (stack size / STACK_DIVISOR) bytes for its own frame, or
#   - has an unbounded ("dynamic") frame, e.g. a VLA or alloca.
#
# Kernel code (core/) is measured against KERNEL_STACK_SIZE, user code (bin/)
# against USER_STACK_SIZE. Note this is per *frame*, not per call chain:
# a deep chain of small frames can still overflow.
set -euo pipefail
cd "$(dirname "$0")/.."
source ci/lib.sh

DIVISOR="${STACK_DIVISOR:-8}"
kstack=$(macro KERNEL_STACK_SIZE)
ustack=$(macro USER_STACK_SIZE)
fail=0

check_tree() {
    local label=$1 limit=$2 dir=$3
    mapfile -t files < <(find "$dir" -name '*.su' | sort)
    if (( ${#files[@]} == 0 )); then
        echo "::error::no .su files under $dir/ (is -fstack-usage still in CFLAGS?)"
        fail=1; return
    fi

    echo "== $label: frame limit ${limit} B (stack $(( limit * DIVISOR )) B / $DIVISOR)"
    # .su line format: file:line:col:function<TAB>bytes<TAB>static|dynamic[,bounded]
    while IFS=$'\t' read -r loc bytes kind; do
        if [[ "$kind" == dynamic ]]; then          # "dynamic,bounded" is fine
            echo "::error::$loc has an unbounded stack frame ($kind)"; fail=1
        elif (( bytes > limit )); then
            echo "::error::$loc uses $bytes B of stack (limit $limit B)"; fail=1
        fi
    done < <(cat "${files[@]}")

    echo "   largest frames:"
    cat "${files[@]}" | sort -t$'\t' -k2,2nr | head -n 5 |
        awk -F'\t' '{ printf "   %6d B  %-10s %s\n", $2, $3, $1 }'
}

check_tree "kernel" $(( kstack / DIVISOR )) core
check_tree "user"   $(( ustack / DIVISOR )) bin

exit $fail
