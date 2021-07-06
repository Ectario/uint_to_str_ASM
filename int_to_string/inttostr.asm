BITS 64


%define NUMBER_TO_PRINT 12345543210

; A macro with two parameters
; Implements the write system call
%macro print_string 2 
  mov rax, 1        
  mov rdi, 1        
  mov rsi, %1    ; msg
  mov rdx, %2    ; msg length
  syscall    
%endmacro

%macro uint_to_str 2    ; Cast an unsigned int (first param) to a string (2nd param to store it), store in r13 the length
    mov rax, %1         ; Number to translate 
    mov r11, %2         ; Variable where store the string result
    mov r12, 10         ; New line after the conversion (not necessary)
    mov r13, 0          ; Register to store the length

    push r12            ; Push in the stack the \n


%%extractDigits:            ; It extracts the digits and puts them in the stack
    mov rdx, 0              ; To manage the future concatenate and just to don't mess up it.
    div r12                 ; Divide rax by r12 (10), and put the ratio into rax, and the remainder into rdx.
    add rdx, 48             ; Concatenate with ascii '0' to get the char of rdx number

    push rdx                ; Push in the stack the remainder

    add r13, 1              ; Add one for the length each char of digit

    cmp rax, 0              ; Check if rax (the ratio) is equal to 0
    jne %%extractDigits     ; If not, continue, else it means that all digit are used


%%popDigits:                ; It pops the digit from the stack and puts them into the variable
    pop r10                 ; Get the last number stacked in r10

    mov [r11], r10b         ; r10b is the 8 bits low of r10, and a char is encoded with 8 bits, so we get it and store into [r11]
    inc r11                 ; Increment word register by 1
    mov [r11], r11          ; Set the next address for the next char

    cmp r10, 10             ; Check if we are in the end (which is the new line \n = 10)
    jne %%popDigits         ; If not, continue, else we stop poping digit and go to the next instruction
    
%endmacro


section .bss
    string resb 100         ; Allocate 100 bytes for the string which will contains the number in string
section .rodata
 
section .text
    global _start
 
    _start:
    
        uint_to_str NUMBER_TO_PRINT, string     ; Cast the number in string, and store the length in r13
        print_string string, r13                ; Printing the string

        jmp _exit
    _exit:
        mov rax, 60
        mov rdi, 0
        syscall
    