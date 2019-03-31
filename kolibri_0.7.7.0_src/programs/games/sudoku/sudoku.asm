;based on http://sources.codenet.ru/download/1599/Sudoku.html

use32
	org	0x0
	db	'MENUET01'
	dd	0x1
	dd	START
	dd	I_END
	dd	(I_END+9*9*4+10000) and not 3
	dd	(I_END+9*9*4+10000) and not 3
	dd	0x0,0x0

Difficult db 0	;сложность [0..9]
Difficult_array db 80,75,68,59,50,45,40,36,32,25

DEBUG equ 0

include 'macros.inc'
include 'lang.inc'


;include 'debug.inc'

macro dbg_dec num
{pushad
newline
debug_print_dec num
popad
}

START:

	mcall	40,7;100111b
	mcall	3
	mov	[rsx1],ax
	ror	eax,16
	mov	[rsx2],ax
	rol	eax,7
	mov	[rsx3],ax
	rol	eax,7
	mov	[rsx4],ax

	jmp	key.new_game

redraw_all:
	mcall	12,1
	mcall	0,100*65536+192,100*65536+260,0x34FFFFFF,,title
	mcall	38,1*65536+181,21*65536+21,0x780000
	mov	edx,0x00b0b0b0
	mov	edi,3
	mov	esi,3
  @@:	add	ecx,20*65536+20
	mcall
	dec	esi
	jnz	@b
	mov	esi,3
	push	edx
	mcall	,,,0x780000
	pop	edx
	dec	edi
	jnz	@b
	mcall	,1*65536+1,22*65536+200,0xe7e6a0
	mov	edx,0x00b0b0b0
	mov	edi,3
	mov	esi,3
	push	edx
	mcall	,,,0x780000
	pop	edx

  @@:	add	ebx,20*65536+20
	mcall
	dec	esi
	jnz	@b
	mov	esi,3
	push	edx
	mcall	,,,0x780000
	pop	edx
	dec	edi
	jnz	@b

	mcall	4,<5,5>,0x80000000,txt_new
	mcall	,<70,5>,,txt_dif
	mcall	,<5,218>,,txt_space
	mcall	,<5,206>,,txt_check

	movzx	ecx,[Difficult]
	mcall	47,0x10000,,<170,5>,0x50000000,0xffffff

	push	dword Map;esi;  mov     esi,Map
	mcall	12,2
draw_pole:
;	mcall	12,1
;	mcall	0,100*65536+192,100*65536+260,0x74FFFFFF,,title
	if DEBUG
	call	SysMsgBoardNum	;show esp
	endf

	movzx	eax,[Y]
	dec	al
	mov	ebx,9
	mul	bl
	mov	bl,[X]
	add	al,bl
	pop	esi	;       mov     esi,Map
	push	eax	;курсорчик
	mov	edi,81-9
	mov	ebp,9
	mov	ebx,1*65536+21
	mov	ecx,21*65536+41
	call	out_numbers
	pop	eax
;	mcall	12,2


still:
	mcall	10

	dec	al
	jz	redraw_all
	dec	al
	jz	key
	dec	al
	jnz	still
;button:
	mcall	17
	cmp	ah,1
	jne	still;@f
	mcall	-1

key:
	mcall	2
cmp ah,32		;пробел
jne	@f
	push	dword SolveMap
	btc	[flags],3
	jc	.todraw
	jmp	draw_pole
	.todraw:
	push	dword Map
	jmp	draw_pole
@@:
	btr	[flags],3
	cmp	ah,43		;+
	jne	.45
	cmp	[Difficult],9
	je	still
	inc	[Difficult]
	movzx	ecx,[Difficult]
	mcall	47,0x10000,,<170,5>,0x50000000,0xffffff
	jmp	still
.45:				;-
	cmp	ah,45
	jne	.99
	cmp	[Difficult],0
	je	still
	dec	[Difficult]
	movzx	ecx,[Difficult]
	mcall	47,0x10000,,<170,5>,0x50000000,0xffffff
	jmp	still

.99:				;Check
	cmp	ah,99
	jne	.39
	xor	ecx,ecx
	mov	edx,txt_check_no
 @@:	mov	al,byte [Map+ecx]
	cmp	byte [SolveMap+ecx],al
	jne	@f
	inc	ecx
	cmp	ecx,9*9
	jb	@b
	mov	edx,txt_check_yes
 @@:	mcall	4,<90,206>,0xd00000ff,,,0xffffff
	jmp	.todraw

.39:	cmp	ah,0x39
	ja	.110
	cmp	ah,0x30
	jb	still
	sub	ah,0x30
	mov	cl,ah

	movzx	eax,[Y]
	dec	al
	mov	ebx,9
	mul	bl
	mov	bl,[X]
	dec	bl
	add	al,bl
	mov	esi,Map
	cmp	byte [esi+eax],9
	jg	still
	mov	[esi+eax],cl
	jmp	.onedraw

