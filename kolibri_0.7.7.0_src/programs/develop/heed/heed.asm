; v.012 26.10.2009

; PageUp, PageDown      - страница вверх/вниз
; Ctrl+UP, Ctrl+Down    - прокрутка страницы на строку вверх/вниз без смещения курсора
; Home,End              - в начало/конец строки
; Ctrl+Home, Ctrl+End   - к первому/последнему байту файла
; Left, Right           - курсор влево/вправо
; Ctrl+O                - открыть файл
; Ctrl+S                - сохранить
; Ctrl+F                - поиск (+Tab для OptionBox)
; Ctrl+G                - переход на смещение (+Tab для OptionBox)
; n                     - инвертировать байт под курсором
; Ins                   - режим замены/вставки (по умолчанию)
;   Del                 - в режиме вставки - удалить байт под курсором
;   BackSpace           - в режиме вставки - удалить байт перед курсором
; ~                     - смена кодировки (cp866,cp1251)
; Shift+~               - смена кодировки (cp866 или cp1251,koi8-r)

; ! Программа в режиме вставки медлительна и нестабильна!
; Программа при старте выделяет блок памяти (4КБ), в режиме вставки его можно заполнить и сохранить.
; Файл загружается целиком.


; Макросы load_lib.mac, editbox_ex и библиотеку box_lib.obj создали:
; <Lrz> - Alexey Teplov / Алексей Теплов
; Mario79, Mario - Marat Zakiyanov / Марат Закиянов
; Diamondz - Evgeny Grechnikov / Евгений Гречников и др.



; babalbes@yandex.ru
; staper@inbox.ru



use32
	org	0x0
	db	'MENUET01'
	dd	0x1
	dd	START		;program start
	dd	I_END		;program image size
	dd	(D_END+0x400) and not 3 ;required amount of memory
	dd	(D_END+0x400) and not 3 ;stack
	dd	0x0		;buf_cmd_lin
	dd	cur_dir_path

include 'lang.inc'
include 'macros.inc'
include 'editbox_ex.mac'
include 'load_lib.mac'
;include 'debug.inc'

frgrd_color   equ 0xfefefe
bkgrd_color   equ 0x000000
kursred_color equ 0x0039ff
kurstxt_color equ 0x708090
text_color    equ 0xaaaaaa

FIRST_HEX equ 2*65536+24

struct f70
 func_n dd ?
 param1 dd ?
 param2 dd ?
 param3 dd ?
 param4 dd ?
 rezerv db ?
 name dd ?
ends


START:
	load_library	boxlib_name,cur_dir_path,buf_cmd_lin,system_path,\
	err_message_found_lib,head_f_l,myimport,err_message_import,head_f_i

	mcall	40,0x27

	mcall	68,11
	mcall	68,12,16*1024		;страничный буфер
	mov	[screen_table],eax
	mcall	68,12,4*1024
;        mov     [blocks_table],eax
	mov	[file_buffer],eax
;        mov     esi,eax
;        mcall   68,12,4*1024
;        mov     [esi],eax
;        mov     [blocks_counter],1

	mcall	68,12,1024		;Procinfo area for function 9 in MenuBar
	mov	[menu_data_1.procinfo],eax
	mov	[menu_data_2.procinfo],eax


	jmp	open_file

redraw_all:
	call	start_draw
	call	draw_window
	call	show_file_size
	call	show_codepage
	call	show_insert
red:	call	ready_screen_buffer
	call	main_area

still:
	mcall	10

	cmp	eax,6
	je	mouse
	dec	al
	jz	redraw_all
	dec	al
	jz	key
	dec	al
	jz	button
	jmp	still
key:
	mcall	2
cmp ah,6
je		Ctrl_F			;find
cmp ah,7
je		Ctrl_G			;go to
cmp ah,8
je		BackSpace
cmp ah,15
je		open_file		;Ctrl+O
cmp ah,19
je		save_file		;Ctrl+S
cmp ah,48
jb  still
cmp ah,57
jbe		input_from_keyboard	;0-9
cmp ah,65
jb  still
cmp ah,70
jbe		input_from_keyboard	;A-F
cmp ah,81
jne @f
call		Ctrl_DOWN
jmp	red
@@:
cmp ah,82
jne @f
call		Ctrl_UP
jmp red
@@:
cmp ah,84
jne @f
call		Ctrl_HOME
jmp red
@@:
cmp ah,85
je		Ctrl_END
cmp ah,96
je		change_codepage 	;тильда, cp866 - cp1251
cmp ah,97
jb  still
cmp ah,102
jbe		input_from_keyboard	;a-f
cmp ah,126
jne @f
xor ah,ah
jmp		change_codepage 	;Shift+~, koi8-r
@@:
cmp ah,110
je		invert_byte		;n
cmp ah,176
jne @f
call		LEFT
jmp red
@@:
cmp ah,177
jne @f
call		DOWN
jmp red
@@:
cmp ah,178
je		UP
@@:
cmp ah,179
je		RIGHT
cmp ah,180
jne @f
call		HOME
jmp red
@@:
cmp ah,181
je		END_
cmp ah,182
je		DEL
cmp ah,183
je		PGDN
cmp ah,184
je		PGUP
cmp ah,185
je		Insert
	jmp	still


button:
	mcall	17
	cmp	ah,1
	jne	still
	jmp	close_prog


mouse:
	mcall	37,7
	test	eax,eax
	jz	.menu_bar_1
	bt	eax,15
	jc	@f
	mov	ecx,eax
    .1: call	Ctrl_DOWN
	call	Ctrl_DOWN
	call	Ctrl_DOWN
	call	Ctrl_DOWN
	loop	.1
	jmp	red
    @@: xor	ecx,ecx
	sub	cx,ax
    .2: call	Ctrl_UP
	call	Ctrl_UP
	call	Ctrl_UP
	call	Ctrl_UP
	loop	.2
	jmp	red
  .menu_bar_1:
	call	.set_mouse_flag
  @@:	push	dword menu_data_1	;mouse event for Menu 1
	call	[menu_bar_mouse]
	cmp	[menu_data_1.click],dword 1
	jne	.menu_bar_2
	cmp	[menu_data_1.cursor_out],dword 0
	jne	.analyse_out_menu_1
	jmp	.menu_bar_1
  .menu_bar_2:
	push	dword menu_data_2
	call	[menu_bar_mouse]
	cmp	[menu_data_2.click],dword 1
	jne	.menu_bar_3
	cmp	[menu_data_2.cursor_out],dword 0
	jne	.analyse_out_menu_2
	jmp	.menu_bar_1
  .menu_bar_3:
	push	dword menu_data_3
	call	[menu_bar_mouse]
	cmp	[menu_data_3.click],dword 1
	jne	.scroll_bar
	cmp	[menu_data_3.cursor_out],dword 0
	jne	.analyse_out_menu_3
	jmp	.menu_bar_1


  .set_mouse_flag:
	xor	eax,eax
	inc	eax
	mov	[menu_data_1.get_mouse_flag],eax
	mov	[menu_data_2.get_mouse_flag],eax
	mov	[menu_data_3.get_mouse_flag],eax
	ret

  .analyse_out_menu_1:
	cmp	[menu_data_1.cursor_out],dword 1
	je	open_file
	cmp	[menu_data_1.cursor_out],dword 2
	je	save_file
	cmp	[menu_data_1.cursor_out],dword 3
	je	close_prog
	jmp	still

  .analyse_out_menu_2:
	cmp	[menu_data_2.cursor_out],dword 1
	jne	@f
	add	[number_columns],4
	jmp	redraw_all
  @@:	cmp	[menu_data_2.cursor_out],dword 2
	jne	@f
	add	[number_columns],8
	jmp	redraw_all
  @@:	cmp	[menu_data_2.cursor_out],dword 3
	jne	@f
	cmp	[number_columns],4
	je	still
	sub	[number_columns],4
	jmp	redraw_all
  @@:	cmp	[menu_data_2.cursor_out],dword 4
	jne	still
	cmp	[number_columns],8
	jbe	 still
	sub	[number_columns],8
	jmp	redraw_all


  .analyse_out_menu_3:			;analyse result of Menu 2
	cmp	[menu_data_3.cursor_out],dword 1
	jne	still
	call	create_help_window
	jmp	still

  .scroll_bar:
	mcall	37,2
	test	eax,eax
	jnz	@f
	btr	[flags],5
	jmp	still
@@:	bt	[flags],5
	jc	@f
	mcall	37,1
	shr	eax,16
	cmp	ax,[scroll_bar_data_vertical.start_x]
	jb	still
	sub	ax,[scroll_bar_data_vertical.start_x]
	cmp	ax,[scroll_bar_data_vertical.size_x]
	jge	still
