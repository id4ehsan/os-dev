; kpack = Kolibri Packer
; Kolibri version
; Written by diamond in 2006, 2007 specially for KolibriOS

; Uses LZMA compression library by Igor Pavlov
; (for more information on LZMA and 7-Zip visit http://www.7-zip.org)
; (plain-C packer and ASM unpacker are ported by diamond)

	.486
	.model flat
lzma_compress equ _lzma_compress@16
lzma_set_dict_size equ _lzma_set_dict_size@4
lzma_decompress equ _lzma_decompress@12
extrn lzma_compress:proc
extrn lzma_set_dict_size:proc
extrn lzma_decompress:proc
.data
	db	'MENUET01'
	dd	1
	dd	offset _start
	dd	offset bss_start	; i_end
memf	dd	offset bss_end		; memory
	dd	offset bss_end		; esp
	dd	offset params		; params
	dd	0		; icon

caption_str	db	'KPack',0
buttons1names	db	' InFile:'
		db	'OutFile:'
		db	'   Path:'
aCompress	db	'COMPRESS',0
aDecompress	db	'DECOMPRESS',0
definoutname	db	0
defpath		db	'/RD/1/'
curedit		dd	0

info_str	db	'KPack - Kolibri Packer, version 0.13',10
		db	'Uses LZMA v4.32 compression library',10,10
info_len	=	$ - offset info_str
usage_str	db	'Written by diamond in 2006, 2007, 2009 specially for KolibriOS',10
		db	'LZMA  is copyright (c) 1999-2005 by Igor Pavlov',10
		db	10
		db	'Command-line usage:',10
		db	' kpack infile [outfile]',10
		db	'If no output file is specified,',10
		db	'    packed data will be written back to input file',10
		db	10
		db	'Window usage:',10
		db	" enter input file name, output file name and press needed button",10
usage_len	=	$ - usage_str
errload_str	db	'Cannot load input file',10
errload_len	=	$ - offset errload_str
outfileerr_str	db	'Cannot save output file',10
outfileerr_len	=	$ - offset outfileerr_str
nomem_str	db	'No memory',10
nomem_len	=	$ - offset nomem_str
too_big_str	db	'failed, output is greater than input.',10
too_big_len	=	$ - too_big_str
compressing_str	db	'Compressing ... '
compressing_len = $ - compressing_str
lzma_memsmall_str db	'Warning: not enough memory for default LZMA settings,',10
		db	'         will use less dictionary size',10
lzma_memsmall_len = $ - lzma_memsmall_str
notpacked_str	db	'Input file is not packed with KPack!',10
notpacked_len	=	$ - notpacked_str
unpacked_ok	db	'Unpacked successful',10
unpacked_len	=	$ - unpacked_ok

done_str	db	'OK! Compression ratio: '
ratio		dw	'00'
		db	'%',10
done_len	=	$ - done_str

.data?
bss_start label byte

params	db	256 dup (?)

color_table dd	10 dup (?)
skinheight dd	?

innamelen dd	?
inname	db	48 dup (?)
outnamelen dd	?
outname	db	48 dup (?)
pathlen dd	?
path	db	48 dup (?)

curedit_y	dd	?

message_mem	db	80*20 dup (?)
message_cur_pos	dd	?

outsize		dd	?
infile		dd	?
outfile		dd	?
outfile1	dd	?
outfile2	dd	?
outfilebest	dd	?
inbuftmp	dd	?
workmem		dd	?
lzma_dictsize	dd	?
ct1		db	256 dup (?)
ctn		dd	?
cti		db	?
use_lzma	=	1

use_no_calltrick =	0
use_calltrick1	=	40h
use_calltrick2	=	80h

method			db	?

fn70block label byte
fn70op	dd	?
fn70start dd	?
fn70size dd	?
fn70zero dd	?
fn70dest dd	?
fullname db	100 dup (?)

align 4

file_attr       dd      8 dup (?)
insize          dd      ?       ; last qword in file_attr
                dd      ?

mtstack	db	1000h dup (?)
bss_end label byte

.code

clear_messages:
	xor	eax, eax
	mov	ecx, 80*20/4+1
	mov	edi, offset message_mem
	rep	stosd
	ret

_start:
	call	clear_messages
; set default path = /RD/1/
	mov	esi, offset defpath
	mov	edi, offset path
	mov	dword ptr [edi-4], 6
	movsw
	movsd
; get system window info
	mov	al, 48
	push	3
	pop	ebx
	mov	ecx, offset color_table
	push	40
	pop	edx
	int	40h
	inc	ebx
	int	40h
	mov	[skinheight], eax
; check command line
	mov	esi, offset params
	mov	byte ptr [esi+100h], 0
parse_opt:
	call	skip_spaces
	test	al, al
	jz	short default
	mov	edi, offset inname
	call	copy_name
	test	al, al
	jz	short outeqin
	mov	edi, offset outname
	call	copy_name
	test	al, al
	jnz	short default
doit:
	call	draw_window
	call	pack
	jmp	waitevent
exit:
	xor	eax, eax
	dec	eax
	int	40h
outeqin:
	mov	ecx, 48/4+1
	mov	esi, offset inname-4
	mov	edi, offset outname-4
	rep	movsd
	jmp	short doit
default:
	mov	[curedit], offset inname
	mov	ecx, [skinheight]
	add	ecx, 5
	mov	[curedit_y], ecx
	mov	esi, offset definoutname
	mov	edi, esi
	xor	ecx, ecx
	xor	eax, eax
	dec	ecx
	repnz	scasb
	not	ecx
	dec	ecx
	mov	[innamelen], ecx
	push	ecx
	push	esi
	mov	edi, offset inname
	rep	movsb
	pop	esi
	pop	ecx
	mov	[outnamelen], ecx
	mov	edi, offset outname
	rep	movsb
dodraw:
	call	draw_window
waitevent:
	push	10
	pop	eax
	int	40h
	dec	eax
	jz	short dodraw
	dec	eax
	jz	keypressed
	dec	eax
	jnz	short waitevent
; button pressed
	mov	al, 17
	int	40h
	xchg	al, ah
	cmp	al, 7
	jz	short but7
	dec	eax
	jz	exit
	dec	eax
	jnz	short nopack
	call	pack
	jmp	short waitevent
nopack:
	dec	eax
	jnz	short nounpack
	call	unpack
	jmp	short waitevent
but7:
	call	clear_messages
; display logo
	mov	esi, offset info_str
	push	info_len
	pop	ecx
	call	write_string
; display info
	mov	esi, offset usage_str
	mov	ecx, usage_len
	call	write_string
	jmp	short waitevent
nounpack:
; this is infile/outfile/path button
	call	clear_edit_points
	mov	esi, offset inname
	mov	ecx, [skinheight]
	add	ecx, 5
	dec	eax
	jz	short edit
	mov	esi, offset outname
	add	ecx, 0Ch
	dec	eax
	jz	short edit
	mov	esi, offset path
	add	ecx, 0Ch
edit:
	cmp	esi, [curedit]
	mov	[curedit], 0
	jz	waitevent
	mov	[curedit], esi
	mov	[curedit_y], ecx
	mov	al, 1
	mov	ebx, [esi-4]
	mov	edi, ebx
	imul	ebx, 6
	add	ebx, 42h
	add	ecx, 4
	xor	edx, edx
@@:
	cmp	edi, 48
	jz	waitevent
	int	40h
	add	ebx, 6
	inc	edi
	jmp	@b
keypressed:
	mov	al, 2
	int	40h
	xchg	al, ah
	mov	edi, [curedit]
	test	edi, edi
	jz	waitevent
	mov	ebx, [edi-4]
	cmp	al, 8
	jz	short backspace
	cmp	al, 13
	jz	onenter
	cmp	al, 20h
	jb	waitevent
	cmp	ebx, 48
	jz	waitevent
	mov	[edi+ebx], al
	inc	ebx
	mov	[edi-4], ebx
; clear point and draw symbol
	lea	edi, [ebx+edi-1]
	imul	ebx, 6
	add	ebx, 40h-6
	shl	ebx, 16
	mov	al, 13
	mov	bl, 6
	mov	ecx, [curedit_y]
	push	ecx
	shl	ecx, 16
	mov	cl, 9
	mov	edx, [color_table+20]
	int	40h
	pop	ecx
	mov	bx, cx
	mov	edx, edi
	push	1
	pop	esi
	mov	ecx, [color_table+32]
	mov	al, 4
	int	40h
	jmp	waitevent
backspace:
	test	ebx, ebx
	jz	waitevent
	dec	ebx
	mov	[edi-4], ebx
; clear symbol and set point
	imul	ebx, 6
	add	ebx, 40h
	shl	ebx, 16
	mov	al, 13
	mov	bl, 6
	mov	ecx, [curedit_y]
	push	ecx
	shl	ecx, 16
	mov	cl, 9
	mov	edx, [color_table+20]
	int	40h
	xor	edx, edx
	shr	ebx, 16
	inc	ebx
	inc	ebx
	pop	ecx
	add	ecx, 4
	mov	al, 1
	int	40h
	jmp	waitevent
onenter:
	cmp	[curedit], offset inname
	jnz	short @f
	push	2
	pop	eax
	jmp	nounpack
@@:	cmp	[curedit], offset outname
	jnz	short @f
	call	pack
	jmp	waitevent
@@:	call	clear_edit_points
	jmp	waitevent

pack:
	call	clear_edit_points
	and	[curedit], 0
; clear messages
	call	clear_messages
; display logo
	mov	esi, offset info_str
	push	info_len
	pop	ecx
	call	write_string
; load input file
	mov	esi, offset inname
	call	get_full_name
	mov	ebx, offset fn70block
	mov	dword ptr [ebx], 5
	and	dword ptr [ebx+4], 0
	and	dword ptr [ebx+8], 0
	and     dword ptr [ebx+12], 0
	mov	dword ptr [ebx+16], offset file_attr
	push	70
	pop	eax
	int	40h
	test	eax, eax
	jz	short inopened
infileerr:
	mov	esi, offset errload_str
	push	errload_len
	pop	ecx
	jmp	write_string
inopened:
        mov     ebx, [insize]
        test    ebx, ebx
        jz      short infileerr
; maximum memory requests: 2*insize + 2*(maxoutsize+400h) + worksize
	mov	esi, [memf]
	mov	[infile], esi
	add	esi, ebx
	mov	[inbuftmp], esi
	add	esi, ebx
	mov	[outfile], esi
	mov	[outfile1], esi
	mov	[outfilebest], esi
	mov	ecx, ebx
	shr	ecx, 3
	add	ecx, ebx
	add	ecx, 400h
	add	esi, ecx
	mov	[outfile2], esi
	add	esi, ecx
	mov	[workmem], esi
	add	ecx, ebx
	add	ecx, ecx
	add	ecx, [memf]
; LZMA requires 0x448000 + dictsize*9.5 bytes for workmem,
	and	[lzma_dictsize], 0
	push	ecx
	mov	eax, ebx
	dec	eax
	bsr	ecx, eax
	inc	ecx
	cmp	ecx, 28
	jb	short @f
	mov	cl, 28
@@:
	mov	edx, ecx
	xor	eax, eax
	inc	eax
	shl	eax, cl
	imul	eax, 19
	shr	eax, 1
	add	eax, 448000h
	pop	ecx
	add	ecx, eax
	push	64
	pop	eax
	push	1
	pop	ebx
	int	40h
	test	eax, eax
	jz	short mem_ok
; try to use smaller dictionary
meml0:
	cmp	edx, 4
	jbe	short memf1
	dec	edx
	xor	eax, eax
	inc	eax
	mov	ecx, edx
	shl	eax, cl
	imul	eax, 19
	shr	eax, 1
	add	eax, 509000h
	pop	ecx
	push	ecx
	add	ecx, eax
	push	64
	pop	eax
	int	40h
	test	eax, eax
	jnz	short meml0
; ok, say warning and continue
	mov	[lzma_dictsize], edx
	mov	esi, offset lzma_memsmall_str
	push	lzma_memsmall_len
	pop	ecx
	call	write_string
	jmp	short mem_ok
memf1:
	mov	esi, offset nomem_str
	push	nomem_len
	pop	ecx
	jmp	write_string
mem_ok:
	mov	eax, [insize]
	mov	ebx, offset fn70block
	mov     byte ptr [ebx], 0
	mov	[ebx+12], eax
	mov	esi, [infile]
	mov	[ebx+16], esi
	push	70
	pop	eax
	int	40h
	test	eax, eax
	jnz	infileerr
	mov	eax, [outfile]
	mov	dword ptr [eax], 'KCPK'
	mov     ecx, [insize]
	mov	dword ptr [eax+4], ecx
	mov	edi, eax
; set LZMA dictionary size
	mov	eax, [lzma_dictsize]
	test	eax, eax
	js	short no_lzma_setds
	jnz	short lzma_setds
	mov	ecx, [insize]
	dec	ecx
	bsr	eax, ecx
	inc	eax
	cmp	eax, 28
	jb	short lzma_setds
	mov	eax, 28
lzma_setds:
	push	eax
	call	lzma_set_dict_size
no_lzma_setds:
	push	compressing_len
	pop	ecx
	mov	esi, offset compressing_str
	call	write_string
	mov	esi, [outfile1]
	mov     edi, [outfile2]
	movsd
	movsd
	movsd
	call	pack_lzma
	mov	[outsize], eax
	mov	eax, [outfile]
	mov	[outfilebest], eax
	mov	[method], use_lzma
@@:
	call	preprocess_calltrick
	test	eax, eax
	jz	short noct1
	call	set_outfile
	call	pack_lzma
	add	eax, 5
	cmp	eax, [outsize]
	jae	short @f
	mov	[outsize], eax
	mov	eax, [outfile]
	mov	[outfilebest], eax
	mov	[method], use_lzma or use_calltrick1
@@:
noct1:
	call	set_outfile
	push	[ctn]
	mov	al, [cti]
	push	eax
	call	preprocess_calltrick2
	test	eax, eax
	jz	noct2
	call	set_outfile
	call	pack_lzma
	add	eax, 5
	cmp	eax, [outsize]
	jae	short @f
	mov	[outsize], eax
	mov	eax, [outfile]
	mov	[outfilebest], eax
	mov	[method], use_lzma or use_calltrick2
	pop	ecx
	pop	ecx
	push	[ctn]
	mov	al, [cti]
	push	eax
@@:
noct2:
	pop	eax
	mov	[cti], al
	pop	[ctn]
	add     [outsize], 12
	mov     eax, [outsize]
	cmp	eax, [insize]
	jb	short packed_ok
	mov	esi, offset too_big_str
	push	too_big_len
	pop	ecx
	jmp	write_string
packed_ok:
; set header
        movzx   eax, [method]
	mov	edi, [outfilebest]
	mov     [edi+8], eax
	test    al, use_calltrick1 or use_calltrick2
	jz      short @f
	mov     ecx, [outsize]
	add     ecx, edi
	mov     eax, [ctn]
	mov     [ecx-5], eax
	mov     al, [cti]
	mov     [ecx-1], al
@@:
	mov	eax, [outsize]
	mov	ecx, 100
	mul	ecx
	div	[insize]
	aam
	xchg	al, ah
	add	ax, '00'
	mov	[ratio], ax
	mov	esi, offset done_str
	push	done_len
	pop	ecx
	call	write_string
; save output file
saveout:
	mov	esi, offset outname
	call	get_full_name
	mov	ebx, offset fn70block
	mov	byte ptr [ebx], 2
	mov	eax, [outfilebest]
	mov	ecx, [outsize]
	mov	[ebx+12], ecx
	mov	[ebx+16], eax
	push	70
	pop	eax
	int	40h
	test	eax, eax
	jz	short @f
outerr:
	mov	esi, offset outfileerr_str
	push	outfileerr_len
	pop	ecx
	jmp	write_string
@@:
	xor	eax, eax
	mov	ebx, offset fn70block
	mov	byte ptr [ebx], 6
	mov	[ebx+4], eax
	mov	[ebx+8], eax
	mov	[ebx+12], eax
	mov	dword ptr [ebx+16], offset file_attr
	mov	al, 70
	int	40h
	ret

set_outfile:
	mov	eax, [outfilebest]
	xor	eax, [outfile1]
	xor	eax, [outfile2]
	mov	[outfile], eax
	ret

pack_calltrick_fail:
	xor	eax, eax
	mov	[ctn], 0
	ret
preprocess_calltrick:
; input preprocessing
	xor	eax, eax
	mov	edi, offset ct1
	mov	ecx, 256/4
	push	edi
	rep	stosd
	pop	edi
	mov	ecx, [insize]
	mov	esi, [infile]
	xchg	eax, edx
	mov	ebx, [inbuftmp]
input_pre:
	lodsb
	sub	al, 0E8h
	cmp	al, 1
	ja	short input_pre_cont
	cmp	ecx, 5
	jb	short input_pre_done
	lodsd
	add	eax, esi
	sub	eax, [infile]
	cmp	eax, [insize]
	jae	short xxx
	cmp	eax, 1000000h
	jae	short xxx
	sub	ecx, 4
; bswap is not supported on i386
	xchg	al, ah
	ror	eax, 16
	xchg	al, ah
	mov	[esi-4], eax
	inc	edx
	mov	[ebx], esi
	add	ebx, 4
	jmp	short input_pre_cont
xxx:	sub	esi, 4
	movzx	eax, byte ptr [esi]
	mov	byte ptr [eax+edi], 1
input_pre_cont:
	loop	input_pre
input_pre_done:
	mov	[ctn], edx
	xor	eax, eax
	mov	ecx, 256
	repnz	scasb
	jnz	pack_calltrick_fail
	not	cl
	mov	[cti], cl
@@:
	cmp	ebx, [inbuftmp]
	jz	@f
	sub	ebx, 4
	mov	eax, [ebx]
	mov	[eax-4], cl
	jmp	@b
@@:
	mov	al, 1
	ret

pack_lzma:
        mov     eax, [outfile]
        add     eax, 11
	push	[workmem]
	push    [insize]
	push	eax
	push	[infile]
	call	lzma_compress
	mov	ecx, [outfile]
	mov	edx, [ecx+12]
	xchg	dl, dh
	ror	edx, 16
	xchg	dl, dh
	mov     [ecx+12], edx
	dec     eax
	ret

preprocess_calltrick2:
; restore input
	mov	esi, [infile]
	mov	ecx, [ctn]
	jecxz	pc2l2
pc2l1:
	lodsb
	sub	al, 0E8h
	cmp	al, 1
	ja	short pc2l1
	mov	al, [cti]
	cmp	[esi], al
	jnz	short pc2l1
	lodsd
	shr	ax, 8
	ror	eax, 16
	xchg	al, ah
	sub	eax, esi
	add	eax, [infile]
	mov	[esi-4], eax
	loop	pc2l1
pc2l2:
; input preprocessing
	mov	edi, offset ct1
	xor	eax, eax
	push	edi
	mov	ecx, 256/4
	rep	stosd
	pop	edi
	mov	ecx, [insize]
	mov	esi, [infile]
	mov	ebx, [inbuftmp]
	xchg	eax, edx
input_pre2:
	lodsb
@@:
	cmp	al, 0Fh
	jnz	short ip1
	dec	ecx
	jz	short input_pre_done2
	lodsb
	cmp	al, 80h
	jb	short @b
	cmp	al, 90h
	jb	short @f
ip1:
	sub	al, 0E8h
	cmp	al, 1
	ja	short input_pre_cont2
@@:
	cmp	ecx, 5
	jb	short input_pre_done2
	lodsd
	add	eax, esi
	sub	eax, [infile]
	cmp	eax, [insize]
	jae	short xxx2
	cmp	eax, 1000000h
	jae	short xxx2
	sub	ecx, 4
	xchg	al, ah
	rol	eax, 16
	xchg	al, ah
	mov	[esi-4], eax
	inc	edx
	mov	[ebx], esi
	add	ebx, 4
	jmp	short input_pre_cont2
xxx2:	sub	esi, 4
	movzx	eax, byte ptr [esi]
	mov	byte ptr [eax+edi], 1
input_pre_cont2:
	loop	input_pre2
input_pre_done2:
	mov	[ctn], edx
	xor	eax, eax
	mov	ecx, 256
	repnz	scasb
	jnz	pack_calltrick_fail
	not	cl
	mov	[cti], cl
@@:
	cmp	ebx, [inbuftmp]
	jz	short @f
	sub	ebx, 4
	mov	eax, [ebx]
	mov	[eax-4], cl
	jmp	short @b
@@:
	mov	al, 1
	ret

unpack:
	call	clear_edit_points
	and	[curedit], 0
; clear messages
	call	clear_messages
; display logo
	mov	esi, offset info_str
	push	info_len
	pop	ecx
	call	write_string
; load input file
	mov	esi, offset inname
	call	get_full_name
	mov	ebx, offset fn70block
	mov	dword ptr [ebx], 5
	and	dword ptr [ebx+4], 0
	and	dword ptr [ebx+8], 0
	and     dword ptr [ebx+12], 0
	mov	dword ptr [ebx+16], offset file_attr
	push	70
	pop	eax
	int	40h
	test	eax, eax
	jnz	infileerr
	mov	eax, [insize]
	test	eax, eax
        jz      infileerr
        mov	ecx, [memf]
        mov	[infile], ecx
        add	ecx, eax
        mov	[outfile], ecx
        mov	[outfilebest], ecx
        push	64
        pop	eax
        push	1
        pop	ebx
        int	40h
        test	eax, eax
        jnz	memf1
	mov	ebx, offset fn70block
	mov     byte ptr [ebx], 0
	mov	eax, [insize]
	mov	[ebx+12], eax
	mov	esi, [infile]
	mov	[ebx+16], esi
	push	70
	pop	eax
	int	40h
	test	eax, eax
	jnz	infileerr
	mov	eax, [infile]
	cmp	dword ptr [eax], 'KCPK'
	jz	short @f
unpack_err:
	mov	esi, offset notpacked_str
	push	notpacked_len
	pop	ecx
	jmp	write_string
@@:
	mov	ecx, [outfile]
	add	ecx, dword ptr [eax+4]
	push	64
	pop	eax
	push	1
	pop	ebx
	int	40h
	test	eax, eax
	jnz	memf1
	mov	esi, [infile]
	mov	eax, [esi+8]
	push	eax
	and	al, 0C0h
	cmp	al, 0C0h
	pop	eax
	jz	unpack_err
	and	al, not 0C0h
	dec	eax
	jnz	unpack_err
	mov	eax, [esi+4]
	mov	[outsize], eax
	push	eax
	push	[outfile]
	add	esi, 11
	push	esi
	mov	eax, [esi+1]
	xchg	al, ah
	ror	eax, 16
	xchg	al, ah
	mov	[esi+1], eax
	call	lzma_decompress
	mov	esi, [infile]
	test	byte ptr [esi+8], 80h
	jnz	uctr1
	test	byte ptr [esi+8], 40h
	jz	udone
	add	esi, [insize]
	sub	esi, 5
	lodsd
	mov	ecx, eax
	jecxz	udone
	mov	dl, [esi]
	mov	esi, [outfile]
uc1:
	lodsb
	sub	al, 0E8h
	cmp	al, 1
	ja	uc1
	cmp	[esi], dl
	jnz	uc1
	lodsd
	shr	ax, 8
	ror	eax, 16
	xchg	al, ah
	sub	eax, esi
	add	eax, [outfile]
	mov	[esi-4], eax
	loop	uc1
	jmp	short udone
uctr1:
	add	esi, [insize]
	sub	esi, 5
	lodsd
	mov	ecx, eax
	jecxz	udone
	mov	dl, [esi]
	mov	esi, [outfile]
uc2:
	lodsb
@@:
	cmp	al, 15
	jnz	short uf
	lodsb
	cmp	al, 80h
	jb	short @b
	cmp	al, 90h
	jb	short @f
uf:
	sub	al, 0E8h
	cmp	al, 1
	ja	uc2
@@:
	cmp	[esi], dl
	jnz	uc2
	lodsd
	shr	ax, 8
	ror	eax, 16
	xchg	al, ah
	sub	eax, esi
	add	eax, [outfile]
	mov	[esi-4], eax
	loop	uc2
udone:
	mov	esi, offset unpacked_ok
	push	unpacked_len
	pop	ecx
	call	write_string
	jmp	saveout

get_full_name:
	push	esi
	mov	esi, offset path
	mov	ecx, [esi-4]
	mov	edi, offset fullname
	rep	movsb
	mov	al, '/'
	cmp	byte ptr [edi-1], al
	jz	short @f
	stosb
@@:	pop	esi
	cmp	byte ptr [esi], al
	jnz	short @f
	mov	edi, offset fullname
@@:	mov	ecx, [esi-4]
	rep	movsb
	xor	eax, eax
	stosb
	ret

wsret:	ret
write_string:
; in: esi=pointer, ecx=length
	mov	edx, [message_cur_pos]
x1:
	lea	edi, [message_mem+edx]
do_write_char:
	lodsb
	cmp	al, 10
	jz	short newline
	stosb
	inc	edx
	loop	do_write_char
	jmp	short x2
newline:
	xor	eax, eax
	stosb
	xchg	eax, edx
	push	ecx
	push	eax
	mov	ecx, 80
	div	ecx
	pop	eax
	xchg	eax, edx
	sub	edx, eax
	add	edx, ecx
	pop	ecx
	loop	x1
x2:	mov	[message_cur_pos], edx
; update window
	push	13
	pop	eax
	mov	ebx, 901A1h
	mov	ecx, [skinheight]
	shl	ecx, 16
	add	ecx, 3700DEh
	mov	edx, [color_table+20]
	int	40h
draw_messages:
	mov	ebx, [skinheight]
	add	ebx, 3Ch+12*10000h
	mov	edi, offset message_mem
@@:	push	edi
	xor	eax, eax
	push	80
	pop	ecx
	repnz	scasb
	sub	ecx, 79
	neg	ecx
	mov	esi, ecx
	mov	al, 4
	pop	edi
	mov	edx, edi
	mov	ecx, [color_table+32]
	int	40h
	add	ebx, 10
	add	edi, 80
	cmp	edi, offset message_cur_pos
	jb	short @b
	ret

draw_window:
; start redraw
	push	12
	pop	eax
	xor	ebx, ebx
	inc	ebx
	int	40h
	mov	edi, [skinheight]
; define window
	xor	eax, eax
	mov	ebx, 6401B3h
	mov	ecx, 64011Eh
	add	ecx, edi
	mov	edx, [color_table+20]
	add	edx, 13000000h
	push	edi
	mov	edi, offset caption_str
	int	40h
	pop	edi
; lines - horizontal
	mov	edx, [color_table+36]
	mov	ebx, 80160h
	mov	ecx, edi
	shl	ecx, 16
	or	ecx, edi
	add	ecx, 20002h
	mov	al, 38
	int	40h
	add	ecx, 0C000Ch
	int	40h
	add	ecx, 0C000Ch
	int	40h
	add	ecx, 0C000Ch
	int	40h
; lines - vertical
	mov	ebx, 80008h
	sub	ecx, 240000h
	int	40h
	add	ebx, 340034h
	int	40h
	add	ebx, 1240124h
	int	40h
; draw frame for messages data
	push	ecx
	mov	ebx, 801AAh
	add	ecx, 340010h
	int	40h
	add	ecx, 0E0h*10001h
	int	40h
	mov	ebx, 80008h
	sub	cx, 0E0h
	int	40h
	mov	ebx, 1AA01AAh
	int	40h
	pop	ecx
; define compress button
	mov	al, 8
	mov	cx, 12h
	mov	ebx, 1620048h
	push	2
	pop	edx
	mov	esi, [color_table+36]
	int	40h
; uncompress button
	add	ecx, 120000h
	inc	edx
	int	40h
	add	ecx, -12h+0Ah+140000h
; question button
	push	esi
	mov	ebx, 1A10009h
	mov     dl, 7
	int	40h
	mov	al, 4
	mov	edx, offset aQuestion
	push	1
	pop	esi
	shr	ecx, 16
	lea	ebx, [ecx+1A40002h]
	mov	ecx, [color_table+28]
	int	40h
	mov	al, 8
	pop	esi
; define settings buttons
	mov	ebx, 90032h
	lea	ecx, [edi+2]
	shl	ecx, 16
	mov	cx, 0Bh
	push	4
	pop	edx
@@:
	int	40h
	add	ecx, 0C0000h
	inc	edx
	cmp	edx, 6
	jbe	@b
; text on settings buttons
	lea	ebx, [edi+5+0C0000h]
	mov	al, 4
	mov	ecx, [color_table+28]
	push	offset buttons1names
	pop	edx
	push	8
	pop	esi
@@:
	int	40h
	add	edx, esi
	add	ebx, 0Ch
	cmp	byte ptr [edx-6], ' '
	jnz	@b
; text on compress and decompress buttons
	lea	ebx, [edi+8+1720000h]
	push	offset aCompress
	pop	edx
	or	ecx, 80000000h
	int	40h
	lea	ebx, [edi+1Ah+16A0000h]
	push	offset aDecompress
	pop	edx
	int	40h
; infile, outfile, path strings
	mov	edx, offset inname
	lea	ebx, [edi+400005h]
editdraw:
	mov	esi, [edx-4]
	mov	al, 4
	mov	ecx, [color_table+32]
	int	40h
	cmp	edx, [curedit]
	jnz	short cont
	mov	al, 1
	push	ebx
	push	edx
	movzx	ecx, bx
	shr	ebx, 16
	lea	edx, [esi*2]
	lea	edx, [edx+edx*2]
	lea	ebx, [ebx+edx+2]
	add	ecx, 4
	xor	edx, edx
@@:
	cmp	esi, 48
	jz	@f
	int	40h
	add	ebx, 6
	inc	esi
	jmp	@b
@@:
	pop	edx
	pop	ebx
cont:
	add	edx, 52
	add	ebx, 0Ch
	cmp	edx, offset path+52
	jb	editdraw
; draw messages
	call	draw_messages
; end redraw
	push	12
	pop	eax
	push	2
	pop	ebx
	int	40h
	ret
aQuestion db '?'

copy_name:
	lea	edx, [edi+48]
@@:	lodsb
	cmp	al, ' '
	jbe	short copy_name_done
	stosb
	cmp	edi, edx
	jb	short @b
@@:	lodsb
	cmp	al, ' '
	ja	short @b
copy_name_done:
	dec	esi
	sub	edx, 48
	sub	edi, edx
	mov	[edx-4], edi

skip_spaces:
	lodsb
	cmp	al, 0
	jz	short @f
	cmp	al, ' '
	jbe	short skip_spaces
@@:	dec	esi
	ret

clear_edit_points:
; clear edit points (if is)
	mov	esi, [curedit]
	test	esi, esi
	jz	short cleared_edit_points
	push	eax
	mov	al, 13
	mov	ebx, [esi-4]
	imul	ebx, 6
	mov	edi, ebx
	add	ebx, 40h
	shl	ebx, 16
	add	ebx, 48*6
	sub	bx, di
	mov	ecx, [curedit_y]
	shl	ecx, 16
	or	cx, 9
	mov	edx, [color_table+20]
	int	40h
	pop	eax
cleared_edit_points:
	ret

	end	_start
