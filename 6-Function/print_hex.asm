; prints the value of DX as hex. 
print_hex:
; TODO: manipulate chars at HEX_OUT to reflect DX
pusha
mov bx,HEX_OUT
add bx,0x5
mov cx,0x0
looph:
		cmp cl,0x4
		je endh
				mov ax,dx
				and ax,0x000f
				cmp al,0x9
				jle number
						add al,0x57
						jmp afteradd
number:
						add al,0x30
afteradd:
				mov [bx],al
				sub bx,1
				shr dx,0x4
				add cl,0x1
				jmp looph
endh:

mov bx, HEX_OUT       ; print the string pointed to 
call print_string ; by BX ret

popa
ret
; Data 
HEX_OUT:
 db '0x0000',0