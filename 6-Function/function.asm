; 
; A boot sector that prints a string using our function. 
; 
[org 0x7c00]  ; Tell the assembler where this code will be loaded

mov bx, HELLO_MSG  ; Use BX as a parameter to our function , so 
call print_string            ; we can specify the address of a string.
mov bx, GOODBYE_MSG 
call print_string

mov dx, 0x1fb6             ; store the value to print in dx 
call print_hex                ; call the function





jmp $                            ; Hang

%include "print_string.asm"
%include "print_hex.asm"
 
HELLO_MSG: 
db  'Hello , World!', 0   ; <-- The zero on the end tells our routine
                                      ; when to stop printing characters.
GOODBYE_MSG: 
db 'Goodbye!', 0

; Padding and magic number. 
times 510-($-$$) db 0 
dw 0xaa55
