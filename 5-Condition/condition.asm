mov bx, 30
;if (bx <= 4) {
cmp bx,4
jg elseif 
mov al, 'A'
;} else if (bx < 40) {
elseif:
cmp bx,40
jge else 
mov al, 'B' 
;} else { 
else:
mov al, 'C'
;}
mov ah, 0x0e ; int=10/ah=0x0e -> BIOS tele -type output 
int 0x10 ; print the character in al
jmp $ 
; Padding and magic number. 
times 510-($-$$) db 0 
dw 0xaa55

