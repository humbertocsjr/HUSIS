echo -= DOS API =- >> ..\MAKE.LOG
..\bin\OSASMPRG DOSAPI >> ..\MAKE.LOG

echo -= EGA Video Controller =- >> ..\MAKE.LOG
..\bin\OSASMPRG EGA >> ..\MAKE.LOG

echo -= Shell =- >> ..\MAKE.LOG
type ..\LIBHUSIS.T > SHELL.T
type SHELL\MAIN.T >> SHELL.T
..\bin\t SHELL >> ..\MAKE.LOG