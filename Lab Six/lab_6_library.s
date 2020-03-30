	.text
	.global uart_init
 	.global output_character
 	.global read_character
 	.global output_string
 	;.global read_from_push_btns
	.global UART0_Handler
 	;.global Switches_Handler
 	;.global interrupt_init
 	.global lab6
 	;.global gpio_init
 	.global convert_to_int
 	.global convert_to_ascii


U0LSR:	.equ 0x18 ; UART0 Line Status Register
uart_init:
	STMFD SP!, {lr}
	MOV r2, #0xE618  ;Set r0 equal to the base address
    MOVT r2, #0x400F
	LDR r0,[r2]
	ORR r0,r0,#1
	STR r0,[r2]	;stores the new value

	MOV r2, #0xE608  ;Set r0 equal to the base address
    MOVT r2, #0x400F
	LDR r0,[r2]
	ORR r0,r0,#1
	STR r0,[r2] ;stores the new value

	MOV r2, #0xC030  ;Set r0 equal to the base address
    MOVT r2, #0x4000
	LDR r0,[r2]
	ORR r0,r0,#0
	STR r0,[r2] ;stores the new value


	MOV r2, #0xC024  ;Set r0 equal to the base address
    MOVT r2, #0x4000
	LDR r0,[r2]
	ORR r0,r0,#8
	STR r0,[r2] ;stores the new value

	MOV r2, #0xC028  ;Set r0 equal to the base address
    MOVT r2, #0x4000
	LDR r0,[r2]
	ORR r0,r0,#44
	STR r0,[r2] ;stores the new value

	MOV r2, #0xCFC8  ;Set r0 equal to the base address
    MOVT r2, #0x4000
	LDR r0,[r2]
	ORR r0,r0,#0
	STR r0,[r2] ;stores the new value

	MOV r2, #0xC02C  ;Set r0 equal to the base address
    MOVT r2, #0x4000
	LDR r0,[r2]
	ORR r0,r0,#0x60
	STR r0,[r2] ;stores the new value

	MOV r2, #0xC030  ;Set r0 equal to the base address
    MOVT r2, #0x4000
	LDR r0,[r2]
	MOV r3, #0x301
	ORR r0,r0,r3
	STR r0,[r2] ;stores the new value

	MOV r2, #0x451C  ;Set r0 equal to the base address
    MOVT r2, #0x4000
	LDR r0,[r2]
	ORR r0,r0,#0x03
	STR r0,[r2] ;stores the new value

	MOV r2, #0x4420  ;Set r0 equal to the base address
    MOVT r2, #0x4000
	LDR r0,[r2]
	ORR r0,r0,#0x03
	STR r0,[r2] ;stores the new value

	MOV r2, #0x452C  ;Set r0 equal to the base address
    MOVT r2, #0x4000
	LDR r0,[r2]
	ORR r0,r0,#0x11
	STR r0,[r2] ;stores the new value

	LDMFD sp!, {lr}     ;(Restore Registers)
	MOV pc,lr


output_character:
    STMFD SP!, {r1-r3,r5-r12,lr}	    ;Store register lr on stack
    MOV r2, #0xC000  ;Set r0 equal to the base address
    MOVT r2, #0x4000
