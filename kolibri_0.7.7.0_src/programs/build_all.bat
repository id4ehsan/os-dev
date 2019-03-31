@echo off
cls
goto MAIN


rem
rem %1 - variable name
rem %2-x - allowed values
rem
:input_value
   set __var_name=%1
   set __values=
   set __value=
   set __res=
   shift
   
  :__allowed
   set __values=%1 %__values%
   shift
   if not "%1"=="" goto __allowed
   
   set /P __res=">
  :Check_Value
   for %%a in (%__values%) do if %%a==%__res% set __value=%__res%
   if defined __value goto :__input_value_end

   echo Value '%__res%' is incorrect
   echo Enter valid value from [ %__values% ]:

   set /P __res=">
   goto Check_Value
   :__input_value_end
   set %__var_name%=%__value%
goto :eof




:MAIN
set languages=en ru ge et
set __CPU_type=p5 p6 k6
set BIN=bin

echo Build KolibriOS apps
echo Enter valide language
echo     [%languages%]
call :input_value lang %languages%
echo lang fix %lang% > lang.inc

echo Enter CPU_type ("p5" for interrupt, "p6" for SYSENTER, "k6" for SYSCALL)
call :input_value res %__CPU_type%
echo __CPU_type fix %res% > config.inc

for %%i in (%BIN% %BIN%\demos %BIN%\develop %BIN%\lib %BIN%\games %BIN%\network %BIN%\3d %BIN%\fonts "%BIN%\File Managers" %BIN%\media) do if not exist %%i mkdir %%i

echo *
echo Building system
echo *
fasm system\calendar\calendar.asm %BIN%\calendar
fasm system\board\board.asm %BIN%\develop\board
fasm system\clip\@clip.asm %BIN%\@clip
fasm system\commouse\commouse.asm %BIN%\commouse
fasm system\cpu\cpu.asm %BIN%\cpu 
fasm system\cpuid\cpuid.asm %BIN%\cpuid
fasm system\desktop\desktop.asm %BIN%\desktop
if "%lang%"=="ru" goto docpack_ru
cd system\docpack_eng
goto docpack_done
:docpack_ru
cd system\docpack
:docpack_done
fasm docpack.asm ..\..\%BIN%\docpak
cd ..\..
fasm system\disptest\disptest.asm %BIN%\disptest
fasm system\end\end.asm %BIN%\end
fasm system\gmon\gmon.asm %BIN%\gmon
fasm system\hdd_info\hdd_info.asm %BIN%\hdd_info
fasm system\icon\icon.asm %BIN%\icon
fasm system\kbd\kbd.ASM %BIN%\kbd
fasm system\launcher\launcher.asm %BIN%\launcher
fasm system\menu\menu.asm %BIN%\@menu
fasm system\mgb\mgb.asm %BIN%\mgb
fasm system\MyKey\MyKey.asm %BIN%\mykey
fasm system\PANEL\@PANEL.ASM %BIN%\@PANEL
fasm system\pcidev\pcidev.asm %BIN%\pcidev
fasm system\RB\@RB.ASM %BIN%\@RB
fasm system\ss\@ss.asm %BIN%\@ss
fasm system\rdsave\rdsave.asm %BIN%\rdsave
fasm system\run\run.asm %BIN%\run
fasm system\setup\setup.asm %BIN%\setup
fasm system\spanel\spanel.asm %BIN%\spanel
fasm system\test\test.asm %BIN%\test
fasm system\vrr\vrr.asm %BIN%\vrr
fasm system\vrr_m\vrr_m.asm %BIN%\vrr_m
fasm system\mousemul\mousemul.asm %BIN%\mousemul
fasm system\zkey\zkey.asm %BIN%\zkey

echo *
echo Building develop
echo *
fasm develop\fasm\fasm.asm %BIN%\develop\fasm
fasm develop\h2d2b\h2d2b.asm %BIN%\develop\h2d2b
fasm develop\heed\heed.asm %BIN%\demos\heed
fasm develop\examples\ipc\ipc.asm %BIN%\develop\ipc
fasm develop\keyascii\keyascii.asm %BIN%\develop\keyascii
fasm develop\mtdbg\mtdbg.asm %BIN%\develop\mtdbg
fasm develop\scancode\scancode.asm %BIN%\develop\scancode
fasm develop\tinypad\tinypad.asm %BIN%\tinypad
fasm develop\examples\circle\circle.asm %BIN%\demos\circle
fasm develop\examples\thread\thread.asm %BIN%\develop\thread
fasm develop\cObj\cobj.asm %BIN%\develop\cObj

echo *
echo Building system libraries
echo *
fasm ..\lib\box_lib\box_lib.asm %BIN%\lib\box_lib.obj
fasm ..\lib\cnv_png\cnv_png.asm %BIN%\lib\cnv_png.obj
fasm ..\lib\console\src\console.asm %BIN%\lib\console.obj
fasm ..\lib\libs-dev\libgfx\libgfx.asm %BIN%\lib\libgfx.obj
fasm ..\lib\libs-dev\libimg\libimg.asm %BIN%\lib\libimg.obj
fasm ..\lib\libs-dev\libini\libini.asm %BIN%\lib\libini.obj
fasm ..\lib\libs-dev\libio\libio.asm %BIN%\lib\libio.obj
fasm ..\lib\msgbox\msgbox.asm %BIN%\lib\msgbox.obj
fasm ..\lib\network\network.asm %BIN%\lib\network.obj
fasm ..\lib\box_lib\OpenDial\OpenDial.asm "%BIN%\File Managers\OpenDial"
fasm ..\lib\sorter\sort.asm %BIN%\lib\sort.obj

echo *
echo Building fs
echo *
fasm fs\copyr\copyr.asm %BIN%\copyr
fasm fs\kfar\kfar.asm "%BIN%\File Managers\kfar"
fasm fs\kfar\kfar_arc\kfar_arc.asm "%BIN%\lib\archiver.obj"
fasm fs\kfm\kfm.asm "%BIN%\File Managers\kfm"
fasm fs\sysxtree\sysxtree.asm %BIN%\sysxtree

echo *
echo Building network
echo *
fasm network\airc\airc.asm %BIN%\network\airc
fasm network\arpstat\arpstat.asm %BIN%\network\arpstat
fasm network\chess\chess.asm %BIN%\network\chess
fasm network\downloader\downloader.asm %BIN%\downloader
fasm network\ethstat\ethstat.asm %BIN%\network\ethstat
fasm network\ftps\ftps.asm %BIN%\network\ftps
fasm network\httpc\httpc.asm %BIN%\network\httpc
fasm network\https\https.asm %BIN%\network\https
fasm network\nntpc\nntpc.asm %BIN%\network\nntpc
fasm network\popc\popc.asm %BIN%\network\popc
fasm network\smtps\smtps.asm %BIN%\network\smtps
fasm network\stackcfg\stackcfg.asm %BIN%\network\stackcfg
fasm network\zeroconf\zeroconf.asm %BIN%\network\zeroconf
fasm network\telnet\telnet.asm %BIN%\network\telnet
fasm network\tftpc\tftpc.asm %BIN%\network\tftpc
fasm network\VNCclient\VNCclient.asm %BIN%\network\VNCclient
fasm network\ym\ym.asm %BIN%\network\ym

echo *
echo Building other
echo *
fasm other\calc\calc.asm %BIN%\calc
fasm other\period\period.asm %BIN%\period
fasm other\rtfread\rtfread.asm %BIN%\rtfread

echo *
echo Building media
echo *
fasm media\animage\animage.asm %BIN%\media\animage
fasm media\cdp\cdp.asm %BIN%\media\cdp
cd media\kiv
fasm kiv.asm ..\..\%BIN%\media\kiv
cd ..\..
fasm media\midamp\midamp.asm %BIN%\media\midamp
fasm media\pic4\pic4.asm %BIN%\pic4
fasm media\scrshoot\scrshoot.asm %BIN%\scrshoot
fasm media\startmus\startmus.asm %BIN%\media\startmus
fasm media\listplay\listplay.asm %BIN%\media\listplay

echo *
echo Building games
echo *
fasm games\15\15.asm %BIN%\games\15
fasm games\arcanii\arcanii.asm %BIN%\games\arcanii
cd games\c4\
nasmw -f bin -o ..\..\%BIN%\games\c4 c4.asm
cd ..\..
fasm games\freecell\freecell.asm %BIN%\games\freecell
fasm games\gomoku\gomoku.asm %BIN%\games\gomoku
fasm games\invaders\invaders.asm %BIN%\games\invaders
fasm games\mblocks\mblocks.asm %BIN%\games\mblocks
fasm games\phenix\phenix.asm %BIN%\games\phenix
fasm games\pipes\pipes.asm %BIN%\games\pipes
if "%lang%"=="ru" goto pong_prepare_ru
copy games\pong\english.inc games\pong\lang.inc
goto pong_prepared
:pong_prepare_ru
copy games\pong\russian.inc games\pong\lang.inc
:pong_prepared
fasm games\pong\pong.asm %BIN%\games\pong
fasm games\pong3\pong3.asm %BIN%\games\pong3
fasm games\rsquare\rsquare.asm %BIN%\games\rsquare
fasm games\sq_game\sq_game.asm %BIN%\games\sq_game
fasm games\sudoku\sudoku.asm %BIN%\games\sudoku
fasm games\sw\sw.asm %BIN%\games\sw
fasm games\tetris\tetris.asm %BIN%\games\tetris
fasm games\lines\lines.asm %BIN%\games\lines
fasm games\lights\lights.asm %BIN%\games\lights
fasm games\kox\kox.asm %BIN%\games\kox
fasm games\bnc\bnc.asm %BIN%\games\bnc
fasm games\megamaze\megamaze.asm %BIN%\games\megamaze

