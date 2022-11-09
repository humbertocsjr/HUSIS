! HUSIS - Modular Kernel
! Humberto Costa dos Santos Junior, 2022
! 3-Clause BSD license
! Operating System for IBM PC and compatibles
!
!  This Operating System implements minimum INT 0x21 function set to run 
!  T3X/86 applications and Old-School Assembler without modifications.
!
!  This is a reorganization and simplification of original HUSIS Kernel, to 
!  keep kernel under 40 KiB.

const VERSION = 2022;
const SUB_VERSION = 11;
const REVISION = 0;

const TRUE = %1;
const FALSE = 0;


var Mode;
const MODE_STANDALONE = 1; ! Running as Operating System
const MODE_DOS_APP = 2;  ! Running as DOS App
!
! Running as DOS Application:
! 
! - Use for Debug
! - Use on ROM DOS machines like HP Palmtop 95LX/100LX/200LX
!
! In this mode HUSIS Kernel will preserve all DOS Structures on RAM and use
! DOS delimited RAM space by MCB (DOS Memory Control Block).
