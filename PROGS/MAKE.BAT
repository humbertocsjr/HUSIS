echo -= Project Compiler =- >> ..\MAKE.LOG
..\bin\t PRJ >> ..\MAKE.LOG
copy PRJ.COM ..\BIN\PRJ.COM >> NUL
echo -= Hello World S86 PRG =- >> ..\MAKE.LOG
..\bin\s86 HELLO1.S86 HELLO1.PRG /REDIRERR >> ..\MAKE.LOG
echo -= Hello World S86 COM =- >> ..\MAKE.LOG
..\bin\s86 HELLO2.S86 HELLO2.COM /REDIRERR >> ..\MAKE.LOG
echo -= Hello World T3X COM =- >> ..\MAKE.LOG
..\bin\prj HELLO3.PRJ HELLO3.T >> ..\MAKE.LOG
..\bin\t HELLO3 >> ..\MAKE.LOG