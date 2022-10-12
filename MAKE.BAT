@echo off
echo -= Build HUSIS =- > MAKE.LOG
cd boot
call make.bat
cd ..
cd PROGS
call make.bat
cd ..
echo -= HUSIS Kernel =- >> MAKE.LOG
bin\t husis >> MAKE.LOG
exit