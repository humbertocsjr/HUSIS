echo -= DOS API =- >> ..\MAKE.LOG
..\bin\OSASMPRG DOSAPI >> ..\MAKE.LOG

echo -= EGA Video Controller =- >> ..\MAKE.LOG
..\bin\OSASMPRG EGA >> ..\MAKE.LOG

echo -= Shell =- >> ..\MAKE.LOG
..\bin\prj SHELL.PRJ SHELL.T >> ..\MAKE.LOG
..\bin\t SHELL >> ..\MAKE.LOG

echo -= File Manager =- >> ..\MAKE.LOG
..\bin\prj FILEMAN.PRJ FILEMAN.T >> ..\MAKE.LOG
..\bin\t FILEMAN >> ..\MAKE.LOG

echo -= Application Manager =- >> ..\MAKE.LOG
..\bin\prj APPMAN.PRJ APPMAN.T >> ..\MAKE.LOG
..\bin\t APPMAN >> ..\MAKE.LOG