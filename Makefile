all:
	dosbox -C "imgmount 0 -size 512,18,2,80 -fs none -t floppy 1440.IMG" -C "mount c: ./" -C "cls" -C "c:" -C "make" -exit

img:
	dd if=/dev/zero of=1440.IMG bs=1024 count=1440
	mkfs.minix 1440.IMG -1 -n30
	dd if=BOOT/BOOT1440.SYS of=1440.IMG bs=1024 count=1 conv=notrunc
	sudo mount -t minix 1440.IMG TMP/
	make img_copy
	sudo umount TMP
	dd if=/dev/zero of=360.IMG bs=1024 count=360
	mkfs.minix 360.IMG -1 -n30
	dd if=BOOT/BOOT360.SYS of=360.IMG bs=1024 count=1 conv=notrunc
	sudo mount -t minix 360.IMG TMP/
	make img_copy
	sudo umount TMP

img_copy:
	sudo cp HUSIS.COM TMP/husis
	sudo mkdir TMP/Programs
	sudo mkdir TMP/Documents
	sudo mkdir TMP/Library
	sudo mkdir TMP/System
	sudo cp AUTOEXEC TMP/System/autoexec
	sudo cp PROGS/HELLOPRG.PRG TMP/Programs/Hello1.prg
	sudo cp PROGS/HELLOCOM.COM TMP/Programs/Hello2.com
	sudo cp SYSTEM/SHELL.COM TMP/System/Shell.com
	sudo cp BIN/T.COM TMP/Programs/T.com
	sudo cp BIN/S86.COM TMP/Programs/S86.com
	sudo cp BIN/OSASMCOM.COM TMP/Programs/OSAsmCOM.com
	sudo cp BIN/OSASMSYS.COM TMP/Programs/OSAsmSYS.com
	sudo cp BIN/OSASMPRG.COM TMP/Programs/OSAsmPRG.com

test: all img
	dosbox -C "BOOT 1440.IMG -l A"

debug: all img
	bochs

testdos: all img
	dosbox -C "mount c: ./" -C "imgmount 0 -size 512,18,2,80 -fs none -t floppy 1440.IMG" -C "C:\HUSIS 000 80 2 18 /System/Shell.com"