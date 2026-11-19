# Template test: boot drops from M-mode into S-mode before kernel_main.
#
# QEMU exposes the current privilege level as the virtual register $priv:
#   0 = U-mode, 1 = S-mode, 3 = M-mode
#
# Copy this file as test_<feature>.gdb for each feature you verify in GDB.

break kernel_main
continue

assert_eq $priv 1

test_pass
