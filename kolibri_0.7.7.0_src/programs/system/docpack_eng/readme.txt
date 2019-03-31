              ************************
              * Kolibri OS  0.7.7.0  *
              *    December 2009     *
              ************************
 
   The latest release of the OS is available on the official site:
            http://kolibrios.org
 
   If you have questions - look for support on our forum:
            http://board.kolibrios.org (rus+eng)
 
             ***********************************
             *  What is new in this release?   *
             ***********************************
   
    The following changes, revisions, fixes in the kernel have been made:
 
  From Evgeny Grechnikov (Diamond) - Russian Federation
    1) Check for buffer overflow for sockets.
    2) Correct handling of ".." item on ramdisk.
    3) Fixes in devices initialization process on boot stage.
    4) Removed unnecessary delays in PS/2 mouse driver.
    5) Determined CPU frequency is now printed in boot log.
    6) Power off for computer tries to use ACPI.
    7) Work with small amount of physical memory corrected.
    8) Use BIOS functions to query memory map, exclude areas marked as
        reserved by BIOS.
    9) Instances of one dynamic library in many processes now share
        unmodified pages.
 
  From Sergey Semyonov (Serge) - Russian Federation
    1) Fixes in sound drivers.
    2) New driver for all ATI videocards from Radeon 256 to Radeon HD 4xxx
        as well as various IGPs, supports hardware cursors and
        dynamic videomode setting.
    3) TLS addressed through fs: selector.
    4) Dynamic allocation of display data, allows arbitrary high resolutions
        and saves memory for small resolutions.
    5) Other fixes.
 
  From Mihail Semenyako (mike.dld) - Republic of Belarus
    1) Fixed macroses for debug output.
 
  From Hidnplayr
    1) Ability for debug output to COM-port (disabled by default).
    2) Fixes in network driver 3c59x.
 
  From Mihailov Ilya (Ghost) - Russian Federation
    1) Fixed work of system function 49 (APM).
 
  From Pavel Rymovski (Heavyiron)
    1) Tracking compilation errors and corresponding fixes.
 
  From Galkov
    1) Refactoring of some areas in the kernel, optimizations, bugfixes.
    2) Support for exception handlers in applications, removed system
       functions 68.15 and 68.18, new system functions 68.24 and 68.25.
 
  From Maxis
    1) Work with mutexes optimized.
    2) Fixed work of system function 68.20 (memory info).
 
  From CleverMouse
    1) The system function 40 returns now old value of the event mask.
    2) Possibility of automatic selection of local port when opening
       UDP and TCP-sockets.
    3) Fixes in TCP implementation.
    4) The driver forcedeth expanded to more network cards from NVidia.
 
  From <Lrz>
    1) Refactoring, optimization, bugfixes of some places in the kernel.
 
  From tsdima
    1) Fixes in TCP implementation.
    2) Fixes in network driver 3c59x.
 
    The following changes, revisions, fixes in applications have been made:
 
   * New versions of applications and new applications:
 
    KFAR     - Evgeny Grechnikov (Diamond), version 0.65: memory requirements
                for built-in editor decreased, sort modes on panels are now
                saved in ini, bugfixes
    FASM     - Pavel Rymovski (Heavyiron), updated to version 1.69.10
    KIV      - Evgeny Grechnikov (Diamond), support for animated images,
                shows multiple images in one file, bugfixes
    LINES    - Evgeny Grechnikov (Diamond), bugfix
    RUN      - Alexey Teplov (<Lrz>), rewritten with using dynamic library
                box_lib
    RDSAVE   - Alexey Teplov (<Lrz>), rewritten with using dynamic library
                box_lib
    ZEROCONF - Hidnplayr, new application, sets network parameters according
                to ini-file
    STACKCFG - Hidnplayr, reads system settings instead of hardcoded values
                in hope that zeroconf has already set some reasonable values
    SHELL    - Aleksandr Bogomaz (Albom), version 0.4.1, command "clear" added,
                bugfixes
    PIC4     - Evgeny Grechnikov (Diamond), memory requirements reduced
    SCRSHOOT - Alexey Teplov (<Lrz>), rewritten with using box_lib
    HEED     - staper, new version 0.11: redesigned; search with Ctrl+F,
                jump to offset with Ctrl+G and scrolling with mouse wheel
    DOWNLOADER - barsuk, program to download http pages from the web
               CleverMouse, proxy support
    HTMLV    - barsuk, load pages from the web with DOWNLOADER
               Kirill Lipatov (Leency), bugfixes, optimizations
    TABLE    - barsuk, bugfixes
               Kirill Lipatov (Leency), bugfixes, unnecessary redraws reduced
    WEB      - Alexander Meshcheryakov (Self-Perfection), new demo
    ZKEY     - Asper, version 0.5: bugfixes, optimization
    KOSILKA  - Gluk, version 1.11: animation fixed
    FIREWORK - Asper, new demo, ported from program by Yaniv LEVIATHAN
               Evgeny Grechnikov (Diamond), optimization by size
    HDD_INFO - staper, HDD informer
    RFORCES  - Kirill Lipatov (Leency), bugfixes, ability to start new game
                by pressing F2
    CLICKS   - Kirill Lipatov (Leency), optimization, button in system style.
    NSLOOKUP - CleverMouse, console replacement of DNSR, based on new network
                library
    SW       - staper, the game "Sea fight"
    AIRC     - CleverMouse, version 0.6: network code rewritten, support for
                encodings cp866 and utf8 added
    RTFREAD  - Sorcerer, the design of application changed
    CPU      - Alexey Teplov (<Lrz>), use the component editbox
    VIEW3DS  - macgub, updated to version 0.054
    SUDOKU   - staper, the game "Sudoku"
    GOMOKU   - staper, the game "Go-moku"
    MTDBG    - Evgeny Grechnikov (Diamond), flickering reduced, bugfixes
    FTPS     - tsdima, some improvements
    VMODE    - Sergey Semyonov (Serge), interface for dynamic videomode
                setting, for now works only with ATI.
 
   * New versions of dynamic libraries and new dynamic libraries:
    load_lib.mac - Alexey Teplov (<Lrz>), macros for dll loading
    box_lib  - Alexey Teplov (<Lrz>), optimization, bugfixes
               Marat Zakiyanov (Mario79), components added: ScrollBar,
                Dynamic Button, MenuBar, FileBrowser
               IgorA, component TreeList added
    libini   - Mihail Semenyako (mike.dld), support for comments in ini-files
                (lines starting with ';'), bugfixes
    libimg   - Evgeny Grechnikov (Diamond), decoder for animated GIFs,
                decoder for icons and cursors (.ico, .cur), support
                for interlaced PNGs, bugfixes
               Nable, decoders for TGA (Targa) and Z80 images
    msgbox   - IgorA, new library for message boxes
    network  - CleverMouse, new library for network
 