@@:
	mov	edi,[screen_table]
	mov	edi,[edi]
	cmp	edi,[file_size]
	jge	still
	push	dword scroll_bar_data_vertical ;draw for Vertical ScrollBar
	call	[scrollbar_ver_mouse]

	xor	edx,edx
	movzx	ebx,[scroll_bar_data_vertical.size_y]
	mov	ecx,[file_size]
	mov	esi,[number_columns]
	mov	eax,[scroll_bar_data_vertical.position]
	mul	ecx
	div	esi
	xor	edx,edx
	div	ebx
	mul	esi

	cmp	eax,[file_size]
	jng	@f
	sub	eax,esi;[number_columns]
  @@:	mov	ecx,[cursor]
	inc	ecx
	shr	ecx,1
	add	ecx,eax
  @@:	cmp	ecx,[file_size]
	jbe	@f
	sub	ecx,esi;[number_columns]
	sub	eax,esi;[number_columns]
	jmp	@b
  @@:	mov	[begin_offset],eax
	bts	[flags],5
jmp	red

;------------------------------------------------

;------------------------------------------------
align 4
ready_screen_buffer:
	mov	esi,[screen_table]
	push	word [cursor]
	mov	ecx,[esi] ;кол-во подготавливаемых байт
	push	cx
	add	esi,4
	mov	ebx,[begin_offset]
	mov	eax,[file_size]
	test	eax,eax
	jnz	.1
	mov	dword [esi],0
	dec	word [esp+2]
	mov	byte [esi+1],1	;метим курсор
	dec	ecx
	add	esi,4
	jmp	.pre_end_ready
  .1:
	mov	edi,[file_buffer];blocks_table]
;       xor     eax,eax
;  @@:  add     eax,[edi+4]     ;находим нужный блок
;       add     edi,8
;       cmp     ebx,eax
;       jg      @b
;       sub     edi,8
;       push    edi
;       sub     eax,ebx
;       mov     ebx,[edi+4]
;       sub     ebx,eax
;  next_block:
;       mov     edx,[edi]       ;начало блока+смещение
;       add     edx,ebx
;       mov     eax,[edi+4]     ;размер блока
;       sub     eax,ebx         ;осталось в блоке
;       xchg    eax,ebx
	xor	eax,eax

	mov	edx,ebx
	add	edx,edi
	mov	ebx,[file_size]
	sub	ebx,[begin_offset]

  .next_byte:
	mov	al,[edx]
	ror	ax,4
	cmp	al,10
	sbb	al,69h
	das
	mov	[esi],al
	mov	byte [esi+1],0
	dec	word [esp+2];+6]
	jnz	@f
	mov	byte [esi+1],1 ;метим курсор
  @@:	shr	ax,12
	cmp	al,10
	sbb	al,69h
	das
	mov	[esi+2],al
	mov	byte [esi+3],0
	dec	word [esp+2];+6]
	jnz	@f
	mov	byte [esi+3],1 ;метим курсор
  @@:	inc	edx
	add	esi,4
	cmp	word [esp],1;4],1
	jbe	.pre_end_ready;pre_pre_end_ready
	dec	word [esp];+4]
	dec	ecx
	jnz	@f
;       pop     eax
	jmp	.end_ready
  @@:;   jz      end_ready
	dec	ebx
	jnz	.next_byte
;       pop     edi
;       cmp     dword [edi+8],0
;       je      @f
;       xor     ebx,ebx
;       add     edi,8
;       push    edi
;       jmp     next_block
;  @@:  push    eax             ;поиск ненулевого блока
;  @@:  mov     eax,edi         ;адрес текущего смещения в таблице блоков
;       sub     eax,[blocks_table]
;       shr     eax,3
;       cmp     eax,[blocks_counter]
;       jge     pre_pre_end_ready
;       add     edi,8
;       cmp     dword [edi+4],0
;       je      @b
;       jmp     next_block
;  pre_pre_end_ready:
;       add     esp,4   ;pop    eax
  .pre_end_ready:
	mov	dword [esi],0
	dec	word [esp+2]
	jnz	@f
	mov	byte [esi+1],1 ;метим курсор
  @@:	dec	word [esp+2]
	jnz	@f
	mov	byte [esi+3],1 ;метим курсор
  @@:	add	esi,4
	loop	.pre_end_ready
  .end_ready:
	add	esp,4	;pop     eax
ret



align 4
main_area:
	mov	edi,[screen_table]
	mov	edi,[edi]
	cmp	[file_size],edi
	jbe	.4
	xor	edx,edx 	;ползунок
	movzx	ebx,[scroll_bar_data_vertical.size_y]
	mov	ecx,[file_size]
	mov	eax,[current_offset]
	test	eax,eax
	jnz	.3
	inc	eax
  .3:	mul	ebx
	div	ecx
	mov	[scroll_bar_data_vertical.position],eax

	mcall	37,2	;кпопка мыши нажата - нет смысла перерисовывать ScrollBar
	test	eax,eax
	jnz	.4
	push	dword scroll_bar_data_vertical ;draw for Vertical ScrollBar
	call	[scrollbar_ver_draw]

  .4:	mov	esi,0x000001	;цвет и число бит на пиксель

	mov	edx,FIRST_HEX ;координаты первого hex
	call	left_table
	call	show_current_offset

  @@:	mcall	18,14
	test	eax,eax
	jnz	@b

	mov	ebp,[number_columns]
	cmp	ebp,8
	jge	@f
	mov	eax,ebp
	xor	ebp,ebp
	jmp	.1
  @@:	sub	ebp,8
	mov	eax,8
  .1:	xor	ebx,ebx
	mov	edi,[screen_table]
	mov	ecx,[edi]
	add	edi,4

	call	newhex

  @@:	mcall	18,14
	test	eax,eax
	jnz	@b

	mov	eax,[number_columns]
	cmp	eax,8
	jge	@f
	mov	ebp,eax
	xor	eax,eax
	jmp	.2
  @@:	sub	eax,8
	mov	ebp,8
  .2:	xor	ebx,ebx
	mov	edi,[screen_table]
	mov	ecx,[edi]
	add	edi,4

	call	right_table

	jmp	end_draw

align 4
newhex:
	mov	bx,[edi]

	push	eax ecx esi edi ebp
	mov	edi,palitra
	test	bh,bh
	jz	@f
	xor	bh,bh
	mov	edi,palitra3
    @@: shl	bx,4
	add	ebx,font_buffer
	mov	ecx,8*65536+16
	mov	ebp,0
	mcall	65
	pop	ebp edi esi ecx eax

	add	edi,2
	mov	bx,[edi]
	add	edx,8*65536

	push	eax ecx esi edi ebp
	mov	edi,palitra
	test	bh,bh
	jz	@f
	xor	bh,bh
	mov	edi,palitra3
    @@: shl	bx,4
	add	ebx,font_buffer
	mov	ecx,8*65536+16
	mov	ebp,0
	mcall	65
	pop	ebp edi esi ecx eax

	add	edi,2

	dec	eax
	jnz	.2
		bt	[flags],6
		jnc	@f
		pushad
		mov	ebx,edx
		add	ebx,8*65536
		mov	bx,16
		ror	edx,16
		mov	dx,16
		mov	ecx,edx
		mov	edx,frgrd_color
		mcall	13
		popad
		@@:
	add	edx,12*65536
	cmp	ebp,8
	jge	.1
	mov	eax,ebp
	test	eax,eax
	jz	end_str
	mov	ebp,0
	jmp	.2
  .1:	sub	ebp,8
	mov	eax,8
  .2:		bt	[flags],6
		jnc	@f
		pushad
		mov	ebx,edx
		add	ebx,8*65536
		mov	bx,4
		ror	edx,16
		mov	dx,16
		mov	ecx,edx
		mov	edx,frgrd_color
		mcall	13
		popad
		@@:
	add	edx,12*65536
	dec	ecx
	jnz	newhex

	push	edx
	push	dword (FIRST_HEX-18)
	mov	edx,[right_table_xy]
	mov	dx,[esp]
	add	edx,16*65536
	mov	[right_table_xy],edx
	add	esp,4
	pop	edx
ret



align 4
end_str:
	push	ecx edx
	mov	ecx,[number_columns]
	mov	edx,8
	xor	eax,eax
  @@:	add	ax,20
	dec	cx
	jz	@f
	dec	dl
	jnz	@b
	add	ax,12
	mov	dl,8
	jmp	@b
  @@:	pop	edx
	shl	eax,16
	mov	[right_table_xy],edx
		bt	[flags],6
		jnc	@f
		pushad
		mov	ebx,edx
		add	ebx,8*65536
		mov	bx,8
		ror	edx,16
		mov	dx,16
		mov	ecx,edx
		mov	edx,frgrd_color
		mcall	13
		movzx	ebx,[scroll_bar_data_vertical.start_x]
		sub	ecx,2*65536
		mov	cx,2
		mcall
		popad
		@@:
	sub	edx,eax
	add	edx,18
	pop	ecx

	mov	ebp,[number_columns]

	cmp	ebp,8
	jge	@f
	mov	eax,ebp
	xor	ebp,ebp
	jmp	.1
  @@:	sub	ebp,8
	mov	eax,8
  .1:	dec	ecx
	jnz	newhex

	push	edx
	push	dword (FIRST_HEX-18)
	mov	edx,[right_table_xy]
	mov	dx,[esp]
	add	edx,16*65536
	mov	[right_table_xy],edx
	add	esp,4
	pop	edx
