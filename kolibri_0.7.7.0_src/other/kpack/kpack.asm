; kpack = Kolibri Packer
; Written by diamond in 2006 specially for KolibriOS

; Uses LZMA compression library by Igor Pavlov
; (for more information on LZMA and 7-Zip visit http://www.7-zip.org)
; (plain-C packer and ASM unpacker are ported by diamond)

	.486
	.model flat

GetCommandLineA		equ	__imp__GetCommandLineA@0
GetStdHandle		equ	__imp__GetStdHandle@4
WriteConsoleA		equ	__imp__WriteConsoleA@20
CreateFileA		equ	__imp__CreateFileA@28
GetFileSize		equ	__imp__GetFileSize@8
VirtualAlloc		equ	__imp__VirtualAlloc@16
ReadFile		equ	__imp__ReadFile@20
WriteFile		equ	__imp__WriteFile@20
CloseHandle		equ	__imp__CloseHandle@4
VirtualFree		equ	__imp__VirtualFree@12
ExitProcess		equ	__imp__ExitProcess@4

;includelib kernel32.lib
extrn GetStdHandle:dword
extrn GetCommandLineA:dword
extrn WriteConsoleA:dword
extrn CreateFileA:dword
extrn GetFileSize:dword
extrn VirtualAlloc:dword
extrn VirtualFree:dword
extrn ReadFile:dword
extrn WriteFile:dword
extrn CloseHandle:dword
extrn ExitProcess:dword

lzma_compress equ _lzma_compress@16
lzma_set_dict_size equ _lzma_set_dict_size@4
extrn lzma_compress:proc
extrn lzma_set_dict_size:proc

.data?
infilename	dd	?
outfilename	dd	?
infile		dd	?
outfile1	dd	?
outfile2	dd	?
outfile		dd	?
outfilebest	dd	?
workmem		dd	?
insize		dd	?
outsize		dd	?
lzma_dictsize	dd	?
ct1		db	256 dup (?)
ctn		dd	?
cti		db	?

.const
info_str	db	'KPack - Kolibri Packer, version 0.1',13,10
		db	'Uses LZMA v4.32 compression library',13,10,13,10
info_len	=	$ - offset info_str
usage_str	db	'Written by diamond in 2006 specially for KolibriOS',13,10
		db	'LZMA compression library is copyright (c) 1999-2005 by Igor Pavlov',13,10
		db	13,10
		db	'Usage: kpack <infile> [<outfile>]',13,10
usage_len	=	$ - offset usage_str
errload_str	db	'Cannot load input file',13,10
errload_len	=	$ - offset errload_str
outfileerr_str	db	'Cannot save output file',13,10
outfileerr_len	=	$ - offset outfileerr_str
nomem_str	db	'No memory',13,10
nomem_len	=	$ - offset nomem_str
too_big_str	db	'failed, output is greater than input.',13,10
too_big_len	=	$ - too_big_str
compressing_str	db	'Compressing ... '
compressing_len = $ - compressing_str

.data
done_str	db	'OK! Compression ratio: '
ratio		dw	'00'
		db	'%',13,10,13,10
done_len	=	$ - done_str

use_lzma	=	1

use_no_calltrick =	0
use_calltrick1	=	40h
use_calltrick2	=	80h

method			db	1

.code

write_string:
	push	eax	; reserve dword on the stack
	mov	eax, esp
	push	ebx
	push	eax
	push	dword ptr [eax+12]
	push	dword ptr [eax+8]
	push	ebp
	call	[WriteConsoleA]
	pop	eax
	ret	8
write_exit:
	call	write_string
	push	ebx
	call	[ExitProcess]

_start:
; say hi to user
	xor	ebx, ebx
	push	eax	; reserve dword on the stack
	push	-11	; STD_OUTPUT_HANDLE
	call	[GetStdHandle]
	xchg	eax, ebp
	push	info_len
	push	offset info_str
	call	write_string
; parse command line
	call	[GetCommandLineA]
	xchg	eax, esi
	call	skip_spaces
	call	get_file_name
	call	skip_spaces
	test	al, al
	jz	short usage
	call	get_file_name
	mov	[infilename], edi
	test	al, al
	jnz	short two_files
	mov	[outfilename], edi
	jmp	short cont
usage:
	push	usage_len
	push	offset usage_str
	jmp	write_exit
two_files:
	call	get_file_name
	mov	[outfilename], edi
	test	al, al
	jnz	short usage
cont:
; Input file
	push	ebx
	push	ebx
	push	3	; OPEN_EXISTING
	push	ebx
	push	1	; FILE_SHARE_READ
	push	80000000h	; GENERIC_READ
	push	[infilename]
	call	[CreateFileA]
	inc	eax
	jnz	short inopened
infileerr:
	push	errload_len
	push	offset errload_str
	jmp	write_exit
inopened:
	dec	eax
	xchg	eax, esi
	push	ebx
	push	esi
	call	[GetFileSize]
	inc	eax
	jz	short infileerr
	dec	eax
	jz	short infileerr
	mov	[insize], eax
	push	eax
	push	4	; PAGE_READWRITE
	push	1000h	; MEM_COMMIT
	push	eax
	push	ebx
	call	[VirtualAlloc]
	test	eax, eax
	jz	nomem
	mov	[infile], eax
	pop	edx
	mov	ecx, esp
	push	ebx
	push	ecx
	push	edx
	push	eax
	push	esi
	call	[ReadFile]
	test	eax, eax
	jz	short infileerr
	push	esi
	call	[CloseHandle]
	mov	eax, [insize]
	shr	eax, 3
	add	eax, [insize]
	add	eax, 400h	; should be enough for header
	mov	esi, eax
	add	eax, eax
	push	4
	push	1000h
	push	eax
	push	ebx
	call	[VirtualAlloc]
	test	eax, eax
	jnz	short outmemok
nomem:
	push	nomem_len
	push	offset nomem_str
	jmp	write_exit
outmemok:
	mov	[outfile], eax
	mov	[outfile1], eax
	mov	[outfilebest], eax
	add	eax, esi
	mov	[outfile2], eax
	sub	eax, esi
	mov     dword ptr [eax], 'KCPK'
	mov     ecx, [insize]
	mov     dword ptr [eax+4], ecx
	dec	ecx
	bsr	eax, ecx
	inc	eax
	cmp	eax, 28
	jb	short @f
	mov	eax, 28
@@:
	push	eax
	push	eax
	call	lzma_set_dict_size
	pop	ecx
	mov	eax, 1
	shl	eax, cl
	mov	[lzma_dictsize], eax
	imul	eax, 19
	shr	eax, 1
	add	eax, 509000h
	push	4
	push	1000h
	push	eax
	push	ebx
	call	[VirtualAlloc]
	test	eax, eax
	jz	nomem
	mov	[workmem], eax
	push	compressing_len
	push	offset compressing_str
	call	write_string
	mov	eax, [outfile2]
	mov	[outfile], eax
	xchg	eax, edi
	mov	esi, [outfile1]
	movsd
	movsd
	call	pack_lzma
	mov	[outsize], eax
	mov	eax, [outfile]
	mov	[outfilebest], eax
	mov	[method], use_lzma
	call	preprocess_calltrick
	test	eax, eax
	jz	short noct1
	call	set_outfile
	call	pack_lzma
	add     eax, 5
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
	add     eax, 5
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
	cmp     eax, [insize]
	jb      short packed_ok
	push	too_big_len
	push	offset too_big_str
	jmp	write_exit
packed_ok:
	push	8000h	; MEM_RELEASE
	push	ebx
	push	[workmem]
	call	[VirtualFree]
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
	mov     eax, [outsize]
	mov	ecx, 100
	mul	ecx
	div	[insize]
	aam
	xchg	al, ah
	add	ax, '00'
	mov	[ratio], ax
	push	done_len
	push	offset done_str
	call	write_string
; Output file
	push	ebx
	push	80h	; FILE_ATTRIBUTE_NORMAL
	push	2	; CREATE_ALWAYS
	push	ebx
	push	ebx
	push	40000000h	; GENERIC_WRITE
	push	[outfilename]
	call	[CreateFileA]
	inc	eax
	jnz	short @f
outerr:
	push	outfileerr_len
	push	offset outfileerr_str
	jmp	write_exit
@@:
	dec	eax
	xchg	eax, esi
	mov	eax, esp
	push	ebx
	push	eax
	push	[outsize]
	push	edi
	push	esi
	call	[WriteFile]
	test	eax, eax
	jz	short outerr
	push	esi
	call	[CloseHandle]
	push	ebx
	call	[ExitProcess]

get_file_name:
	mov	edi, esi
	lodsb
	cmp	al, 0
	jz	short _ret
	cmp	al, '"'
	setz	dl
	jz	short @f
	dec	esi
@@:	mov	edi, esi
@@loop:
	lodsb
	cmp	al, 0
	jz	short _ret
	cmp	al, ' '
	ja	short @f
	test	dl, 1
	jz	short @@end
@@:
	cmp	al, '"'
	jnz	short @@loop
	test	dl, 1
	jz	short @@loop
@@end:
	mov	byte ptr [esi-1], 0

skip_spaces:
	lodsb
	cmp	al, 0
	jz	short @f
	cmp	al, ' '
	jbe	short skip_spaces
@@:
	dec	esi
_ret:
	ret

set_outfile:
	mov	eax, [outfilebest]
	xor	eax, [outfile1]
	xor	eax, [outfile2]
	mov	[outfile], eax
	ret

pack_calltrick_fail:
	xor	eax, eax
	xor	ebx, ebx
	mov	[ctn], eax
	ret
preprocess_calltrick:
; input preprocessing
	push	4	; PAGE_READWRITE
	push	1000h	; MEM_COMMIT
	push	[insize]
	push	ebx
	call	[VirtualAlloc]
	test	eax, eax
	jz	pack_calltrick_fail
	push	eax
	xor	eax, eax
	mov	edi, offset ct1
	mov	ecx, 256/4
	push	edi
	rep	stosd
	pop	edi
	mov	ecx, [insize]
	mov	esi, [infile]
	xchg	eax, edx
	pop	eax
	xchg	eax, ebx
	push	ebx
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
	bswap	eax
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
	pop	edx
	xor	eax, eax
	mov	ecx, 256
	repnz	scasb
	jnz	pack_calltrick_fail
	not	cl
	mov	[cti], cl
@@:
	cmp	ebx, edx
	jz	@f
	sub	ebx, 4
	mov	eax, [ebx]
	mov	[eax-4], cl
	jmp	@b
@@:
	xor	ebx, ebx
	push	8000h
	push	ebx
	push	edx
	call	[VirtualFree]
	ret

pack_lzma:
	mov	eax, [outfile]
	add	eax, 11
	push	[workmem]
	push	[insize]
	push	eax
	push	[infile]
	call	lzma_compress
	mov	ecx, [outfile]
	mov     edx, [ecx+12]
	bswap	edx
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
	mov	al, 0
	bswap	eax
	sub	eax, esi
	add	eax, [infile]
	mov	[esi-4], eax
	loop	pc2l1
pc2l2:
; input preprocessing
	push	4	; PAGE_READWRITE
	push	1000h	; MEM_COMMIT
	push	[insize]
	push	ebx
	call	[VirtualAlloc]
	test	eax, eax
	jz	pack_calltrick_fail
	mov	edi, offset ct1
	xchg	eax, ebx
	xor	eax, eax
	push	edi
	mov	ecx, 256/4
	rep	stosd
	pop	edi
	mov	ecx, [insize]
	mov	esi, [infile]
	xchg	eax, edx
	push	ebx
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
	bswap	eax
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
	pop	edx
	xor	eax, eax
	mov	ecx, 256
	repnz	scasb
	jnz	pack_calltrick_fail
	not	cl
	mov	[cti], cl
@@:
	cmp	ebx, edx
	jz	@f
	sub	ebx, 4
	mov	eax, [ebx]
	mov	[eax-4], cl
	jmp	@b
@@:
	xor	ebx, ebx
	push	8000h
	push	ebx
	push	edx
	call	[VirtualFree]
	ret

	end	_start