/-----------------------------------------------\
* Dates of publication of the distribution kits *
\-----------------------------------------------/

RE N1           30.08.2003
RE N2           07.10.2003
RE N3           26.11.2003
RE N4           23.12.2003
RE N5           15.02.2004
RE N6           27.03.2004
KOLIBRI N1      16.05.2004
RE N7           11.06.2004
KOLIBRI N2      28.08.2004
RE N8           01.12.2004
KOLIBRI N3      22.02.2005  
        Beta 2: 20.03.2005
KOLIBRI N4      07.06.2005
KOLIBRI 0.5.0.0 04.10.2005
        0.5.1.0 12.10.2005
        0.5.2.0 02.12.2005
        0.5.3.0 18.03.2006
        0.5.8.0 09.07.2006
        0.5.8.1 25.07.2006

        0.6.0.0 04.09.2006
        0.6.3.0 31.10.2006
        0.6.5.0 14.02.2007

        0.7.0.0 07.06.2007
        0.7.1.0 23.09.2007
        0.7.5.0 31.01.2009
        0.7.7.0 13.12.2009

/----------------\
* KolibriOS TEAM *
\----------------/

This list contains all, who has actively helped to creation and development
of KolibriOS, whoever possible.
 (people are enumerated in the order by time of participation in the project,
  from bottom to top - from past to future, through present)