ret



align 4
right_table:
	pushad
	push	dword [right_table_xy]
	mov	ebx,[file_size]
	mov	eax,[begin_offset]
	sub	ebx,[begin_offset]
	cmp	ebx,ecx
	jb	@f
	mov	ebx,ecx
  @@:	push	ebx
	mov	esi,[cursor]
	dec	esi
	shr	esi,1
	mov	edi,palitra2
	mov	edx,[right_table_xy]
	add	eax,[file_buffer]
  .1:	mov	ebp,[number_columns]
	add	edx,18
	xor	ebx,ebx
  .2:
	mov	bl,[eax]
	shl	bx,4
  .3:
	push	eax ecx ebp esi
	cmp	ebx,128*16	 ;проверка на принадлежность символа к расширенной таблице
	jb	@f
	add	ebx,[codepage_offset]
  @@:	add	ebx,font_buffer
	mov	ecx,8*65536+16
	mov	ebp,0
	test	esi,esi
	jnz	@f
	add	edi,16;palitra4
  @@:	mov	esi,1
	mcall	65
	pop	esi ebp ecx eax
	test	esi,esi
	jnz	@f
	sub	edi,16
  @@:	dec	esi
	xor	ebx,ebx
	dec	ecx
	jz	.end
	dec	dword [esp]
	jnz	@f
	inc	dword [esp]
	add	edx,8*65536
	dec	ebp
	jnz	.3
	push	edx
	mov	edx,[number_columns]
	shl	edx,19	;mul 8*[number_columns]*65536
	sub	dword [esp],edx
	pop	edx
	mov	ebp,[number_columns]
	add	edx,18
	jmp	.3
  @@:	inc	eax
	add	edx,8*65536
	dec	ebp
	jnz	.2
	push	edx
	mov	edx,[number_columns]
	shl	edx,19
	sub	dword [esp],edx
	pop	edx
	jmp	.1
  .end:
	add	esp,4
		bt	[flags],6
		jnc	@f
		mov	eax,[number_columns]
		shl	eax,19
		mov	edx,[esp]
		add	edx,eax
		mov	eax,[number_strings]
		lea	ecx,[eax*8];*18
		lea	ecx,[ecx*2]
		lea	eax,[eax*2]
		add	eax,ecx
		shr	edx,16
		mov	bx,dx
		ror	ebx,16
		mov	bx,[scroll_bar_data_vertical.start_x]
		sub	bx,dx
		mov	ecx,(FIRST_HEX)
		shl	ecx,16
		mov	cx,ax
		mcall	13,,,frgrd_color
		btr	[flags],6
		@@:
	pop	dword [right_table_xy]
	popad
ret

align 4
left_table:				;смещения строк
	push	edx
	mov	eax,[number_strings]	;количество строк
	mov	ebx,[begin_offset]	;выводимое число
 .2:	mov	ecx,8
	cmp	[file_size],0x00ffffff
	jg	.1
	sub	ecx,2
	cmp	[file_size],0x0000ffff
	jg	.1
	sub	ecx,2
	cmp	[file_size],0x000000ff
	jg	.1
	sub	ecx,2
	mov	edi,palitra2
.1:	call	hex_output
	add	ebx,[number_columns]
		bt	[flags],6
		jnc	@f
		pushad
		mov	ebx,edx
		lea	eax,[ecx*8]
		shl	eax,16
		add	ebx,eax
		mov	bx,16
		ror	edx,16
		mov	dx,16
		mov	ecx,edx
		mov	edx,frgrd_color
		mcall	13
		popad
		@@:
	add	edx,18
	dec	eax
	jnz	.2
	lea	eax,[ecx*8+16]
	shl	eax,16
	pop	edx
	add	edx,eax
ret

align 4
show_current_offset:
	push	edx		;вывод текущего смещения в файле
	mov	edi,palitra5
	mov	eax,[begin_offset]
	mov	ebx,[cursor]
	dec	ebx
	shr	bx,1
	add	ebx,eax
	mov	[current_offset],ebx
	mov	edx,[low_area]
	lea	eax,[ecx*8+8]
	shl	eax,16
	add	edx,eax
	call	hex_output
	lea	eax,[ecx*8+14]
	shl	eax,16
	add	edx,eax
	push	edx
				;двоичное значение байта
	mov	edx,[file_buffer]
	add	edx,ebx;[current_offset]
	xor	eax,eax
	mov	al,[edx]
	mov	bx,2
	mov	ebp,8
	xor	ecx,ecx
	xor	edx,edx
  @@:	div	bx
	or	cl,dl
	ror	ecx,4
	dec	ebp
	jnz	@b
	mov	ebx,ecx
	pop	edx
	mov	ecx,8
	call	hex_output

				;десятичное
	push	edx
	mov	edx,[file_buffer]
	add	edx,[current_offset]
	xor	eax,eax
	xor	ebx,ebx
	mov	al,[edx]
;        mov     ebp,3
	mov	cl,10
  @@:	div	cl
	mov	bl,ah
	xor	ah,ah
	shl	ebx,8
	test	al,al
;        dec     ebp
	jnz	@b
	shr	ebx,8
	cmp	byte [edx],100
	jb	.1
	mov	ebp,3
	jmp	@f
  .1:	mov	ebp,1
	cmp	byte [edx],10
	jb	@f
	mov	ebp,2
  @@:	mov	al,bl
	shr	ebx,8
	cmp	al,10
	sbb	al,69h
	das
	shl	eax,8
;        test    bx,bx
	dec	ebp
	jnz	@b

	mov	ecx,8*65536+16
	pop	edx
	add	edx,(8*8+30)*65536;268*65536
	mov	edi,palitra2
	mov	ebp,0
	push	dword 3

  @@:	shr	eax,8
	xor	ebx,ebx
	mov	bl,al
	shl	ebx,4
	add	ebx,font_buffer
	push	eax
	mcall	65
	pop	eax
	sub	edx,8*65536
	dec	dword [esp]
	jnz	@b
	add	esp,4

;       mov     edx,[low_area]  ;вывод esp
;       add     edx,298*65536
;       mov     ebx,esp
;       mov     ecx,8
;       call    hex_output
       pop	edx
ret


align 4
hex_output:				;вывод hex строки из 8 символов
	pushad
	mov	edi,(hex8_string)   ;адрес буфера
	mov	dword [edi],0x30303030
	mov	dword [edi+4],0x30303030
	push	ecx
.1:
	mov	eax,ebx
	and	eax,0xF
	cmp	al,10
	sbb	al,69h
	das
	mov	[edi+ecx-1],al
	shr	ebx,4
	loop	.1

	mov	ecx,8*65536+16
.2:	push	edi
	xor	ebx,ebx
	mov	al,[edi]
	shl	eax,4
	add	eax,font_buffer
	xchg	eax,ebx
	mov	edi,palitra5
	mov	ebp,0
	mcall	65
	add	edx,8*65536
	pop	edi
	inc	edi
	dec	dword [esp]
	jnz	.2
	add	esp,4
	popad
ret



;-----------------------------------------
align 4
input_from_keyboard:
	sub	ah,48
	cmp	ah,9
	jbe	.1
	sub	ah,7
	cmp	ah,15
	jbe	.1
	sub	ah,32
  .1:	bt	[flags],1
	jnc	.2
	mov	ebx,[cursor]
	and	bl,1
	jz	.2
	mov	edi,[current_offset]
	add	edi,[file_buffer]
	mov	esi,[file_buffer]
	add	esi,[file_size]
    @@:
	cmp	edi,esi
	jg	@f
	mov	bl,[esi]
	mov	[esi+1],bl
	dec	esi
	jmp	@b
    @@:
	inc	[file_size]
	call	show_file_size
	mov	ebx,[current_offset]
	add	ebx,[file_buffer]
	mov	byte [ebx],0
    .2:
	mov	ecx,[current_offset]
	add	ecx,[file_buffer]
					;см. первую версию heed.asm
	mov	dl,[ecx]		;оригинальный байт
	mov	ebx,[cursor]
	and	bl,1			;нечет - редактируем старший полубайт
	jnz	.hi_half_byte		;чёт - старший
	and	dl,0xf0 		;обнуляем мл. п-байт оригинального байта
	jmp	.patch_byte
    .hi_half_byte:	;одновременно сдвигаем нужное значение в ст.п-т и обнуляем младший
	shl	ax,4
	and	dl,0x0f ;обнуляем старший полубайт у оригинального байта
    .patch_byte:
	or	ah,dl
	mov	[ecx],ah
jmp    RIGHT

;---------------------------------------

;get_offset:     ;ebx - входное смещение, bl - требуемый байт
;        mov     eax,[file_size]
;        inc     ebx
;        cmp     ebx,eax
;        jge     end_get_offset
;        mov     edi,[blocks_table]
;        xor     eax,eax
;  @@:   add     eax,[edi+4]
;        add     edi,8
;        cmp     ebx,eax
;        jg      @b
;        sub     edi,8
;        push    edi
;        sub     eax,ebx         ;смещение в блоке
;        mov     edx,[edi]       ;начало блока+смещение
;        add     edx,ebx
;        mov     bl,[edx]
;        ret
;  end_get_offset:
;        mov     bl,0
;ret

align 4
show_file_size:
	mov	ebx,[file_size]
	mov	edx,[low_area];
	mov	esi,1
	mov	ecx,8
	cmp	ebx,0x00ffffff
	jg	@f
	sub	ecx,2
	cmp	ebx,0x0000ffff
	jg	@f
	sub	ecx,2
	cmp	ebx,0x000000ff
	jg	@f
	sub	ecx,2
@@:	call	hex_output
ret


align 4
draw_window:
	mcall	0,100*65536+593,100*65536+360,((0x73 shl 24) + frgrd_color),,title

	mcall	9,threath_buf,-1
	cmp	byte [threath_buf+70],3 ;окно свёрнуто в заголовок?
	jnge	@f
	call	end_draw
	jmp	still

@@:

	mov	eax,dword [threath_buf+62]	;ширина клиентской области
	sub	ax,[scroll_bar_data_vertical.size_x];14
	mov	[scroll_bar_data_vertical.start_x],ax
	mov	eax,dword [threath_buf+66]	;высота клиентской области
	sub	eax,24+24-11
	mov	[scroll_bar_data_vertical.size_y],ax
	add	eax,[scroll_bar_data_vertical.cur_area];10
	mov	[scroll_bar_data_vertical.max_area],eax
	sub	eax,23
	mov	ebx,18
	xor	edx,edx
	div	bx
	mov	[number_strings],eax		;кол-во hex строк в окне
	mov	ebx,[number_columns]
	mul	ebx
	mov	edi,[screen_table]		;кол-во байтов для вывода
	mov	dword [edi],eax


	mov	ebx,2
	mov	ecx,dword [threath_buf+66]
	mcall	13,,,frgrd_color	;полоса слева

	mov	ebx,dword [threath_buf+62]
	inc	ebx
	mov	ecx,(FIRST_HEX-18)
	ror	ecx,16
	mov	cx,18
	ror	ecx,16
	mcall

	mcall	,,18,0xe9e9e2 	;верхняя панель
	dec	ebx
	mcall	38,,<18,18>,0x8b8b89
	mov	ecx,dword [threath_buf+66]
	sub	cx,18
	push	cx
	shl	ecx,16
	pop	cx
	mcall	,,,0x777777;eaeae3		;нижняя панель
	add	ecx,1*65536
	mov	cx,18
;	inc	ebx
	mcall	13,,,0xe9e9e2

		shr	ecx,16
		mov	edx,ecx
		mov	ecx,(FIRST_HEX)
		shr	ecx,16
		mov	eax,[number_strings]
		lea	ebx,[eax*8];*18
		lea	ebx,[ebx*2]
		lea	eax,[eax*2]
		add	eax,ebx
		add	cx,ax
		add	cx,21
		sub	dx,cx
		shl	ecx,16
		add	cx,dx
		sub	ecx,1*65536
		movzx	ebx, word [scroll_bar_data_vertical.start_x]
		mcall	13,,,frgrd_color


	push	dword menu_data_1	;draw for Menu 1
	call	[menu_bar_draw]
	push	dword menu_data_2	;draw for Menu 2
	call	[menu_bar_draw]
	push	dword menu_data_3	;draw for Menu 3
	call	[menu_bar_draw]


	cmp	eax,[file_size]
	jge	@f
	push	dword scroll_bar_data_vertical
	call	[scrollbar_ver_mouse]
	xor	eax,eax
	inc	eax
	mov	[scroll_bar_data_vertical.all_redraw],eax
	push	dword scroll_bar_data_vertical	;draw for Vertical ScrollBar
	call	[scrollbar_ver_draw]
	xor	eax,eax 			;reset all_redraw flag
	mov	[scroll_bar_data_vertical.all_redraw],eax
  @@:
	mov	ebx,dword [threath_buf+66]
	add	ebx,2*65536-15
	mov	[low_area],ebx

	mov	eax,[number_columns]
	mov	cx,18
	mul	cx
	mov	bx,ax
	mov	eax,[number_columns]
	shr	ax,3
	inc	ax
	mov	cx,19
	mul	cx
	mov	ecx,8
	cmp	[file_size],0x00ffffff
	jg	@f
	sub	cl,2
  @@:	cmp	[file_size],0x0000ffff
	jg	@f
	sub	cl,2
  @@:	cmp	[file_size],0x000000ff
	jg	@f
	sub	cl,2
  @@:	shl	cx,3
	add	ax,bx
	add	ax,cx
	shl	eax,16
	add	eax,30*65536+6
	mov	[right_table_xy],eax

	mov	edi,[screen_table]
	mov	esi,[number_columns]
	mov	ecx,esi
	shl	ecx,1
	mov	eax,[edi]
	mov	ebx,[cursor]
	inc	ebx
	shr	ebx,1
  @@:	cmp	eax,ebx
	jge	@f
	add	[begin_offset],esi
	sub	[cursor],ecx
	sub	ebx,esi
	jmp	@b
  @@:





	bts	[flags],6
ret

align 4
start_draw:
	mcall	12,1
ret

end_draw:
	mcall	12,2
ret

close_prog:
	mcall	-1



;-------------------------------------------------------------------------------
change_codepage:		;меняем вторую половину таблицы
	test	ah,ah
	jnz	@f
	btc	[flags],4
	jc	.1
	push	[codepage_offset]
	pop	[codepage_offset_previous]
	mov	[codepage_offset],2*128*16
	jmp	.end
.1:	push	[codepage_offset_previous]
	pop	[codepage_offset]
	jmp	.end
@@:	cmp	[codepage_offset],0
	jne	 @f
	add	[codepage_offset],128*16
	jmp	.end
@@:	mov	[codepage_offset],0
.end:	call	show_codepage
jmp	red


show_codepage:
	mov	ebp,6
	mov	edx,dword [threath_buf+62]
	sub	edx,73
	shl	edx,16
	add	edx,[low_area]
;        mov     edx,510*65536+335
	mov	edi,string_cp866
	cmp	[codepage_offset],0
	je	@f
	add	edi,6
	cmp	[codepage_offset],128*16
	je	@f
	add	edi,6
  @@:	mov	ecx,8*65536+16
	mov	esi,1
	push	ebp
	mov	ebp,0
  @@:	xor	ebx,ebx
	push	edi
	mov	bl,[edi]
	shl	bx,4
	add	ebx,font_buffer
	mov	edi,palitra
	mcall	65
	add	edx,8*65536
	pop	edi
	inc	edi
	dec	dword [esp]
	jnz	@b
	add	esp,4
ret

show_insert:		;отображение режима вставки/замены
	mov	ebp,3
	mov	edx,dword [threath_buf+62]
	sub	edx,120
	shl	edx,16		;        mov     edx,428*65536+335
	add	edx,[low_area]
	mov	edi,string_ins
	push	ebp
	mov	ecx,8*65536+16
	mov	esi,1
	mov	ebp,0

  .1:	xor	ebx,ebx
	push	edi
	bt	[flags],1
	jnc	.2
	mov	bl,[edi]
	shl	bx,4
  .2:
	add	ebx,font_buffer
	mov	edi,palitra
	mcall	65
	add	edx,8*65536
	pop	edi
	inc	edi
	dec	dword [esp]
	jnz	.1
	add	esp,4
ret
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
	;help window
create_help_window:
	popad
	mcall	51,1,.thread,(.threat_stack+16*4)
	pushad
	ret
 .thread:
	call	.window
 .still:
	mcall	10
	dec	al
	jz	.red
	dec	al
	jz	.key
	dec	al
	jz	.button
	jmp	.still
	mcall	-1
.button:
	mcall	17,1
	cmp	ah,1
	jne	@f
	mcall	-1
 @@:	cmp	ah,2
	jne	@f
	mov	edi,(help_end-help_text)/51
	movzx	eax,[nmbr_help_string]
	sub	edi,13
	sub	edi,eax
	jz	.still
	inc	[nmbr_help_string]
	jmp	.red
 @@:	cmp	ah,3
	jne	.still
	cmp	[nmbr_help_string],0
	je	.still
	dec	[nmbr_help_string]
	jmp	.red


.key:
	mcall	2
	jmp	.still

.red:
	call	.window
	jmp	.still

.window:
	pushad
	mcall	12,1
	mcall	0,50*65536+320,0x70*65536+240,0x13000000,,help_but_text
	mcall	8,<130,20>,<6,12>,2,0xaaaaaa
	mcall	,<150,20>,,3,
	mov	ebx,8*65536+15
	mov	ecx,0x00DDDDDD
	xor	edx,edx
	movzx	eax,byte [nmbr_help_string]
	mov	edi,(help_end-help_text)/51
	sub	edi,eax
	mov	esi,51
	mul	si
	mov	edx,help_text
	add	edx,eax
	mov	eax,4

 @@:	add	ebx,0x10
	mcall
	add	edx,51
	dec	edi
	jnz	@b
	mcall	12,2
	popad
ret

.threat_stack: times 16 dd 0
;-------------------------------------------------


;---------------------------------------------

open_file:
	mov	eax,edit1
	call	draw_ed_box	;рисуем editbox
				;размер файла?
	mov	[func_70.func_n],5
	mov	[func_70.param1],0
	mov	[func_70.param2],0
	mov	[func_70.param3],0
	mov	[func_70.param4],bufferfinfo
	mov	[func_70.rezerv],0
	mov	[func_70.name],file_name
	mcall	70,func_70

	test	al,al		;файл найден?
	jz	@f
	mcall	4,400*65536+31,0x80CC0000,error_open_file_string
	jmp	open_file
  @@:
;       mov     edx,[blocks_counter]
;       mov     edi,[blocks_table]
;  @@:  mov     ecx,[edi]               ;высвобождаем:
;       mcall   68,13                   ;блоки файла
;       add     edi,8
;       dec     edx
;       jnz     @b
;       mcall   68,13,[blocks_table]    ;таблицу

	mov	eax, dword [bufferfinfo+32]	;копируем размер файла
	mov	[file_size],eax

;       mov     ebx,65536       ;64КБ блок
;       xor     edx,edx
;       div     ebx
;       push    dx              ;длина последнего блока
;       test    dx,dx
;       jz      @f
;       inc     eax
;  @@:  test    eax,eax
;       jnz     @f
;       inc     eax
;  @@:  mov     [blocks_counter],eax
;       sal     eax,3;*8        ;размер таблицы с индексами блоков
;;        add     eax,32          ;решаем проблему с 32МБ файлами

;       mov     ecx,eax         ;выделяем память:
;       mcall   68,12           ;под таблицу
;       mov     [blocks_table],eax
;       mov     edi,eax
;       mov     ecx,[blocks_counter]
;  @@:  mov     dword [edi+4],65536
;       add     edi,8
;       loop    @b
;       xor     edx,edx
;       pop     dx              ;длина последнего блока
;       mov     dword [edi-4],edx

;       mov     edx,[blocks_counter]
;       mov     edi,[blocks_table]
;  @@:  mcall   68,12,[edi+4]   ;под блок
;       mov     [edi],eax
;       add     edi,8
;       dec     edx
;       jnz     @b

	mcall	68,13,[file_buffer]
	test	eax,eax
	jnz	@f
	;здесь ошибка на не освобождение блока
  @@:	mcall	68,12,[file_size]
	mov	[file_buffer],eax

;       ;имеем таблицу: [ DWORD указатель на первый элемент блока : DWORD длина блока ]

;       mov     ecx,[blocks_counter]    ;открываем файл
;       mov     edi,[blocks_table]
	mov	[func_70.func_n],0
	mov	[func_70.param1],0
	mov	[func_70.param2],0
	mov	[func_70.rezerv],0
	mov	[func_70.name],file_name
;  @@:
	push	dword [file_size];dword [edi+4]
	pop	dword [func_70.param3]
	push	dword [file_buffer];dword [edi]
	pop	dword [func_70.param4]
	mcall	70,func_70
;       add     edi,8
;       add     dword [func_70.param1],65536
;       loop    @b

	test	eax,eax
	jz	@f
	;ошибка чтения
  @@:
	call	Ctrl_HOME

jmp	redraw_all
;-------------------------------------------------------------------------------
save_file:			;сохраняем файл
	mov	eax,edit1
	call	draw_ed_box

	mov	[func_70.func_n],2
	mov	[func_70.param1],0
	mov	[func_70.param2],0
	push	[file_size]
	pop	[func_70.param3]
	push	[file_buffer]
	pop	[func_70.param4]
	mov	[func_70.rezerv],0
	mov	[func_70.name],file_name
	mcall	70,func_70
	cmp	al,0			;сохранён удачно?
	je	redraw_all
	mcall	4,400*65536+31,0x80CC0000,error_save_file_string
	jmp	save_file
;-------------------------------------------------------------------------------
draw_ed_box:			;рисование edit box'а
	push	dword eax
  .1:	push	eax ebx ecx edx
	mcall	13,180*65536+220,25*65536+70,0xaaaaaa
	bt	[flags],2
	jnc	@f
	push	dword Option_boxs
	call	[option_box_draw]
    @@: bt	[flags],3
	jnc	@f
	push	dword Option_boxs2
	call	[option_box_draw]
    @@: pop	edx ecx ebx eax
	call	[edit_box_draw]
	sub	esp,4
  .2:
	mcall	10

	cmp	al,6
	je	.mouse
	cmp	al,3
	je	.button
	cmp	al,2
	je	.keys
	cmp	al,1
	jne	.2
	call	draw_window
	call	main_area
	bt	[flags],2
	jnc	@f
	push	dword Option_boxs
	call	[option_box_draw]
    @@: bt	[flags],3
	jnc	@f
	push	dword Option_boxs2
	call	[option_box_draw]
    @@: jmp	.1

 .mouse:
	bt	[flags],2
	jnc	@f
	push	dword Option_boxs
	call	[option_box_mouse]
    @@: bt	[flags],3
	jnc	@f
	push	dword Option_boxs2
	call	[option_box_mouse]
    @@: jmp	.2

 .keys:
	mcall	2
	cmp	ah,13
	je	.4
	cmp	ah,27
	je	.3

	bt	[flags],2	;проверка на применимость символов 0-9,a-b
	jnc	.ob2
     ;.ob1:
	cmp	ah,9
	jne	.7
	push	edx
	mov	edx,[option_group1]
	cmp	edx,op1
	jne	@f
	mov	edx,op2
	jmp	.8
       @@: cmp	edx,op2
	jne	@f
	mov	edx,op3
	jmp	.8
	jmp	.1
       @@: mov	edx,op1
       .8: mov	[option_group1],edx
	pop	edx
	jmp	.1
       .7:
	cmp	ah,48
	jb	.6
	cmp	ah,57
	jbe	.eb
	cmp	ah,102
	jg	.6
	cmp	ah,97
	jge	.eb
    .6: cmp	ah,182
	je	.eb
	cmp	ah,8
	je	.eb
	cmp	ah,176
	je	.eb
	cmp	ah,179
	je	.eb
	dec	[edit2.shift]
	dec	[edit2.shift+4]

	push	dword [esp]
	call	[edit_box_draw]
	jmp	.2

    .ob2:
	bt    [flags],3
	jnc	.eb
	cmp	ah,9
	jne	.72
	push	edx
	mov	edx,[option_group2]
	cmp	edx,op11
	jne	@f
	mov	edx,op12
	jmp	.82
       @@: mov	edx,op11
       .82: mov  [option_group2],edx
	pop	edx
	jmp	.1
       .72:
	cmp	ah,182
	je	.eb
	cmp	ah,8
	je	.eb
	cmp	ah,176
	je	.eb
	cmp	ah,179
	je	.eb
	mov	edx,[option_group2]
	cmp	edx,op11
	jne	.eb
	cmp	ah,48
	jb	.62
	cmp	ah,57
	jbe	.eb
	cmp	ah,102
	jg	.62
	cmp	ah,97
	jge	.eb
      .62:
	dec	[edit3.shift]
	dec	[edit3.shift+4]
	push	dword [esp]
	call	[edit_box_draw]
	jmp	.2
    .eb:
	push	dword [esp]
	call	[edit_box_key]
	jmp	.2

  .button:
	mcall	17
	cmp	ah,1
	jne	.2
	jmp	close_prog
  .3:
	btr	[flags],2
	btr	[flags],3
	add	esp,8
	jmp	redraw_all
  .4:
	add	esp,4
ret



;-------------------------------------------------
;-------------------------------------------------
;-------------------------------------------------












Ctrl_G:
	bts	[flags],2
	mov	eax,edit2
	call	draw_ed_box
	btr	[flags],2
	mov	ecx,[edit2.size]
	test	ecx,ecx
	jz	.end
	cmp	ecx,8
	jg	Ctrl_G
	mov	edi,go_to_string
	mov	esi,hex8_string
  @@:	mov	ah,[edi+ecx-1]	;обработка введённых символов
	sub	ah,48
	cmp	ah,9
	jbe	.1
	sub	ah,7
	cmp	ah,15
	jbe	.1
	sub	ah,32
  .1:	mov	[esi+ecx-1],ah
	dec	ecx
	jnz	@b
	mov	ecx,[edit2.size]
	xor	eax,eax
  .2:	shl	eax,4
	or	al,[esi]
	inc	esi
	dec	ecx
	jnz	.2

	cmp	eax,[file_size] ;выбор check_box'а
	jg	Ctrl_G
	mov	edx,[option_group1]
	cmp	edx,op1   ;abs
	je	.abs
	cmp	edx,op2
	jne	.back
	add	eax,[current_offset] ;forward
	cmp	eax,[file_size]
	jg	Ctrl_G
	mov	edi,[screen_table]
	mov	edi,[edi]
	xor	edx,edx
   @@:	add	edx,edi
	cmp	eax,edx
	jg	@b
	sub	edx,edi
	mov	[begin_offset],edx
	sub	eax,edx
	shl	eax,1
	inc	eax
	mov	[cursor],eax
	jmp	.end

 .back:; cmp     edx,op3
;        jne     .abs
	cmp	eax,[current_offset] ;back
	jg	Ctrl_G
	mov	edi,[screen_table]
	mov	edi,[edi]
	mov	ebx,[current_offset]
	sub	ebx,eax
	xor	edx,edx
   @@:	add	edx,edi
	cmp	edx,ebx
	jb	@b
	sub	edx,edi
	mov	[begin_offset],edx
;        add     edx,edi
	sub	ebx,edx
	mov	edx,ebx
	shl	edx,1
	inc	edx
	mov	[cursor],edx
	jmp	.end
 .abs:	mov	esi,[screen_table]
	mov	esi,[esi]
	xor	ebx,ebx
  .3:	add	ebx,esi
	cmp	eax,ebx
	jg	.3
	sub	ebx,esi
	cmp	ebx,[file_size]
	jg	Ctrl_G
	mov	[begin_offset],ebx
	sub	eax,ebx
	shl	eax,1
	inc	eax
	mov	[cursor],eax
  .end:
	mcall	13,180*65536+220,25*65536+70,frgrd_color
jmp	red


Ctrl_F:
	bts	[flags],3
	mov	eax,edit3
	call	draw_ed_box
	btr	[flags],3
	mov	ecx,[edit3.size]
	test	ecx,ecx
	jz	.end
	cmp	ecx,8
	jg	Ctrl_F
	mov	edi,find_string
	mov	esi,hex8_string
	mov	edx,[option_group2]
	cmp	edx,op11
	jne	.find
	mov	eax,find_string
	push	dword [eax]
	push	dword [eax+4]
	bts	[flags],0
  @@:	mov	ah,[edi+ecx-1]	;обработка введённых символов
	sub	ah,48
	cmp	ah,9
	jbe	.1
	sub	ah,7
	cmp	ah,15
	jbe	.1
	sub	ah,32
    .1: mov	[esi+ecx-1],ah
	loop	@b
	mov	ecx,[edit3.size]
	xor	eax,eax
    .2: shl	eax,4
	or	al,[esi]
	inc	esi
	dec	ecx
	jnz	.2
	mov	ecx,[edit3.size]
	bt	cx,0
	jnc	.3
	inc	ecx
	shl	eax,4
    .3: shr	ecx,1
    .4: mov	[edi+ecx-1],al
	shr	eax,8
	loop	.4

  .find:
;        mov     edi,find_string
	mov	esi,[current_offset]
	mov	ebx,[file_size]
	mov	eax,ebx
	add	eax,[file_buffer]
	add	esi,[file_buffer]
    .5: mov	ecx,[edit3.size]
	cmp	edx,op11
	jne	.7
	bt	cx,0
	jnc	.6
	inc	ecx
    .6: shr	ecx,1
    .7: cld
  @@:	cmp	esi,eax
	jg	.end
	cmpsb
	je     .8
	mov	edi,find_string
	jmp	.5
    .8: loop	@b
;        cmp     edi,eax
;        jg      .end
	sub	esi,[file_buffer]
	mov	ecx,[edit3.size]
	cmp	edx,op11
	jne	.10
	bt	cx,0
	jnc	.9
	inc	ecx
    .9: shr	ecx,1
    .10:sub	esi,ecx
	xor	edx,edx
	mov	edi,[screen_table]
	mov	edi,[edi]
  @@:	add	edx,edi
	cmp	edx,esi
	jb	@b
	sub	edx,edi
	mov	[begin_offset],edx
	sub	esi,edx
	shl	esi,1
	inc	esi
	mov	[cursor],esi
  .end:
	bt	[flags],0
	jnc	@f
	mov	eax,find_string
	pop	dword [eax+4]
	pop	dword [eax]
	btr	[flags],0
  @@:	mcall	13,180*65536+220,25*65536+70,frgrd_color
jmp	red

invert_byte:
	mov	ebx,[current_offset]
	add	ebx,[file_buffer]
	not	byte [ebx]
jmp	red


Insert: 			;переключение режима вставки/замены
	btc	[flags],1	;not    [insert_mod]
	call	show_insert
jmp	red


DEL:
	bt	[flags],1
	jnc	still
	mov	edi,[current_offset]
	mov	esi,[file_buffer]
	mov	edx,[file_size]
	test	edx,edx
	jz	still
	dec	edx
	cmp	edi,edx
	jbe	@f
	call	LEFT
	call	LEFT
	jmp	red
  @@:	jb	@f
	call	LEFT
	call	LEFT
  @@:
	cmp	edi,edx
	je	@f
	mov	al,[edi+esi+1]
	mov	[edi+esi],al
	inc	edi
	jmp	@b
  @@:
	dec	[file_size]
	call	show_file_size
jmp	red


BackSpace:
	bt	[flags],1	;cmp    [insert_mod],0
	jnc	still		;je     still
	mov	edi,[current_offset]
	mov	esi,[file_buffer]
	mov	edx,[file_size]
	test	edx,edx
	jz	still
	test	edi,edi
	jz	still
	call	LEFT
	call	LEFT
	cmp	[cursor],2
	jne	@f
	cmp	edx,1
	jne	@f
	dec	[cursor]
  @@:	cmp	edi,edx
	jge	 @f
	mov	al,[edi+esi]
	mov	[edi+esi-1],al
	inc	edi
	jmp	@b
  @@:	dec	[file_size]
	call	show_file_size
jmp	red


Ctrl_UP:
	cmp	[begin_offset],0
	je	@f
	mov	eax,[number_columns]
	sub	[begin_offset],eax
  @@:
ret


Ctrl_DOWN:
	mov	eax,[cursor]
	dec	eax
	shr	eax,1
	add	eax,[begin_offset]
	mov	ebx,[number_columns]
	add	eax,ebx
	cmp	eax,[file_size]
	jge	@f
	add	[begin_offset],ebx
  @@:
ret


UP:
	mov	eax,[current_offset]
	cmp	eax,[number_columns]
	jb	still
	mov	eax,[cursor]
	dec	ax
	shr	ax,1
	cmp	eax,[number_columns]
	jge	@f
	mov	eax,[number_columns]
	sub	[begin_offset],eax
	jmp	red
   @@:	mov	eax,[number_columns]
	shl	ax,1
	sub	[cursor],eax
jmp	red


DOWN:					;на строку вниз
	mov	eax,[current_offset]
	add	eax,[number_columns]
	bt	[flags],1
	jnc	@f
	dec	eax
  @@:	cmp	eax,[file_size]
	jge	still			;если мы на последней строке файла, то стоп
	mov	eax,[screen_table]
	mov	eax,[eax]
	mov	edx,[cursor]
	dec	dx
	shr	dx,1
	add	edx,[number_columns]
	cmp	eax,edx 		;на последней строке?
	jbe	@f
	mov	eax,[number_columns]
	shl	ax,1
	add	[cursor],eax
	ret
  @@:	mov	eax,[number_columns]
	add	[begin_offset],eax
ret;jmp     red


LEFT:
	cmp	[cursor],1
	jbe	@f
	dec	[cursor]
	jmp	.end
  @@:
	cmp	[begin_offset],0 ;курсор на первой строке со смещением 0?
	jne	@f		;иначе смещаем с прокруткой вверх вверх и в конец строки
;        inc     [cursor]
	jmp	.end;still           ;тогда стоп
  @@:	mov	eax,[number_columns]
	sub	[begin_offset],eax
	shl	ax,1
	dec	eax
	add	[cursor],eax
 .end:
ret


RIGHT:
	mov	ecx,[begin_offset]	;вычисляем смещение курсора
	mov	edx,[cursor]		;для проверки существования
	shr	edx,1			;следующего символа
	add	ecx,edx
	bt	[flags],1
	jnc	@f
	dec	ecx			;сравниваем с размером файла
  @@:	cmp	ecx,[file_size] 	;положением курсора - не далее 1 байта от конца файла
	jge	red
	cmp	[file_size],0
	je	still
	mov	eax,[screen_table]
	mov	eax,[eax]
	mov	ecx,[begin_offset]
	cmp	eax,edx 		;сравнение на нижнюю строку
	jbe	@f
	inc	[cursor]		;курсор вправо
	jmp	red
  @@:	mov	ecx,[number_columns]	;смещаемся на строчку вниз
	add	[begin_offset],ecx	;с прокруткой
	shl	cx,1
	dec	cx
	sub	[cursor],ecx
