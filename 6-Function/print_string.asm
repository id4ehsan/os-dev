print_string: 
pusha                   ; Push all register values to the stack 
mov ah, 0x0e        ; int=10/ah=0x0e -> BIOS tele -type output


loop:
mov al,[bx]
cmp  al ,0     ; why we can't successfully compare cl,0
je end
int 0x10                ; print the character in al 
add bx,1
jmp loop
end:
mov al,0xd
int 0x10 
mov al,0xa
int 0x10 
popa                      ; Restore original register values 
ret
