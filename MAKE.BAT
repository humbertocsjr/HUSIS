@echo off
echo -= Build HUSIS =- > MAKE.LOG
cd boot
call make.bat
cd ..
cd PROGS
call make.bat
cd ..
cd SYSTEM
call make.bat
cd ..
echo -= HUSIS Kernel =- >> MAKE.LOG
bin\prj husis.prj husis.t
bin\t husis >> MAKE.LOG
exit