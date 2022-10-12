all:
	dosbox -C "imgmount 0 -size 512,18,2,80 -fs none -t floppy DISCO.IMG" -C "mount c: ./" -C "cls" -C "c:" -C "make" -exit

img:
	mkfs.minix DISCO.IMG -1 -n30
	dd if=BOOT/BOOT1440.SYS of=DISCO.IMG bs=1024 count=1 conv=notrunc
	sudo mount -t minix DISCO.IMG TMP/
	sudo cp HUSIS.COM TMP/husis
	sudo mkdir TMP/Programs
	sudo mkdir TMP/Documents
	sudo mkdir TMP/Library
	sudo mkdir TMP/System
	sudo cp PROGS/SHELL.COM TMP/Programs/Shell.com
	sudo cp BIN/T.COM TMP/Programs/T.com
	sudo cp BIN/S86.COM TMP/Programs/S86.com
	sudo cp BIN/OSASMCOM.COM TMP/Programs/OSAsmCOM.com
	sudo cp BIN/OSASMSYS.COM TMP/Programs/OSAsmSYS.com
	sudo cp BIN/OSASMPRG.COM TMP/Programs/OSAsmPRG.com
	sudo umount TMP

test: all img
	dosbox -C "BOOT DISCO.IMG -l A"

testdos: all img
	dosbox -C "mount c: ./" -C "imgmount 0 -size 512,18,2,80 -fs none -t floppy DISCO.IMG" -C "C:\HUSIS 000 80 2 18"