.110:	cmp	ah,110
	jne	.176
.new_game:
	call	GeneratePlayBoard
	jmp	redraw_all

.176:	cmp	ah,176 ;курсоры
	jne	.177
	call	draw_one_symbol
	dec	[X]
	cmp	[X],1
	jge	@f
	mov	[X],9
@@:	jmp	.onedraw
.177:	cmp	ah,177
	jne	.178
	call	draw_one_symbol
	inc	[Y]
	cmp	[Y],9
	jbe	@f
	mov	[Y],1
@@:	jmp	.onedraw
.178:	cmp	ah,178
	jne	.179
	call	draw_one_symbol
	dec	[Y]
	cmp	[Y],1
	jge	@f
	mov	[Y],9
@@:	jmp	.onedraw
.179:	cmp	ah,179
	jne	still
	call	draw_one_symbol
	inc	[X]
	cmp	[X],9
	jbe	@f
	mov	[X],1
@@:
.onedraw:
	bts	[flags],4
	call	draw_one_symbol
	jmp	still ;.todraw

draw_one_symbol:
	movzx	eax,[X]
	mov	ebx,20*65536+20
	mul	ebx
	xchg	eax,ebx
	add	ebx,(1*65536+21-20*65536+20)
	movzx	eax,[Y]
	mov	ecx,20*65536+20
	mul	ecx
	xchg	eax,ecx
	add	ecx,(21*65536+41-20*65536+20)
	movzx	eax,[Y]
	dec	al
	push	ebx
	mov	ebx,9
	mul	bl
	mov	bl,[X]
	add	al,bl
	dec	al
	pop	ebx
	mov	esi,Map
	add	esi,eax
	push	dword 0	;не курсор
	bt	[flags],4
	jnc	@f
	mov	dword [esp],1 ;курсор
	btr	[flags],4
@@:	mov	edi,0
	mov	ebp,1
	call	out_numbers
	pop	eax
ret


out_numbers:
	push	ebx ecx esi
	shr	ebx,16
	inc	bx
	shl	ebx,16
	add	ebx,19
	shr	ecx,16
	inc	cx
	shl	ecx,16
	add	ecx,19
	mov	edx,0xffffff
	push	ebp
	dec	dword [esp+4*5]
	jnz	@f
	mov	edx,0xdddddd
@@:	pop	ebp
	mcall	13
	pop	esi

	cmp	byte [esi],0
	je	.null
	cmp	byte [esi],9
	jbe	.changable_number
	cmp	byte [esi],19
	jbe	.fixed_number
	jmp	.null
.end:
	inc	esi
	dec	ebp
	jnz	out_numbers
	test	edi,edi
	jz	@f
	sub	edi,9
	mov	ebp,9
	add	ebx,-180*65536-180
	add	ecx,20*65536+20
	jmp	out_numbers
  @@:
ret

.fixed_number:
	push	esi
	shr	ecx,16
	mov	bx,cx
	add	ebx,7*65536+6
	movzx	edx,byte [esi]
	add	edx,str_nmb-11
	mcall	4,,0x0,,1
.1:	pop	esi ecx ebx
	add	ebx,20*65536+20
	jmp	.end

.null:
	pop	ecx ebx
	add	ebx,20*65536+20
	jmp	.end
.changable_number:
	push	esi
	shr	ecx,16
	mov	bx,cx
	add	ebx,7*65536+6
	movzx	edx,byte [esi]
	add	edx,str_nmb-1
	mcall	4,,0x8d8d,,1
	jmp	.1













GeneratePlayBoard:
;i db 0
;j db 0
;RandI db 0
;RandJ db 0
;iRet db 0
;//генерируем решенную матрицу
;m:
;for i:=0 to 8 do
;  for j:=0 to 8 do
;    begin
;    Map[i,j]:=0;
;    SolveMap[i,j]:=0;
;    RealMap[i,j]:=0;
;    end;
	mov	edi,Map
	mov	esi,SolveMap
	mov	edx,RealMap
	xor	ecx,ecx
	@@:
	mov	byte [edi+ecx],0
	mov	byte [esi+ecx],0
	mov	byte [edx+ecx],0
	inc	ecx
	cmp	ecx,9*9
	jb	@b

;//ставим рандомно несколько чисел на поле
;for i:=1 to 21 do
;  begin
;  RandI:=random(9);
;  RandJ:=random(9);
;  if SolveMap[RandI,RandJ]=0 then
;     begin
;     SolveMap[RandI,RandJ]:=random(9)+1;
;     if not CheckSudoku(SolveMap) then
;       begin
;       SolveMap[RandI,RandJ]:=0;
;       Continue;
;       end;
;     end else Continue;
;  end;

	mov	ecx,21