* Trans                                \
* VaStaNi                              |
* Ivan Poddubny                        |
* Marat Zakiyanov (Mario79)            |
* Mihail Semenyako (mike.dld)          |  system programming
* Sergey Kuzmin (Wildwest)             |
* Andrey Halyavin (halyavin)           |  loaders,
* Mihail Lisovin (Mihasik)             |  kernel improvements and so on
* Andrey Ignatiev (andrew_programmer)  |
* NoName                               |
* Evgeny Grechnikov (Diamond)          |
* Iliya Mihailov (Ghost)               |
* Sergey Semyonov (Serge)              |
* Johnny_B                             |
* kasTIgar                             |
* SPraid                               |
* Rus                                  |
* Alver                                |
* Maxis                                |
* Galkov                               |
* CleverMouse                          |
* tsdima                               /

* Mihail Lisovin (Mihasik)             \
* Andrey Ivushkin (Willow)             |
* Mihail Semenyako (mike.dld)          |
* Pavlushin Evgeny (Exis)              |
* Ivan Poddubny                        |  application programming
* Marat Zakiyanov (Mario79)            |
* Sergey Kuzmin (Wildwest)             |
* Andrey Halyavin (halyavin)           |  creation of new,
* Hex                                  |  port of existing
* Andrey Ignatiev (andrew_programmer)  |  or revisions of old
* ealex                                |  applications for Kolibri
* Olaf                                 |
* Evgeny Grechnikov (Diamond)          |
* Navanax                              |
* Johnny_B                             |
* Pavel Rymovski (Heavyiron)           |
* Vitaly Bendik (mistifi(ator)         |
* Iliya Mihailov (Ghost)               |
* Maxim Evtihov (Maxxxx32)             |
* Vladimir Zaitsev (Rabid Rabbit)      |
* vectoroc                             |
* Alexey Teplov (<Lrz>)                |
* Sergey Semyonov (Serge)              |
* YELLOW                               |
* iadn                                 |
* Maciej Guba (macgub)                 |
* Mario Birkner (cYfleXX)              |
* hidden player (hidnplayr)            |
* trolly                               |
* nilgui                               |
* kaitz                                |
* DedOk                                |
* SPraid                               |
* Rus                                  |
* Alver                                |
* Dron2004                             |
* Gluk                                 |
* Aleksandr Bogomaz (Albom)            |
* Kirill Lipatov (Leency)              |
* Vasiliy Kosenko (vkos)               |
* IgorA                                |
* staper                               |
* chaykin                              |
* Alexander Meshcheryakov              |
    (Self-Perfection)                  |
* CleverMouse                          |
* tsdima                               /

* Hex                                  \
* Diamond                              /  documentation

* CodeWorld                            \  forum http://meos.sysbin.com
* mike.dld                             /  site http://kolibrios.org; svn-server

* Alexey Teplov (<Lrz>)                \          (KolibriOS logo)
* goglus                               |  design  (KolibriOS background)
* Kirill Lipatov (Leency)              /          (KolibriOS icons)

* Pavel Rymovski (Heavyiron)           \
* Vitaly Bendik (mistifi(ator)         |
* vectoroc                             |
* Veliant                              |  testing,
* AqwAS                                |  countenance
* Mike                                 |
* camper                               |
* Dmitry the Sorcerer                  |
* Ataualpa                             |
* Maxis                                |
* Galkov                               |
* ChE                                  /

and others...

						KolibriOS team
