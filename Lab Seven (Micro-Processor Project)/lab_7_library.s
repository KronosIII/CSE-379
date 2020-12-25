	.text
	.global uart_init
 	.global output_character
 	.global read_character
 	.global output_string
	.global UART0_Handler
	.global Timer0_Handler
	.global Timer1_Handler
 	.global illuminate_RGB_LED
 	.global lab7
 	.global gpio_init
 	.global convert_to_int
 	.global convert_to_ascii
 	.global randomnum
	.global interrupt_init
U0LSR:	.equ 0x18 ; UART0 Line Status Register
interrupt_init:
	STMFD SP!,{r3-r12,lr}; Store register lr on stack
	 ;timer0
	MOV r4, #0xE604
	MOVT r4, #0x400F
	LDR r0,[r4]
	ORR r0,r0,#0x1 ;connect clock to timer
	STR r0,[r4]

	MOV r4, #0x000C
	MOVT r4, #0x4003 ;enable timer section
	LDR r0,[r4]
	ORR r0,r0,#0x1
	STR r0,[r4]

	MOV r4,#0x0000
	MOVT r4,#0x4003 ;set up timer for 32 bit mode
	LDR r0,[r4]
	BFC r0,#0,#3
	STR r0,[r4]

	MOV r4,#0x0004
	MOVT r4,#0x4003;put timer in periodic mode
	LDR r0,[r4]
	ORR r0,r0,#0x2
	BFC r0,#0,#1
	STR r0,[r4]

	MOV r4,#0x0028
	MOVT r4,#0x4003 ; interval period;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOV r0,#0x1200
	MOVT r0,#0x7A
	STR r0,[r4]

	MOV r4,#0x0018
	MOVT r4,#0x4003 ;set timer to interrupt when top limit of timer is reached
	LDR r0,[r4]
	ORR r0,r0,#1
	STR r0,[r4]

	MOV r4,#0xE100
	MOVT r4,#0xE000;nvic
	MOV r1,#0x0000
	MOVT r1,#0x8
	LDR r0,[r4]
	ORR r0,r0,r1
	STR r0,[r4]

	MOV r4,#0x000C
	MOVT r4,#0x4003;enable the timer
	LDR r0,[r4]
	ORR r0,r0,#1
	STR r0,[r4]

	MOV r4,#0xE100
	MOVT r4,#0xE000
	LDR r2,[r4]
	ORR r2,r2,#0x20 ;enable interupts in the NVIC for the uart
	STR r2,[r4]

	MOV r4,#0xC038
	MOVT r4,#0x4000 ; set RXIM mask bit to 1
	LDR r0,[r4]
	ORR r0,r0,#16
	STR r0,[r4]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;timer1
	MOV r4, #0xE604
	MOVT r4, #0x400F
	LDR r0,[r4]
	ORR r0,r0,#0x2 ;connect clock to timer
	STR r0,[r4]


	MOV r4, #0x100C
	MOVT r4, #0x4003 ;enable timer section
	LDR r0,[r4]
	ORR r0,r0,#0x1
	STR r0,[r4]

	MOV r4,#0x1000
	MOVT r4,#0x4003 ;set up timer for 32 bit mode
	LDR r0,[r4]
	BFC r0,#0,#3
	STR r0,[r4]

	MOV r4,#0x1004
	MOVT r4,#0x4003;put timer in periodic mode
	LDR r0,[r4]
	ORR r0,r0,#0x2
	BFC r0,#0,#1
	STR r0,[r4]

	MOV r4,#0x1028
	MOVT r4,#0x4003 ; interval period;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOV r0,#0x6155
	MOVT r0,#0x51
	STR r0,[r4]

	MOV r4,#0x1018
	MOVT r4,#0x4003 ;set timer to interrupt when top limit of timer is reached
	LDR r0,[r4]
	ORR r0,r0,#1
	STR r0,[r4]

	MOV r4,#0xE100
	MOVT r4,#0xE000;nvic
	MOV r1,#0x0000
	MOVT r1,#0x20
	LDR r0,[r4]
	ORR r0,r0,r1
	STR r0,[r4]

	MOV r4,#0x100C
	MOVT r4,#0x4003;enable the timer
	LDR r0,[r4]
	ORR r0,r0,#1
	STR r0,[r4]

	LDMFD sp!, {r3-r12,lr}
 	MOV pc, lr

illuminate_RGB_LED:
	STMFD SP!,{lr} ; Store register lr on stack
 	; Your code is placed here

	MOV r4,#0x5000 ;base register for port F
	MOVT r4,#0x4002

	LSL r0,r0,#1
	STRB r0,[r4,#0x3FC] ;stores the input in data register

 	LDMFD sp!, {lr}
 	MOV pc, lr

gpio_init:
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

 	LDMFD sp!, {lr}
 	MOV pc, lr
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

	BL getamountofdigits ; r7 has the amount of digits
	;MOV r5,#10

ascloop:
	MOV r1,#10
	SUB r7,r7,#1
	BL div_and_mod
	ADD r1,r1,#48
	STRB r1,[r4,r7]
	CMP r7,#0
	BGT ascloop

	LDMFD sp!, {r1-r12,lr}     ;(Restore Registers)
	MOV pc,lr

getamountofdigits: ;returns the needed number for mod
	STMFD SP!, {r0-r5,r9-r12,lr}
	MOV r7,#0

	CMP r0,#9
	BGT place10
	MOV r7,#1 ;r7=1 if the number is in the ones place
	B enddigits

place10:
	CMP r0,#99
	BGT place100 ;r7=1 if the number is in the tens place
	MOV r7,#2
	B enddigits
place100:
	SUB r0,r0,#999
	CMP r0,#0
	BGT place1000 ;r7=1 if the number is in the tens place
	MOV r7,#3
	B enddigits

place1000:
	MOV r8,#0x270F
	SUB r0,r0,r8
	CMP r0,#0
	BGT place10000 ;r7=1 if the number is in the tens place
	MOV r7,#4
	B enddigits

place10000:
	MOV r7,#5
enddigits:
	LDMFD sp!, {r0-r5,r9-r12,lr}     ;(Restore Registers)
	MOV pc,lr

div_and_mod:
	STMFD r13!, {r2-r12, r14}

	; Your code for the signed division/mod routine goes here.
	; The dividend is passed in r0 and the divisor in r1.
	; The quotient is returned in r0 and the remainder in r1.
	MOV r2, #16 ;counter of 16

	MOV r5, #0 ; register r5 to know if dividend is negative
	MOV r6, #0 ;register r6 to know is divisor is negative

	CMP r0, #0 ;check if dividend is negative
	BGT chkquo

	MOV r5, #1 ; flag for if dividend is negative
	MOV r8, #0
	SUB r0, r8, r0; making the dividend to negative

chkquo:
	MOV r3, #0 ;r3 temp register for quotient
	LSL r1, r1, #16
	MOV r4, r0 ;r4 temp register for remainder
	CMP r1, #0 ; check if divisor is negative
	BGT loop

	MOV r6, #1 ;flag for is divisor is negative
	MOV r8, #0
	SUB r1, r8, r1; converts it to positive

loop:
	SUB r4, r4, r1 ;remainder = remainder-divisor
	CMP r4, #0 ;checks if remainder is less than 0
	BLT rem1

	LSL r3, r3, #1 ;left shift quotient
	ORR r3, r3, #0x1; lsb =1
	B rem

rem1:
	ADD r4, r4, r1 ; rem=rem+div
	LSL r3,r3,#1;left shift quotient
	BFC r3,#0,#1;lsb=0

rem:
	LSR r1, r1, #1 ;right shift divisor
	BFC r1, #31, #1;msb=0
	CMP r2, #0 ;check if counter >0
	BGT loop1
	B done

loop1:
	SUB r2,r2,#1 ;decrements counter
	B loop

done:
	EOR r7, r5, r6 ; check if i need to negate the quotient using the flags and xor
	CMP r7,#0
	BEQ pos
	MOV r8, #0
	SUB r3,r8,r3;making the quotient neg

pos:
	MOV r0, r3 ;moving the quotient to r0
	MOV r1, r4 ;moving the remainder to r1

	LDMFD r13!, {r2-r12, r14}
	MOV pc, lr
	.end
