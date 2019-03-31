
format MS COFF

public Start
public _PATH
public _PARAM

extrn _kol_main

section ".aheader" data
	db "MENUET01"
	dd 1, Start, -1, -1, hStack, _PARAM, _PATH

section ".text" code
Start:

; инициализация кучи
mov	eax, 68
mov	ebx, 11
int	0x40

; вызов главной процедуры
call	_kol_main

; завершение работы программы
mov	eax, -1
int	0x40

section ".bss"

_PARAM:
rb	256

_PATH:
rb	256

rb	8*1024
hStack:
