nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin
nasm -f bin program.asm -o program.bin
nasm -f bin ./programs/memory.asm -o memory.bin
dd if=/dev/zero of=OS.img bs=512 count=256
dd if=boot.bin of=OS.img conv=notrunc
dd if=kernel.bin of=OS.img bs=512 seek=1 conv=notrunc
dd if=program.bin of=OS.img bs=512 seek=6 conv=notrunc
dd if=memory.bin of=OS.img bs=512 seek=7 conv=notrunc
qemu-system-i386 -hda OS.img
