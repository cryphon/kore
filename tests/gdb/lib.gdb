# tests/gdb/lib.gdb - helpers loaded before every test_*.gdb.
#
# A test passes only by reaching `test_pass`. Anything else fails it:
# a failed assert, a kernel_panic, a GDB error, the timeout
# (breakpoint never hit), or the script just ending.

set pagination off
set confirm off
set print pretty on

# Any kernel panic fails the test immediately.
break kernel_panic
commands
  silent
  printf "FAIL: kernel_panic hit\n"
  bt
  quit 1
end

# assert_eq <expr> <expected>
#   GDB splits arguments on spaces, so write expressions without them.
#   e.g.  assert_eq $priv 1
#         assert_eq tasks[1]->pid 1
define assert_eq
  if ($arg0) != ($arg1)
    printf "FAIL: $arg0 = 0x%x, expected 0x%x\n", (unsigned int)($arg0), (unsigned int)($arg1)
    quit 1
  end
  printf "  ok: $arg0 == 0x%x\n", (unsigned int)($arg1)
end

# assert_ne <expr> <value>
define assert_ne
  if ($arg0) == ($arg1)
    printf "FAIL: $arg0 == 0x%x, expected it to differ\n", (unsigned int)($arg1)
    quit 1
  end
  printf "  ok: $arg0 != 0x%x\n", (unsigned int)($arg1)
end

define test_pass
  printf "PASS\n"
  quit 0
end
