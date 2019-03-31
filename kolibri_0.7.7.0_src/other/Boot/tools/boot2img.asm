	org	100h
	mov	ax, 3D00h
	mov	dx, inname
	int	21h
	jc	err
	xchg	ax, bx
	mov	ah, 3Fh
	mov	cx, 200h
	push	cx
	mov	dx, buf
	push	dx
	int	21h
	mov	ax, 3D01h
	mov	dx, outname
	int	21h
	jc	err
	xchg	ax, bx
	mov	ah, 40h
	pop	dx
	pop	cx
	int	21h
	ret
err:
	push	dx
	mov	ah, 9
	mov	dx, errmsg
	int	21h
	pop	dx
	int	21h
	int	20h
errmsg	db	'Cannot open $'
inname	db	'bootmosf.bin',0
	db	'$'
outname	db	'kolibri.img',0
	db	'$'
buf: