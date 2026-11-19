#!/usr/bin/env bash
# tests/gdb/run.sh - run every tests/gdb/test_*.gdb against a fresh QEMU.
#
#   tests/gdb/run.sh                 # all tests
#   tests/gdb/run.sh boot_smode      # only test_boot_smode.gdb
#
# Env: KERNEL, GDB, GDB_PORT, GDB_TEST_TIMEOUT (s), LOG_DIR
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
cd "$here/../.."

KERNEL="${KERNEL:-kernel.elf}"
GDB="${GDB:-riscv64-elf-gdb}"
PORT="${GDB_PORT:-1234}"
TIMEOUT="${GDB_TEST_TIMEOUT:-20}"
LOG_DIR="${LOG_DIR:-${TMPDIR:-/tmp}/kore-gdb-tests}"
mkdir -p "$LOG_DIR"

[[ -f "$KERNEL" ]] || { echo "::error::$KERNEL not found - build first"; exit 1; }

if (( $# )); then
    tests=(); for n in "$@"; do tests+=("$here/test_$n.gdb"); done
else
    tests=("$here"/test_*.gdb)
fi
[[ -e "${tests[0]}" ]] || { echo "::error::no tests found in $here"; exit 1; }

pass=0; failed=()
for t in "${tests[@]}"; do
    name=$(basename "$t" .gdb)

    # Fresh machine per test, halted at reset (-S) until GDB attaches.
    qemu-system-riscv32 -M virt -bios none -kernel "$KERNEL" \
        -display none -monitor none -serial "file:$LOG_DIR/$name.uart.log" \
        -S -gdb "tcp::$PORT" </dev/null >"$LOG_DIR/$name.qemu.log" 2>&1 &
    qpid=$!

    # The trailing quit 2 catches a test that ends without test_pass.
    timeout "$TIMEOUT" "$GDB" -batch -nx -q \
        -ex "set tcp connect-timeout 10" \
        -ex "file $KERNEL" \
        -ex "target remote :$PORT" \
        -x "$here/lib.gdb" \
        -x "$t" \
        -ex 'printf "FAIL: test ended without test_pass\n"' \
        -ex "quit 2" \
        >"$LOG_DIR/$name.gdb.log" 2>&1
    rc=$?

    kill "$qpid" 2>/dev/null; wait "$qpid" 2>/dev/null

    if (( rc == 0 )) && grep -q '^PASS$' "$LOG_DIR/$name.gdb.log"; then
        echo "PASS  $name"; pass=$((pass + 1))
    else
        (( rc == 124 )) && reason="timeout after ${TIMEOUT}s (breakpoint never hit?)" || reason="exit $rc"
        echo "::error::FAIL  $name - $reason"
        echo "----- gdb log -----";  cat "$LOG_DIR/$name.gdb.log"
        echo "----- uart log ----";  cat "$LOG_DIR/$name.uart.log" 2>/dev/null
        failed+=("$name")
    fi
done

echo "== $pass passed, ${#failed[@]} failed (logs: $LOG_DIR)"
(( ${#failed[@]} == 0 ))
