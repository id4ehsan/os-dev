	org	100h
	mov	ax, 3D00h
	mov	dx, inname
	int	21h
	jc	err
	xchg	ax, bx
	mov	ah, 3Fh
	mov	cx, 200h
	mov	dx, buf
	push	dx
	int	21h
	mov	ax, 301h
	xor	dx, dx
	mov	cx, 1
	pop	bx
	int	13h
	ret
err:
	mov	ah, 9
	mov	dx, errmsg
	int	21h
	ret
errmsg	db	'Cannot open '
inname	db	'bootmosf.bin',0
	db	'$'
buf: