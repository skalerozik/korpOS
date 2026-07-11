@echo off

nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin
nasm -f bin program.asm -o program.bin
nasm -f bin programs\memory.asm -o memory.bin
dd if=boot.bin of=OS.img
dd if=kernel.bin of=OS.img bs=512 seek=1
dd if=program.bin of=OS.img bs=512 seek=6
dd if=memory.bin of=OS.img bs=512 seek=7
qemu-system-i386 -hda OS.img