echo *
echo Building demos
echo *
fasm demos\3dcube2\3dcube2.asm %BIN%\3d\3dcube2
fasm demos\3ds\3dsheart.asm %BIN%\3d\3dsheart
fasm demos\3dspiral\3dspiral.asm %BIN%\3d\3dspiral
fasm demos\3dtcub10\3dtcub10.asm %BIN%\3d\3dtcub10
cd demos\aclock\
nasmw -t -f bin -o ..\..\%BIN%\demos\aclock aclock.asm
cd ..\..
fasm demos\bcdclk\bcdclk.asm %BIN%\demos\bcdclk
fasm demos\bgitest\bgitest.asm %BIN%\fonts\bgitest
fasm demos\colorref\colorref.asm %BIN%\demos\colorref
fasm demos\crownscr\crownscr.asm %BIN%\3d\crownscr
fasm demos\cslide\cslide.asm %BIN%\demos\cslide
fasm demos\eyes\eyes.asm %BIN%\demos\eyes
fasm demos\fire\fire.asm %BIN%\demos\fire
fasm demos\firework\firework.asm %BIN%\demos\firework
fasm demos\flatwav\flatwav.asm %BIN%\3d\flatwav
fasm demos\free3d04\free3d04.asm %BIN%\3d\free3d04
fasm demos\magnify\magnify.asm %BIN%\magnify
fasm demos\movback\movback.asm %BIN%\demos\movback
fasm demos\plasma\plasma.asm %BIN%\demos\plasma
fasm demos\timer\timer.asm %BIN%\demos\timer
fasm demos\tinyfrac\tinyfrac.asm %BIN%\demos\tinyfrac
fasm demos\trantest\trantest.asm %BIN%\demos\trantest
fasm demos\tube\tube.asm %BIN%\demos\tube
fasm demos\use_msgbox\use_mb.asm %BIN%\demos\use_mb
fasm demos\view3ds\view3ds.asm %BIN%\3d\view3ds
fasm demos\web\web.asm %BIN%\demos\web

erase lang.inc

echo *
echo Finished building 
echo *

echo Kpack KolibriOS apps?
echo.

set /P res=[y/n]?

