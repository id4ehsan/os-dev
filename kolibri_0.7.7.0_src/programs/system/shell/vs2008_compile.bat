cl /c /nologo /Ox /Os /GL /Gr /GS- /GR- shell.c
link /nologo /ltcg /section:.bss,E /entry:Start /subsystem:native /base:0 /fixed:no /nodefaultlib /merge:.rdata=.text /merge:.data=.text /merge:.aheader=.text shell.obj start.obj kolibri.obj stdlib.obj string.obj
fasm doexe2.asm shell