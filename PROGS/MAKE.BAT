echo -= Hello World S86 PRG =- >> ..\MAKE.LOG
..\bin\s86 HELLO1.S86 HELLO1.PRG /REDIRERR >> ..\MAKE.LOG
echo -= Hello World S86 COM =- >> ..\MAKE.LOG
..\bin\s86 HELLO2.S86 HELLO2.COM /REDIRERR >> ..\MAKE.LOG
echo -= Hello World T3X COM =- >> ..\MAKE.LOG
type ..\LIBHUSIS.T > HELLO3.T
type HELLO3\MAIN.T >> HELLO3.T
..\bin\t HELLO3 >> ..\MAKE.LOG