if "%res%"=="y" (

echo *
echo Compressing system
echo *
kpack /nologo %BIN%\calendar
kpack /nologo %BIN%\@clip
kpack /nologo %BIN%\develop\board
kpack /nologo %BIN%\cpu 
kpack /nologo %BIN%\cpuid
kpack /nologo %BIN%\desktop
kpack /nologo %BIN%\disptest
kpack /nologo %BIN%\docpak
kpack /nologo %BIN%\end
kpack /nologo %BIN%\gmon
kpack /nologo %BIN%\hdd_info
kpack /nologo %BIN%\icon
kpack /nologo %BIN%\kbd
kpack /nologo %BIN%\launcher
kpack /nologo %BIN%\@menu
kpack /nologo %BIN%\mgb
kpack /nologo %BIN%\mykey
kpack /nologo %BIN%\@PANEL
kpack /nologo %BIN%\pcidev
kpack /nologo %BIN%\@RB
kpack /nologo %BIN%\@ss
kpack /nologo %BIN%\rdsave
kpack /nologo %BIN%\run
kpack /nologo %BIN%\setup
kpack /nologo %BIN%\spanel
kpack /nologo %BIN%\test
kpack /nologo %BIN%\vrr
kpack /nologo %BIN%\vrr_m
kpack /nologo %BIN%\mousemul
kpack /nologo %BIN%\zkey

echo *
echo Compressing develop
echo *

kpack /nologo %BIN%\develop\fasm
kpack /nologo %BIN%\develop\h2d2b
kpack /nologo %BIN%\demos\heed
kpack /nologo %BIN%\develop\ipc
kpack /nologo %BIN%\develop\keyascii
kpack /nologo %BIN%\develop\mtdbg
kpack /nologo %BIN%\develop\scancode
kpack /nologo %BIN%\tinypad
kpack /nologo %BIN%\demos\circle
kpack /nologo %BIN%\develop\thread
kpack /nologo %BIN%\develop\cObj

echo *
echo Compressing libraries
echo *

kpack /nologo %BIN%\lib\box_lib.obj
kpack /nologo %BIN%\lib\cnv_png.obj
kpack /nologo %BIN%\lib\console.obj
kpack /nologo %BIN%\lib\libgfx.obj
kpack /nologo %BIN%\lib\libimg.obj
kpack /nologo %BIN%\lib\libini.obj
kpack /nologo %BIN%\lib\libio.obj
kpack /nologo %BIN%\lib\msgbox.obj
kpack /nologo %BIN%\lib\network.obj
kpack /nologo "%BIN%\File Managers\OpenDial"
kpack /nologo %BIN%\lib\sort.obj

echo *
echo Compressing fs
echo *

kpack /nologo %BIN%\copyr
kpack /nologo "%BIN%\File Managers\kfar"
kpack /nologo "%BIN%\lib\archiver.obj"
kpack /nologo "%BIN%\File Managers\kfm"
kpack /nologo %BIN%\sysxtree

echo *
echo Compressing network
echo *

kpack /nologo %BIN%\network\airc
kpack /nologo %BIN%\network\arpstat
kpack /nologo %BIN%\network\chess
kpack /nologo %BIN%\downloader
kpack /nologo %BIN%\network\ethstat
kpack /nologo %BIN%\network\ftps
kpack /nologo %BIN%\network\httpc
kpack /nologo %BIN%\network\https
kpack /nologo %BIN%\network\nntpc
kpack /nologo %BIN%\network\popc
kpack /nologo %BIN%\network\smtps
kpack /nologo %BIN%\network\stackcfg
kpack /nologo %BIN%\network\zeroconf
kpack /nologo %BIN%\network\telnet
kpack /nologo %BIN%\network\tftpc
kpack /nologo %BIN%\network\VNCclient
kpack /nologo %BIN%\network\ym

echo *
echo Compressing other
echo *

kpack /nologo %BIN%\calc
kpack /nologo %BIN%\period
kpack /nologo %BIN%\rtfread

echo *
echo Compressing media
echo *

kpack /nologo %BIN%\media\animage
kpack /nologo %BIN%\media\cdp
kpack /nologo %BIN%\media\kiv
kpack /nologo %BIN%\media\midamp
kpack /nologo %BIN%\pic4
kpack /nologo %BIN%\scrshoot
kpack /nologo %BIN%\media\startmus
kpack /nologo %BIN%\media\listplay

echo *
echo Compressing games
echo *

kpack /nologo %BIN%\games\15
kpack /nologo %BIN%\games\arcanii
kpack /nologo %BIN%\games\c4
kpack /nologo %BIN%\games\freecell
kpack /nologo %BIN%\games\gomoku
kpack /nologo %BIN%\games\invaders
kpack /nologo %BIN%\games\mblocks
kpack /nologo %BIN%\games\phenix
kpack /nologo %BIN%\games\pipes
kpack /nologo %BIN%\games\pong
kpack /nologo %BIN%\games\pong3
kpack /nologo %BIN%\games\rsquare
kpack /nologo %BIN%\games\sq_game
kpack /nologo %BIN%\games\sudoku
kpack /nologo %BIN%\games\sw
kpack /nologo %BIN%\games\tetris
kpack /nologo %BIN%\games\lines
kpack /nologo %BIN%\games\lights
kpack /nologo %BIN%\games\kox
kpack /nologo %BIN%\games\bnc
kpack /nologo %BIN%\games\megamaze

echo *
echo Compressing demos
echo *

kpack /nologo %BIN%\3d\3dcube2
kpack /nologo %BIN%\3d\3dsheart
kpack /nologo %BIN%\3d\3dspiral
kpack /nologo %BIN%\3d\3dtcub10
kpack /nologo %BIN%\demos\aclock
kpack /nologo %BIN%\demos\bcdclk
kpack /nologo %BIN%\fonts\bgitest
kpack /nologo %BIN%\demos\colorref
kpack /nologo %BIN%\3d\crownscr
kpack /nologo %BIN%\demos\cslide
kpack /nologo %BIN%\demos\eyes
kpack /nologo %BIN%\demos\fire
kpack /nologo %BIN%\demos\firework
kpack /nologo %BIN%\3d\flatwav
kpack /nologo %BIN%\3d\free3d04
kpack /nologo %BIN%\magnify
kpack /nologo %BIN%\demos\movback
kpack /nologo %BIN%\demos\plasma
kpack /nologo %BIN%\demos\timer
kpack /nologo %BIN%\demos\tinyfrac
kpack /nologo %BIN%\demos\trantest
kpack /nologo %BIN%\demos\tube
kpack /nologo %BIN%\demos\use_mb
kpack /nologo %BIN%\3d\view3ds
kpack /nologo %BIN%\demos\web

echo *
echo Compressing complete
echo *
)

:END
echo *
echo Done. Thanks for your choice ;)
echo *
pause