jmp	red


PGDN:
	mov	edi,[screen_table]
	mov	eax,[edi]
	shl	eax,1
	add	eax,[begin_offset]
	cmp	eax,[file_size] 	;есть ли возможность сместиться на страницу?
	jg	Ctrl_END
	mov	eax,[edi]
	add	[begin_offset],eax
;        mov     ebx,[cursor]
;        dec     ebx
;        xor     ecx,ecx
;        bt      ebx,0
;        jnc     @f
;        inc     ecx
;  @@:   shr     ebx,1
;        add     ebx,eax
;  @@:   cmp     ebx,[file_size]
;        jbe     @f
;        sub     ebx,[number_columns]
;        jmp     @b
;  @@:   sub     ebx,eax
;        shl     ebx,1
;        inc     ebx
;        add     ebx,ecx
;        mov     [cursor],ebx
jmp	red


PGUP:
	mov	eax,[screen_table]
	mov	eax,[eax]
	mov	edx,[begin_offset]
	cmp	eax,edx
	jbe	@f
	call	Ctrl_HOME
	jmp	red
   @@:	sub	[begin_offset],eax
jmp	red


HOME:
	mov	eax,[cursor]
	dec	ax
	shr	ax,1
	mov	ecx,[number_columns]
	xor	edx,edx
	div	ecx
	shl	dx,1
	sub	[cursor],edx
	bt	[cursor],0
	jc	@f
	dec	[cursor]
  @@:
ret


END_:
	mov	eax,[cursor]
	dec	ax
	shr	ax,1
	mov	ecx,[number_columns]
	xor	edx,edx
	div	ecx
	mov	eax,[current_offset]
	sub	eax,edx
	add	eax,[number_columns]
	mov	edx,[file_size]
	cmp	eax,edx
	jbe	@f
	sub	edx,eax
	add	eax,edx
  @@:	sub	eax,[begin_offset]
	shl	eax,1
	test	eax,eax
	jz	red
	dec	eax
	mov	[cursor],eax
jmp red


Ctrl_HOME:
	mov	[begin_offset],0
	mov	[cursor],1
ret


Ctrl_END:
	mov	eax,[file_size]
	mov	ecx,[screen_table]
	mov	ecx,[ecx]
	xor	edx,edx
	div	ecx
	test	dx,dx
	jnz	@f
	test	eax,eax
	jz	@f
	mov	edx,ecx
	dec	eax
  @@:	push	dx
	xor	dx,dx
	mul	ecx
	pop	dx
	shl	edx,1
	cmp	edx,1
	jg	@f
	mov	edx,2
  @@:	dec	edx
	mov	[begin_offset],eax
	mov	[cursor],edx
jmp  red

;---------------------------------------------------------
;----------------------- DATA AREA------------------------
;---------------------------------------------------------
align 4
myimport:
edit_box_draw	dd	aEdit_box_draw
edit_box_key	dd	aEdit_box_key
edit_box_mouse	dd	aEdit_box_mouse
version_ed	dd	aVersion_ed

option_box_draw  dd	 aOption_box_draw
option_box_mouse dd	 aOption_box_mouse
version_op	 dd	 aVersion_op

scrollbar_ver_draw	dd aScrollbar_ver_draw
scrollbar_ver_mouse	dd aScrollbar_ver_mouse
version_scrollbar	dd aVersion_scrollbar

menu_bar_draw		dd	aMenu_bar_draw
menu_bar_mouse		dd	aMenu_bar_mouse
version_menu_bar	dd	aVersion_menu_bar

		dd	0
		dd	0

aEdit_box_draw	db 'edit_box',0
aEdit_box_key	db 'edit_box_key',0
aEdit_box_mouse db 'edit_box_mouse',0
aVersion_ed	db 'version_ed',0

aOption_box_draw  db 'option_box_draw',0
aOption_box_mouse db 'option_box_mouse',0
aVersion_op	  db 'version_op',0

aScrollbar_ver_draw	db 'scrollbar_v_draw',0
aScrollbar_ver_mouse	db 'scrollbar_v_mouse',0
aVersion_scrollbar	db 'version_scrollbar',0

aMenu_bar_draw		db 'menu_bar_draw',0
aMenu_bar_mouse 	db 'menu_bar_mouse',0
aVersion_menu_bar	db 'version_menu_bar',0

align 4
scroll_bar_data_vertical:
.x:
.size_x     dw 15 ;+0
.start_x    dw 565 ;+2
.y:
.size_y     dw 284 ;+4
.start_y    dw 19 ;+6
.btn_high   dd 10 ;+8
.type	    dd 1  ;+12
.max_area   dd 300  ;+16
.cur_area   dd 20  ;+20
.position   dd 0  ;+24
.bckg_col   dd 0xAAAAAA ;+28
.frnt_col   dd 0xCCCCCC ;+32
.line_col   dd 0  ;+36
.redraw     dd 0  ;+40
.delta	    dw 0  ;+44
.delta2     dw 0  ;+46
.run_x:
.r_size_x   dw 0  ;+48
.r_start_x  dw 0  ;+50
.run_y:
.r_size_y   dw 0 ;+52
.r_start_y  dw 0 ;+54
.m_pos	    dd 0 ;+56
.m_pos_2    dd 0 ;+60
.m_keys     dd 0 ;+64
.run_size   dd 0 ;+68
.position2  dd 0 ;+72
.work_size  dd 0 ;+76
.all_redraw dd 0 ;+80
.ar_offset	dd 10 ;+84


align 4
menu_data_1:
.type:			dd 0   ;+0
.x:
.size_x 		dw 40  ;+4
.start_x		dw 2	;+6
.y:
.size_y 		dw 15	;+8
.start_y		dw 2  ;+10
.text_pointer:	dd menu_text_area  ;0 ;+12
.pos_pointer:	dd menu_text_area.1 ;0 ;+16
.text_end		dd menu_text_area.end ;0 ;+20
.mouse_pos		dd 0  ;+24
.mouse_keys		dd 0  ;+28
.x1:
.size_x1		dw 40  ;+32
.start_x1		dw 2	;+34
.y1:
.size_y1		dw 100	 ;+36
.start_y1		dw 18  ;+38
.bckg_col	dd 0xeeeeee ;+40
.frnt_col	dd 0xff ;+44
.menu_col	dd 0xffffff ;+48
.select 	dd 0 ;+52
.out_select	dd 0 ;+56
.buf_adress		dd 0 ;+60
.procinfo		dd 0 ;+64
.click			dd 0 ;+68
.cursor 		dd 0 ;+72
.cursor_old		dd 0 ;+76
.interval		dd 16 ;+80
.cursor_max		dd 0 ;+84
.extended_key	dd 0 ;+88
.menu_sel_col	dd 0x00cc00 ;+92
.bckg_text_col	dd 0 ; +96
.frnt_text_col	dd 0xffffff ;+100
.mouse_keys_old dd 0 ;+104
.font_height	dd 8 ;+108
.cursor_out		dd 0 ;+112
.get_mouse_flag dd 0 ;+116

menu_text_area:
db 'File',0
.1:
db 'Open',0
db 'Save',0
db 'Exit',0
.end:
db 0

align 4
menu_data_2:
.type:			dd 0   ;+0
.x:
.size_x 		dw 40  ;+4
.start_x		dw 43	;+6
.y:
.size_y 		dw 15	;+8
.start_y		dw 2  ;+10
.text_pointer:	dd menu_text_area_2  ;0 ;+12
.pos_pointer:	dd menu_text_area_2.1 ;0 ;+16
.text_end		dd menu_text_area_2.end ;0 ;+20
.mouse_pos		dd 0  ;+24
.mouse_keys		dd 0  ;+28
.x1:
.size_x1		dw 50  ;+32
.start_x1		dw 43	;+34
.y1:
.size_y1		dw 100	 ;+36
.start_y1		dw 18  ;+38
.bckg_col	dd 0xeeeeee ;+40
.frnt_col	dd 0xff ;+44
.menu_col	dd 0xffffff ;+48
.select 	dd 0 ;+52
.out_select	dd 0 ;+56
.buf_adress		dd 0 ;+60
.procinfo		dd 0 ;+64
.click			dd 0 ;+68
.cursor 		dd 0 ;+72
.cursor_old		dd 0 ;+76
.interval		dd 16 ;+80
.cursor_max		dd 0 ;+84
.extended_key	dd 0 ;+88
.menu_sel_col	dd 0x00cc00 ;+92
.bckg_text_col	dd 0 ; +96
.frnt_text_col	dd 0xffffff ;+100
.mouse_keys_old dd 0 ;+104
.font_height	dd 8 ;+108
.cursor_out		dd 0 ;+112
.get_mouse_flag dd 0 ;+116

