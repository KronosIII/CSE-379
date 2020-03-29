	.text
	.global uart_init
 	.global output_character
 	.global read_character
 	.global read_string
 	.global output_string
 	.global read_from_push_btns
 	.global illuminate_LEDs
 	.global illuminate_RGB_LED
	.global read_keypad
	.global convert_to_int
	.global clearmem
	.global replace_cr
	.global div_and_mod
U0LSR:	.equ 0x18 ; UART0 Line Status Register
;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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


	;;;;;;;;;;;;;;;
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
   ;;;;;;;;;;;;;;;;;;;;;;
read_from_push_btns:
	STMFD SP!,{lr} ; Store register lr on stack
 	; Your code is placed here
 	MOV r1,#0xE000
	MOVT r1,#0x400F ;clock address

	LDR r2,[r1,#0x608] ;inirialize the clock
	ORR r2,r2,#0x8
	STR r2,[r1,#0x608]

	MOV r4,#0x7000 ;base register for port d
	MOVT r4,#0x4000

	LDR r2,[r4,#0x51C] ;initialize the digital register
	ORR r2,r2,#0xF
	STR r2,[r4,#0x51C]

	LDR r2,[r4,#0x400]
	MOV r1,#0xFFF0 ;initialize the direction register
	MOVT r1,#0xFFFF
	AND r2,r2,r1
	STR r2,[r4,#0x400]

	LDRB r0,[r4,#0x3FC] ;stores the input in r0

 	LDMFD sp!, {lr}
 	MOV pc, lr
   ;;;;;;;;;;;;;;;;;;;;
illuminate_LEDs:
	STMFD SP!,{lr}    ; Store register lr on stack
	; Your code is placed here
	MOV r1,#0xE000 ;clock address
	MOVT r1,#0x400F

	LDR r2,[r1,#0x608]
	ORR r2,r2,#0x2 ;initialize the clock
	STR r2,[r1,#0x608]

	MOV r4,#0x5000 ;address for port B
	MOVT r4,#0x4000
	
	LDR r2,[r4,#0x400]
	ORR r2,r2,#0xF ;initialize the direction register
	STR r2,[r4,#0x400]

	LDR r2,[r4,#0x51C]
	ORR r2,r2,#0xF ;initialize the direction register
	STR r2,[r4,#0x51C]

	STRB r0,[r4,#0x3FC] ;stores the input in the data register

	
	LDMFD SP!, {lr}
	BX lr

illuminate_RGB_LED:
	STMFD SP!,{lr} ; Store register lr on stack
 	; Your code is placed here

	MOV r1,#0xE000 ;clock address
	MOVT r1,#0x400F
	LDR r2,[r1,#0x608] ;initialize the clock
	ORR r2,r2,#0x32
	STR r2,[r1,#0x608]

	MOV r4,#0x5000 ;base register for port F
	MOVT r4,#0x4002

	LDR r2,[r4,#0x400]
	ORR r2,r2,#0xE ;intialize the direction register
	STR r2,[r4,#0x400]

	LDR r2,[r4,#0x51C]
	ORR r2,r2,#0xE ;intialize the digital register
	STR r2,[r4,#0x51C]

	LSL r0,r0,#1
	STRB r0,[r4,#0x3FC] ;stores the input in data register

 	LDMFD sp!, {lr}
 	MOV pc, lr
read_keypad:
 	STMFD SP!,{lr} ; Store register lr on stack
 	; Your code is placed here
	MOV r1,#0xE000
	MOVT r1,#0x400F ;base address
	LDR r2,[r1,#0x608]
	ORR r2,r2,#0x8 ;initializes the clock for port d
	STR r2,[r1,#0x608]

	LDR r2,[r1,#0x608] ;initializes the clock for port A
	ORR r2,r2,#0x1
	STR r2,[r1,#0x608]


	MOV r4,#0x7000 ; address D
	MOVT r4,#0x4000

	LDR r2,[r4,#0x400]
	ORR r2,r2,#0xF ; initialize the direction register port D
	STR r2,[r4,#0x400]

	LDR r2,[r4,#0x51C]
	ORR r2,r2,#0xF ;initialize the digital register port D
	STR r2,[r4,#0x51C]




	MOV r3,#0x4000
	MOVT r3,#0x4000 ;address A

	LDR r2,[r3,#0x51C]
	ORR r2,r2,#0x3C ;initialize the digital register port A
	STR r2,[r3,#0x51C]

	LDR r2,[r3,#0x400]
	MOV r1,#0xFFC3
	MOVT r1,#0xFFFF ;initialize the direction register for port a
	AND r2,r2,r1
	STR r2,[r3,#0x400]

readkey_loop:
	MOV r0,#0
	MOV r1,#0x1 ;D
	STRB r1,[r4,#0x3FC] ; initilize only the first row of the keypad

	LDR r5,[r3,#0x3FC] ;A
	LSR r5,r5,#2 ;load the input from port A
	AND r5,r5,#0xF

	LDR r5,[r3,#0x3FC] ;A
	LSR r5,r5,#2 ;load the input from port A
	AND r5,r5,#0xF

	CMP r5,#1 ;check if the first column is pressed
	BNE a3_1_check
	MOV r0,#49 ; 1 is pressed
	B keypad_end

a3_1_check:
	CMP r5, #2 ;checks if the second column is pressed
	BNE a4_1_check
	MOV r0,#50 ; 2 is pressed
	B keypad_end

a4_1_check:
	CMP r5,#4 ;check if the third column is checked
	BNE row2
	MOV r0,#51 ; 3 is pressed
	B keypad_end


row2:
	MOV r1,#0x2 ;D
	STRB r1,[r4,#0x3FC];initialize only the second row of the keypad

	LDR r5,[r3,#0x3FC] ;A
	LSR r5,r5,#2
	AND r5,r5,#0xF ;load the input in from A

	LDR r5,[r3,#0x3FC] ;A
	LSR r5,r5,#2  ;load the input from port A
	AND r5,r5,#0xF

	CMP r5,#1 ;check if the first column is pressed
	BNE a3_2_check
	MOV r0,#52 ; 4 is pressed
	B keypad_end

a3_2_check:
	CMP r5, #2 ;checks if the second column is pressed
	BNE a4_2_check
	MOV r0,#53 ; 5 is pressed
	B keypad_end

a4_2_check:
	CMP r5, #4 ;checks if the third column is pressed
	BNE row3
	MOV r0,#54 ; 6 is pressed
	B keypad_end


row3:
	MOV r1,#0x4 ;D
	STRB r1,[r4,#0x3FC] ;initialize only the third row of the keypad

	LDR r5,[r3,#0x3FC] ;A
	LSR r5,r5,#2
	AND r5,r5,#0xF ;load the input from port A

	LDR r5,[r3,#0x3FC] ;A
	LSR r5,r5,#2
	AND r5,r5,#0xF ;load the input from port A

	CMP r5,#1 ;checks if the first column is pressed
	BNE a3_3_check
	MOV r0,#55 ;7 is pressed
	B keypad_end

a3_3_check:
	CMP r5, #2 ;checks if the second column is pressed
	BNE a4_3_check
	MOV r0,#56 ; 8 is pressed
	B keypad_end

a4_3_check:
	CMP r5, #4 ;checks if the third column is pressed
	BNE row4
	MOV r0,#57 ;9 is pressed
	B keypad_end

row4:
	MOV r1,#0x8 ;D
	STRB r1,[r4,#0x3FC] ;initialize only the fourth row of the keypad

	LDR r5,[r3,#0x3FC] ;A
	LSR r5,r5,#2
	AND r5,r5,#0xF ;load the input from port A

	LDR r5,[r3,#0x3FC] ;A
	LSR r5,r5,#2
	AND r5,r5,#0xF ;load the input from port A

	CMP r5,#2 ;checks if the second column is pressed
	BNE keypad_end
	MOV r0,#48 ; 0 is pressed





keypad_end:
 	LDMFD sp!, {lr}
 	MOV pc, lr
 ;;;;;;
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

clearmem:;replaces the old numbers with spaces
	STMFD SP!, {r1-r12,lr} ;saves the registers

clearmemloop:
	MOV r1,#0 ;decimal number for space
	LDRB r2,[r4] ;load the byte in mem
	CMP r2,#0	; check if its the null
	BEQ doneclearmem ; if it is, it exits the loop
	STRB r1,[r4] ; stores the space in memory
	ADD r4,r4,#1 ;increase address
	B clearmemloop ; loops
doneclearmem:
	LDMFD sp!, {r1-r12,lr}     ;(Restore Registers)
	MOV pc,lr

	;;;;;;
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
 	.end


