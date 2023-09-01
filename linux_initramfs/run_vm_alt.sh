../../QEMU-Nyx/x86_64-softmmu/qemu-system-x86_64 \
  -kernel /usr/lib64/guestfs/vmlinuz.x86_64 \
  -initrd init_debug_shell.cpio.gz \
  -serial mon:stdio \
  -enable-kvm -k de -m 300 \
  -nographic \
  -append "root=/dev/sda console=ttyS0"