menu_text_area_2:
db 'View',0
.1:
db 'Add 4',0
db 'Add 8',0
db 'Sub 4',0
db 'Sub 8',0
.end:
db 0


align 4
menu_data_3:
.type:			dd 0   ;+0
.x:
.size_x 		dw 40  ;+4
.start_x		dw 84	 ;+6
.y:
.size_y 		dw 15	;+8
.start_y		dw 2  ;+10
.text_pointer:	dd menu_text_area_3  ;0 ;+12
.pos_pointer:	dd menu_text_area_3.1 ;0 ;+16
.text_end		dd menu_text_area_3.end ;0 ;+20
.mouse_pos		dd 0  ;+24
.mouse_keys		dd 0  ;+28
.x1:
.size_x1		dw 40  ;+32
.start_x1		dw 84	 ;+34
.y1:
.size_y1		dw 100	 ;+36
.start_y1		dw 18  ;+38
.bckg_col	dd 0xeeeeee ;+40
.frnt_col	dd 0xff ;+44
.menu_col	dd 0xffffff ;+48
.select 	dd 0 ;+52
.out_select	dd 0 ;+56
.buf_adress		dd 0 ;+60
.procinfo		dd 0 ;+64
.click			dd 0 ;+68
.cursor 		dd 0 ;+72
.cursor_old		dd 0 ;+76
.interval		dd 16 ;+80
.cursor_max		dd 0 ;+84
.extended_key	dd 0 ;+88
.menu_sel_col	dd 0x00cc00 ;+92
.bckg_text_col	dd 0 ; +96
.frnt_text_col	dd 0xffffff ;+100
.mouse_keys_old dd 0 ;+104
.font_height	dd 8 ;+108
.cursor_out		dd 0 ;+112
.get_mouse_flag dd 0 ;+116

menu_text_area_3:
db 'Help',0
.1:
db 'Help',0
.end:
db 0

;---------------------------------------------------------------------
edit1 edit_box 200,190,27,0xffffff,0x6a9480,0,0xAABBCC,0,134,file_name,ed_focus,6,6
edit2 edit_box 55,260,29,0xeeeeee,0x6a9480,0,0xAABBCC,4,8,go_to_string,ed_focus,0,0
edit3 edit_box 55,260,29,0xeeeeee,0x6a9480,0,0xAABBCC,4,8,find_string,ed_focus,0,0

op1 option_box option_group1,210,50,6,12,0xffffff,0,0,op_text.1,op_text.e1-op_text.1,1
op2 option_box option_group1,310,50,6,12,0xFFFFFF,0,0,op_text.2,op_text.e2-op_text.2
op3 option_box option_group1,210,65,6,12,0xffffff,0,0,op_text.3,op_text.e3-op_text.3
op11 option_box option_group2,210,50,6,12,0xffffff,0,0,op_text2.11,op_text2.e11-op_text2.11
op12 option_box option_group2,310,50,6,12,0xffffff,0,0,op_text2.21,op_text2.e21-op_text2.21

option_group1	dd op1	;указатели, они отображаются по умолчанию, когда выводится
option_group2	dd op11 ;приложение
Option_boxs	dd  op1,op2,op3,0
Option_boxs2	dd  op11,op12,0

op_text:		; Сопровождающий текст для чек боксов
.1 db 'Absolutely'
.e1:
.2 db 'Forward'
.e2:
.3 db 'Back'
.e3:

op_text2:
.11 db 'Hex'
.e11:
.21 db 'ASCII'
.e21:


system_path db '/sys/lib/'
boxlib_name db 'box_lib.obj',0

head_f_i:
head_f_l	db 'error',0
err_message_found_lib	db 'box_lib.obj was not found',0
err_message_import	db 'box_lib.obj was not imported',0


title		db	'HeEd 0.11  '
file_name	db	'/rd/1/',0
file_buf: times 260-($-file_name) db (0)

help_but_text	= menu_text_area_3 ;db      'Help',0
error_open_file_string db "Isn't found!",0
error_save_file_string db "Isn't saved!",0
string_cp866	db	' cp866'
string_cp1251	db	'cp1251'
string_koi8r	db	'koi8-r'
string_ins	db	'Ins'


align 4
number_strings	dd	16		;количество строк на листе
number_columns	dd	16		;кол-во столбцов

palitra 	dd	frgrd_color,bkgrd_color ;цвет невыделенного символа
palitra2	dd	frgrd_color,text_color ;левый,правый столбцы,часть нижней строки
palitra3	dd	kursred_color,frgrd_color ;курсора
palitra4	dd	kurstxt_color,bkgrd_color ;курсора в текстовой области
palitra5	dd	frgrd_color,not text_color

;blocks_counter dd      1
;blocks_table   dd      0
cursor		dd	1

flags		dw	001000010b
;бит 0: в edit_box - восприятие/(не) всех вводимых символов
;1: 0/1 - режим замены/вставки
;2: в edit_box - обработка Ctrl_G
;3: в edit_box - обработка Ctrl_F
;4: в change_codepage - если поднят, то восстановить предыдущую кодировку
;5: см. mouse:
;6: полная перерисовка окна


func_70     f70

help_text:
if lang eq ru
 db 'Ctrl+O              - открыть файл                 '
 db 'Ctrl+S              - сохранить                    '
 db 'PageUp, PageDown    - страница вверх/вниз          '
 db 'Ctrl+UP, Ctrl+Down  - прокрутка страницы на стро-  '
 db '                 ку вверх/вниз без смещения курсора'
 db 'Home,End            - в начало/конец строки        '
 db 'Ctrl+Home, Ctrl+End - в начало/конец файла         '
 db 'Left, Right         - курсор влево/вправо          '
 db 'n                   - инвертировать байт           '
 db 'Ins                 - режим замены/вставки         '
 db '  Del               - удалить байт под курсором    '
 db '  BackSpace         - удалить байт перед курсором  '
 db '~                   - смена кодировок cp866,cp1251 '
 db 'Shift+~             - cp866/cp1251,koi8r           '
 db 'Ctrl+F              - поиск                        '
 db 'Ctrl+G              - переход на смещение          '
else
 db 'Ctrl+O              - open file                    '
 db 'Ctrl+S              - save file                    '
 db 'PageUp, PageDown    - page up/down                 '
 db 'Ctrl+UP, Ctrl+Down  - scroll page by one string    '
 db '                    up/down without cursor movement'
 db 'Home,End            - at the start/end of string   '
 db 'Ctrl+Home, Ctrl+End - at the start/end of file     '
 db 'Left, Right         - move cursor to the lft/rght  '
 db 'n                   - invert byte                  '
 db 'Ins                 - replace/past mode            '
 db '  Del               - delete byte under cursor     '
 db '  BackSpace         - delete byte before cursor    '
 db '~                   - change codepages cp866,cp1251'
 db 'Shift+~             - cp866/cp1251,koi8r           '
 db 'Ctrl+F              - find                         '
 db 'Ctrl+G              - go to offset                 '
end if
help_end:


;align 4096
font_buffer	file	'cp866-8x16'	;ASCII+cp866 (+Ё,ё)
cp1251		file	'cp1251-8x16'
koi8_r		file	'koi8-r-8x16'

I_END:
cur_dir_path	rb 4096
buf_cmd_lin	rb 0
threath_buf	rb 0x400

screen_table	rd	1
begin_offset	rd	1
file_buffer	rd	1
current_offset	rd	1
;               rd      1       ;под старший dword
codepage_offset rd	1
codepage_offset_previous rd 1
low_area	rd	1	;координаты нижней строки
right_table_xy	rd	1

mouse_flag	rd	1
file_size	rd	1
;               rd      1       ;под старший dword

hex8_string	rb 8	;буфер для hex_output
bufferfinfo	rb 40
go_to_string	rb 8
find_string	rb 16
nmbr_help_string rb 1	;номер строки, с которой выводится текст в help - окне


D_END:



; ADC приемник, источник ; Сложение с переносом

;Эта команда во всем аналогична ADD, кроме того, что она выполняет арифметическое сложение приемника, источника и флага СF. Пара команд ADD/ADC используется для сложения чисел повышенной точности. Сложим, например, два 64-битных целых числа: пусть одно из них находится в паре регистров EDX:EAX (младшее двойное слово (биты 0 - 31) - в ЕАХ и старшее (биты 32 - 63) - в EDX), а другое - в паре регистров ЕВХ:ЕСХ:

 ;   add      eax,ecx
 ;   adc      edx,ebx

;Если при сложении младших двойных слов произошел перенос из старшего разряда (флаг CF = 1), то он будет учтен следующей командой ADC.





; SBB приемник, источник ; Вычитание с займом

;Эта команда во всем аналогична SUB, кроме того, что она вычитает из приемника значение источника и дополнительно вычитает значение флага CF. Так, можно использовать эту команду для вычитания 64-битных чисел в EDX:EAX и ЕВХ:ЕСХ аналогично ADD/ADC:

 ;   sub      eax,ecx
 ;   sbb      edx,ebx

