	.data
	.global prompt
	.global expression
prompt1: .string "Enter first number (0 to 999): ",0
prompt2: .string "Enter second number (0 to 999): ",0
num1: .string "   ",0
num2: .string "   ",0
large:	.string "   ",0
dif:	.string "    ",0
dif1:	.string " ",0;

expression: .string " is the largest. The difference is ",0

	.text
	.global lab3
U0LSR:	.equ 0x18 ; UART0 Line Status Register

ptr_to_prompt1: .word prompt1
ptr_to_prompt2: .word prompt2
ptr_to_num1: .word num1
ptr_to_num2: .word num2
ptr_to_large: .word large
ptr_to_dif: .word dif
ptr_to_dif1: .word dif1
ptr_to_expression: .word expression

lab3:
	STMFD SP!, {lr}	    ;(Preserve Registers)Store register lr on stack


	LDR r4,ptr_to_num1 ;clears the mem for num1
	BL clearmem

	LDR r4,ptr_to_num2 ; clears the mem for num2
	BL clearmem

	LDR r4,ptr_to_large;clears the mem for largest num
	BL clearmem

	LDR r4,ptr_to_dif; clears mem for difference num
	BL clearmem

	LDR r4, ptr_to_prompt1 ; load the prompt for num1
	BL output_string	;output prompt1

	LDR r4, ptr_to_num1 ; reads the input for num1
 	BL read_string
 	BL replace_cr ; replaces cr with null terminator

 	LDR r4, ptr_to_prompt2 ;load the prompt for num2
 	BL output_string ;output prompt2


 	LDR r4, ptr_to_num2 ; reads the input for num2
 	BL read_string
	BL replace_cr ; replaces cr with null terminator

	LDR r4,ptr_to_num1
	BL convert_to_int ; converts num1 to int and store it in mem
	MOV r3,r1 ;result of num1 is store in r1 and mov into r3

	LDR r4,ptr_to_num2 ;converts num2 to int and store it in mem
	BL convert_to_int

	MOV r2,r1 ;result of num2 is store in r1 and mov into r2
	MOV r6,#0 ;flag to know if the difference should be neg
	CMP r3, r2 ;checks which number is bigger
	BGE firstisbig ; if the first number is bigger

	SUB r5,r2,r3 ;calc the abs value of the difference
	MOV r0,r2 ; copies the number to r0
	LDR r4, ptr_to_dif ; loads the address for difference in memory
	SUB r4,r4,#2; moves the address so it is as the end of the large address
	BL convert_to_ascii ;converts the second number to ascii and store it in the large number memory
	MOV r6,#1 ;set the flag to 1 so we know to print the negative sign

	B skiplab1 ;skips to label

firstisbig: ;
	SUB r5,r3,r2 ;calc thhe difference
	MOV r0,r3
	LDR r4, ptr_to_dif ;loads the address for difference in memory
	SUB r4,r4,#2;moves the address so it is as the end of the large address
	BL convert_to_ascii;converts the first number to ascii and store it in the large number memory

skiplab1:
	LDR r4, ptr_to_large ; prints the largest number that is store in mem
	BL output_string

 	LDR r4,ptr_to_dif1 ; load the dif1 address
 	SUB r4,r4,#2	;;moves the address so it is as the end of the dif address
	MOV r0,r5
	BL convert_to_ascii; converts the difference to ascii and store it in mem


	LDR r4,ptr_to_expression ; prints the expression
	BL output_string

	LDR r4,ptr_to_dif ;prints the difference
	BL output_string

	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character

	;B lab3

	LDMFD sp!, {lr}     ;(Restore Registers)
	MOV pc,lr


	LDMFD sp!, {r1-r12,lr}     ;(Restore Registers)
	MOV pc,lr

clearmem:;replaces the old numbers with spaces
	STMFD SP!, {r1-r12,lr} ;saves the registers

clearmemloop:
	MOV r1,#32 ;decimal number for space
	LDRB r2,[r4] ;load the byte in mem
	CMP r2,#0	; check if its the null
	BEQ doneclearmem ; if it is, it exits the loop
	STRB r1,[r4] ; stores the space in memory
	ADD r4,r4,#1 ;increase address
	B clearmemloop ; loops
doneclearmem:
	LDMFD sp!, {r1-r12,lr}     ;(Restore Registers)
	MOV pc,lr


convert_to_ascii:;convert integers to ascii
	STMFD SP!, {r1-r12,lr}
convert_asc:

	MOV r5,#10
	UDIV r1,r0,r5
	MUL r2,r1,r5 ;gets the last digit; this basically finds mod and right shift in decimal
	SUB r3,r0,r2 ; starts converting the ones place and then 10s place and so on
	MOV r0,r1

	CMP r1,#0 ; if the remainder is 0, there is no more places to convert
	BEQ doneasc ;exits the loop

	ADD r3,r3,#48
	STRB r3,[r4] ; if there needs to be a number to convert, it converts it and stores it in mem
	SUB r4,r4,#1
	B convert_asc

doneasc:
	ADD r3,r3,#48 ; converts the final number
	STRB r3,[r4] ;stores the final number in memory

	CMP r6,#0 ;this is the flag to see if it needs to store the negative sign in mem
	BEQ doneasc1
	MOV r3,#45 ; if r6 is 1, it will add the negative sign in before the number in mem
	SUB r4,r4,#1
	STRB r3,[r4]
doneasc1:
	LDMFD sp!, {r1-r12,lr}     ;(Restore Registers)
	MOV pc,lr

replace_cr:;replace carriage return with null
	STMFD SP!, {r1-r12,lr}
replace_loop:
	LDRB r0,[r4]
	ADD r4,r4,#1 ;traverses the string
	CMP r0,#13 ; check if char is the cr
	BNE replace_loop ;loops back if it is not the cr

	SUB r4,r4,#1
	MOV r1,#0 ; if it is, replaces it with null
	STRB r1,[r4]

	LDMFD sp!, {r1-r12,lr}     ;(Restore Registers)
	MOV pc,lr


convert_to_int: ;convert the ascii to integers
	STMFD SP!, {r2-r12,lr}
	MOV r1,#0 ;
	MOV r5,#10
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
	LDMFD sp!, {r2-r12,lr}     ;(Restore Registers)
	MOV pc,lr


read_string:; reads the string in address
	STMFD SP!, {r1-r12,lr}

read_s_loop:
	BL read_character ; calls read character
	STRB r0,[r4] ; stores the char from mem in r0
	ADD r4,r4,#1 ;increase the address to gget next char
	BL output_character ; calls output char to output what the user inputted
	CMP r0,#13 ; checks if it is the carriage return
	BNE read_s_loop

	BL output_character ;outputs the carriage return
	MOV r0,#10
	BL output_character;outputs new line
	LDMFD sp!, {r1-r12,lr}     ;(Restore Registers)
	MOV pc,lr

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

output_character:
    STMFD SP!, {r1-r3,r5-r12,lr}	    ;Store register lr on stack
    MOV r2, #0xC000  ;Set r0 equal to the base address
    MOVT r2, #0x4000


Transmit:
	;MOV r2, #0xC000  ;Set r0 equal to the base address
    ;MOVT r2, #0x4000
	LDRB r1, [r2,#U0LSR]
	LSR r1, r1,#5
	AND r3, r1, #0x1

	CMP r3,#1

    BEQ Transmit            ;Loop back if not full
    STRB r0,[r2]          ;Else store in transmit register
    LDMFD sp!, {r1-r3,r5-r12,lr}
	MOV pc, lr



	.end



