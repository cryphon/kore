# ci/lib.sh - shared helpers for the CI check scripts. Source, don't run.

CC="${CC:-riscv64-elf-gcc}"
MEM_LAYOUT="${MEM_LAYOUT:-core/mem_layout.h}"

# macro NAME -> prints the integer value of a #define from mem_layout.h,
# expanded by the real preprocessor so the check can never drift from the
# header. Integer suffixes (0x1000UL) are stripped so bash can evaluate it.
macro() {
    local expr
    expr=$(printf '%s\n' "$1" |
        "$CC" -E -P -x c -include "$MEM_LAYOUT" - | tail -n 1 |
        sed -E 's/([0-9a-fA-FxX])[uUlL]+/\1/g')
    if [[ -z "$expr" || "$expr" == "$1" ]]; then
        echo "::error::$1 is not defined in $MEM_LAYOUT" >&2
        return 1
    fi
    echo $(( expr ))
}
