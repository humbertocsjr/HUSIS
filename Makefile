all:
	@echo -= Building HUSIS =-
	@dosbox -C "imgmount 0 -size 512,18,2,80 -fs none -t floppy 1440.IMG" -C "mount c: ./" -C "cls" -C "c:" -C "make" -exit  > /dev/null
	@! grep -E 'Error|error|erro' MAKE.LOG
	@echo -= Build Complete =-

img:
	@echo -= Creating Disk Images =-
	@rm *.IMG
	@echo -= 1440 KiB Floppy Disk =-
	@dd if=/dev/zero of=IMG.IMG bs=1024 count=1440 status=none
	@minixfs mkfs IMG.IMG -1 -n 30 -s 1440
	@dd if=BOOT/BOOT1440.SYS of=IMG.IMG bs=1024 count=1 conv=notrunc status=none
	@make img_copy
	@mv IMG.IMG 1440.IMG
	@echo -= 360 KiB Floppy Disk =-
	@dd if=/dev/zero of=IMG.IMG bs=1024 count=360 status=none
	@minixfs mkfs IMG.IMG -1 -n 30 -s 360
	@dd if=BOOT/BOOT360.SYS of=IMG.IMG bs=1024 count=1 conv=notrunc status=none
	@make img_copy
	@mv IMG.IMG 360.IMG

img_copy:
	@minixfs add IMG.IMG HUSIS.COM /husis
	@minixfs mkdir IMG.IMG /Programs
	@minixfs mkdir IMG.IMG /Documents
	@minixfs mkdir IMG.IMG /Library
	@minixfs mkdir IMG.IMG /Config
	@minixfs mkdir IMG.IMG /System
	@minixfs add IMG.IMG AUTOEXEC.HSH /System/Autoexec.hsh
	@minixfs add IMG.IMG PROGS/HELLO1.PRG /Programs/Hello1.prg
	@minixfs add IMG.IMG PROGS/HELLO2.COM /Programs/Hello2.com
	@minixfs add IMG.IMG PROGS/HELLO3.COM /Programs/Hello3.com
	@minixfs add IMG.IMG SYSTEM/SHELL.COM /System/Shell.com
	@minixfs add IMG.IMG SYSTEM/DOSAPI.PRG /System/DOSAPI.prg
	@minixfs add IMG.IMG SYSTEM/EGA.PRG /System/EGA.prg
	@minixfs add IMG.IMG SYSTEM/SPLASH.TXT /System/Splash.txt
	@minixfs add IMG.IMG SYSTEM/BOLD.FON /System/Bold.fon
	@minixfs add IMG.IMG SYSTEM/BOLD.FON /System/Default.fon
	@minixfs add IMG.IMG SYSTEM/DRAW.FON /System/Draw.fon
	@minixfs add IMG.IMG SYSTEM/FILEMAN.FON /System/FileMan.fon
	@minixfs add IMG.IMG SYSTEM/FILEMAN.COM /System/FileMan.com
	@minixfs add IMG.IMG SYSTEM/APPMAN.COM /System/AppMan.com
	@minixfs add IMG.IMG BIN/T.COM /Programs/T.com
	@minixfs add IMG.IMG BIN/S86.COM /Programs/S86.com
	@minixfs add IMG.IMG BIN/PRJ.COM /Programs/PRJ.com
	@minixfs add IMG.IMG BIN/OSASMCOM.COM /Programs/OSAsmCOM.com
	@minixfs add IMG.IMG BIN/OSASMSYS.COM /Programs/OSAsmSYS.com
	@minixfs add IMG.IMG BIN/OSASMPRG.COM /Programs/OSAsmPRG.com

test: all img
	@echo -= Start emulation [DOSBox] =-
	@dosbox -C "BOOT 1440.IMG -l A" > /dev/null

debug: all img
	@echo -= Start emulation [Bochs] =-
	@bochs

testdos: all img
	@echo -= Start emulation [DOSBox] =-
	@dosbox -C "mount c: ./" -C "imgmount 0 -size 512,18,2,80 -fs none -t floppy 1440.IMG" -C "C:\HUSIS 000 80 2 18 /System/Autoexec.hsh"  > /dev/null