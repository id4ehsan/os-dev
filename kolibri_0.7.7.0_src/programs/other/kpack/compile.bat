del kpack
del kpack.exe
\masm32\bin\ml /nologo /c /coff kpack.asm
\masm32\bin\link /section:.bss,E /fixed:no /subsystem:native /merge:.data=.text /merge:.rdata=.text /nologo /entry:start /out:kpack.exe /ltcg kpack.obj /nodefaultlib lzmapack.lib memset.obj
fasm doexe2.asm kpack
