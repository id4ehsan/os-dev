\masm32\bin\ml /nologo /c /coff kpack.asm
\masm32\bin\link /nologo @link.opt kpack.obj lzmapack.lib \masm32\lib\kernel32.lib