Transmit:

	LDRB r1, [r2,#U0LSR]
	LSR r1, r1,#5
	AND r3, r1, #0x1

	CMP r3,#1

    BEQ Transmit            ;Loop back if not full
    STRB r0,[r2]          ;Else store in transmit register
    LDMFD sp!, {r1-r3,r5-r12,lr}
	MOV pc, lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
read_character:
	STMFD SP!, {r1-r12,lr}
	MOV r3, #0xC000  ;Set r0 equal to the base address
    MOVT r3, #0x4000

back:
	LDRB r1, [r3,#U0LSR];check if it is able to read char
	LSR r1, r1,#4
	AND r2, r1, #0x1 ;get the status register

	CMP r2,#1 ; check if it is 1
	BEQ back


	LDRB r0, [r3] ; if it is zero, it will load the char in r0

	LDMFD sp!, {r1-r12,lr}
	MOV pc, lr



output_string:
    STMFD   SP!, {r1-r3,r5-r12,lr}
output_string_loop:

    LDRB    r0, [r4], #1        ; char loaded into r0
    ;;;;;;;
    MOV r2, #0xC000  ;Set r0 equal to the base address
    MOVT r2, #0x4000
    BL      output_character    ; output char in r0
    CMP     r0, #0x0            ; Check if loop has reached the NULL termniator '\0'
    BNE     output_string_loop  ; If Loop has not reached Null Character read next char

    LDMFD sp!, {r1-r3,r5-r12,lr}
    MOV pc, lr


convert_to_int: ;convert the ascii to integers
	STMFD SP!, {r2-r12,lr}
	MOV r1,#0 ;
	MOV r5,#10
	MOV r6,#0
	LDRB r2,[r4]
	CMP r2, #45
	BNE convertint
	ADD r4,r4,#1
	MOV r6,#1

convertint:
	LDRB r2,[r4] ;loads the current char
	LDRB r3,[r4,#1];load the next char


	CMP r3,#0 ;checks if the next char is null
	BEQ doneint

	SUB r2,r2,#48 ;converts the curren char to int
	ADD r4,r4,#1 ; increase the address

	ADD r1,r1,r2
	MUL r1,r1,r5 ;adds the num to final int and mulitplies it by 10

	B convertint

doneint:
	SUB r2,r2,#48 ;converts final char
	ADD r1,r1,r2 ;add like number to final int
	CMP r6,#0
	BEQ doneint1
	MOV r8,#0
	SUB r1,r8,r1

doneint1:
	LDMFD sp!, {r2-r12,lr}     ;(Restore Registers)
	MOV pc,lr

convert_to_ascii:;convert integers to ascii
	STMFD SP!, {r1-r12,lr}
;convert_asc:
	CMP r6,#0 ;this is the flag to see if it needs to store the negative sign in mem
	BEQ doneasc1
	MOV r3,#45 ; if r6 is 1, it will add the negative sign in before the number in mem
	STRB r3,[r4]
	ADD r4,r4,#1
doneasc1:

	BL getamountofdigits ; r7 has the amount of digits r8
	;MOV r5,#10
	UDIV r1,r0,r7 ;r1 is the result of div
	MUL r2,r1,r7 ;gets the last digit; this basically finds mod and right shift in decimal
	SUB r3,r0,r2 ; starts converting the ones place and then 10s place and so on
	MOV r0,r3

	CMP r7,#10; if the div is 0, there is no more places to convert
	BEQ doneasc ;exits the loop
	CMP r7,#1
	BEQ doneasc3

	ADD r1,r1,#48
	STRB r1,[r4] ; if there needs to be a number to convert, it converts it and stores it in mem
	ADD r4,r4,#1
	B doneasc1

doneasc:
	ADD r1,r1,#48
	STRB r1,[r4]
	ADD r4,r4,#1
	ADD r3,r3,#48 ; converts the final number
	STRB r3,[r4] ;stores the final number in memory
	B doneasc2
doneasc3:
	ADD r1,r1,#48
	STRB r1,[r4]
doneasc2:
	LDMFD sp!, {r1-r12,lr}     ;(Restore Registers)
	MOV pc,lr


getamountofdigits: ;returns the needed number for mod
	STMFD SP!, {r0-r6,r9-r12,lr}
	MOV r7,#1

	CMP r0,#9
	BGT place10
	MOV r7,#1 ;r7=1 if the number is in the ones place
	B enddigits

place10:
	CMP r0,#99
	BGT place100 ;r7=1 if the number is in the tens place
	MOV r7,#10
	B enddigits
place100:
	MOV r7,#100; ;r7=1 if the number is in the 100s place
enddigits:
	LDMFD sp!, {r0-r6,r9-r12,lr}     ;(Restore Registers)
	MOV pc,lr
	.end