.1:	mov	eax,9
	call	random
	mov	ebx,eax
	mov	eax,9
	call	random
	mov	ah,9
	mul	ah
	add	eax,ebx ;RandI,RandJ
	cmp	byte [esi+eax],0
	jne	.loop
		mov	ebx,eax
		mov	eax,9
		call	random
		mov	byte [esi+ebx],al
		call	CheckSudoku
		jnc	.loop
		mov	byte [esi+ebx],0
	.loop:
	loop	.1


;//решаем Судоку
;iRet:=Solve(SolveMap);
;if iRet<>1 then goto m;
;i:=1;

	mov	esi,SolveMap
	call	Solve
	cmp	[_iRet],1
	jne	GeneratePlayBoard

	movzx	ecx,[Difficult]
	movzx	ecx,byte [Difficult_array+ecx]

;case Difficult of
;1:
;   while i<=42 do
;   begin
;        RandI:=random(9);
;        RandJ:=random(9);
;        if RealMap[RandI,RandJ]<>0 then Continue else
;        RealMap[RandI,RandJ]:=SolveMap[RandI,RandJ];
;        inc(i);
;   end;
;2:
;   while i<=32 do
;   begin
;        RandI:=random(9);
;        RandJ:=random(9);
;        if RealMap[RandI,RandJ]<>0 then Continue else
;        RealMap[RandI,RandJ]:=SolveMap[RandI,RandJ];
;        inc(i);
;   end;
;3:
;   while i<=25 do
;   begin
;        RandI:=random(9);
;        RandJ:=random(9);
;        if RealMap[RandI,RandJ]<>0 then Continue else
;        RealMap[RandI,RandJ]:=SolveMap[RandI,RandJ];
;        inc(i);
;   end;
;end;

.2:
	mov	eax,9
	call	random
	mov	ebx,eax
	mov	eax,9
	call	random
	mov	ah,9
	mul	ah
	cmp	al,81
	jb	@f
	dec	al
	@@:
	add	eax,ebx ;RandI,RandJ
	cmp	byte [RealMap+eax],0
	jne	.loop2
		add	byte [SolveMap+eax],10
		mov	bl,[SolveMap+eax]
		mov	byte [RealMap+eax],bl
	.loop2:
	loop	.2

;for i:=0 to 8 do
;   for j:=0 to 8 do
;      Map[i,j]:=RealMap[i,j];
;end;

	xor	ecx,ecx
@@:	mov	al,[RealMap+ecx]
	mov	[Map+ecx],al
	inc	ecx
	cmp	ecx,9*9
	jb	@b
ret



include 'SudokuSolve.pas'





align 4
rsx1 dw ?;0x4321
rsx2 dw ?;0x1234
rsx3 dw ?;0x62e9
rsx4 dw ?;0x3619
random: 	; из ASCL
	push ecx ebx esi edx
	mov cx,ax
	mov ax,[rsx1]
	mov bx,[rsx2]
	mov si,ax
	mov di,bx
	mov dl,ah
	mov ah,al
	mov al,bh
	mov bh,bl
	xor bl,bl
	rcr dl,1
	rcr ax,1
	rcr bx,1
	add bx,di
	adc ax,si
	add bx,[rsx3]
	adc ax,[rsx4]
	sub [rsx3],di
	adc [rsx4],si
	mov [rsx1],bx
	mov [rsx2],ax
	xor dx,dx
	cmp ax,0
	je nodiv
	cmp cx,0
	je nodiv
	div cx
nodiv:
	mov ax,dx
	pop edx esi ebx ecx
	and eax,0000ffffh
ret



if DEBUG
SysMsgBoardNum: ;warning: destroys eax,ebx,ecx,esi
	mov	ebx,esp
	mov	ecx,8
	mov	esi,(number_to_out+1)
.1:
	mov	eax,ebx
	and	eax,0xF
	add	al,'0'
	cmp	al,(10+'0')
	jb	@f
	add	al,('A'-'0'-10)
@@:
	mov	[esi+ecx],al
	shr	ebx,4
	loop	.1
	dec	esi
	mcall	71,1,number_to_out
ret

number_to_out	db '0x00000000',13,10,0
endf


if lang eq ru
title db 'Судоку',0
txt_dif db "Сложность (+/-):",0
txt_new db 'Новая (N)',0
txt_space db 'Решение (Пробел)',0
txt_check db 'Проверить (C)',0
txt_check_yes db 'Да!  ',0
txt_check_no db 'Не-а!',0
else
title db 'Sudoku',0
txt_dif db "Difficult (+/-)",0
txt_new db 'New (N)',0
txt_space db 'Solution (Space)',0
txt_check db 'Check (C)',0
txt_check_yes db 'Yes!',0
txt_check_no db 'No! ',0
endf

str_nmb db '123456789',0

X db 1
Y db 1

I_END:
align 16
Map	rb 9*9
SolveMap rb 9*9
RealMap rb 9*9
TempMap rb 9*9

flags rw 1
;бит 0: см. перед draw_pole
;3: