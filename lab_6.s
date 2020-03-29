	.data
score:	.string 12,"                Score:  "
score_data: .string "1",0,0,0,0,0 ;score
board:	.string 10,13," ---------------------------------------- ",10,13 ;board
		.string       "|                                        |",10,13
		.string       "|                                        |",10,13
		.string       "|                                        |",10,13
		.string       "|                                        |",10,13
		.string       "|                                        |",10,13
		.string       "|                                        |",10,13
		.string       "|                                        |",10,13
		.string       "|                    "
position:	.string                        "*                   |",10,13 ;starting position
		.string       "|                                        |",10,13
		.string       "|                                        |",10,13
		.string       "|                                        |",10,13
		.string       "|                                        |",10,13
		.string       "|                                        |",10,13
		.string       "|                                        |",10,13
		.string       "|                                        |",10,13
		.string       " ---------------------------------------- ",10,13,0
direction: .string "0",0,0,0 ;stores the direction
game_end: .string "Game Over. Your score is: ",0; when the game is over


	.text
	.global uart_init
 	.global output_character
 	.global read_character
 	.global output_string
	.global UART0_Handler
 	.global Switches_Handler
 	.global Timer0_Handler
 	.global interrupt_init
 	.global lab6
 	.global convert_to_int
 	.global convert_to_ascii


ptr_to_score:	.word score
ptr_to_score_data:	.word score_data
ptr_to_board:	.word board
ptr_to_position: .word position
ptr_to_direction:	.word direction
ptr_to_game_end:	.word game_end

lab6:
	STMFD SP!,{r6-r12,lr}
	; Store register lr on stack
	MOV r2,#0 ;initialize the r2 to zero
	MOV r5,#1 ;initialize the counter to 1
	MOV r8,#0	;initialize the offset to 0
	BL uart_init ;initialize the uart
	BL interrupt_init ;initializes the interrupts
	LDR r2,ptr_to_position
	LDR r4,ptr_to_score
	BL output_string ;outputs the score

	LDR r4, ptr_to_board ;outputs the board
	BL output_string

lab6loop:
	CMP r7,#45 ;check if r7 is '-'
	BEQ lab6exit ;exits if it is
	CMP r7,#124 ;check if r7 is '-'
	BEQ lab6exit ;exits if it is
	CMP r7,#42 ;check if r7 is '*'
	BEQ lab6exit ;exits if it is

	B lab6loop ;loops unconditionally

interrupt_init:
	STMFD SP!,{r3-r12,lr}
	 ; Store register lr on stack
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
	MOVT r4,#0x4003 ; interval period
	MOV r0,#0x0900
	MOVT r0,#0x3D
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
	ORR r2,r2,#0x20 ;enable interupts in the NVIC for the uart and port d
	STR r2,[r4]

	MOV r4,#0xC038
	MOVT r4,#0x4000 ; set RXIM mask bit to 1
	LDR r0,[r4]
	ORR r0,r0,#16
	STR r0,[r4]


	LDMFD sp!, {r3-r12,lr}
 	MOV pc, lr
UART0_Handler:
 	STMFD SP!,{r3-r12,lr}
 	; Store register lr on stack
 	BL read_character ;reads keyboard input
 	LDR r4,ptr_to_direction ;stores the direction in memory
 	STRB r0,[r4]

 	MOV r4,#0xC044 ;clear interrupt for rxim bit
	MOVT r4,#0x4000
	LDR r3,[r4]
	ORR r3,r2,#16
	STR r3,[r4]

	LDMFD sp!, {r3-r12,lr}
 	BX lr

Switches_Handler:
 	STMFD SP!,{lr}
 	; Store register lr on stack
	LDMFD sp!, {lr}
 	BX lr

Timer0_Handler:
	;r5 will be the score
	;r3 will be the char on the board
	;r8 will be the offset value
	;r2 will be the direction
 	STMFD SP!,{r0,r1,r4,r9-r12,lr}
 	; Store register lr on stack
	LDR r4,ptr_to_direction ;loads the direction into r2
	LDRB r2,[r4]

	CMP r2,#107 ;check if the direction is right (k)
	BEQ k_pressed
	CMP r2,#109 ;check if the direction is down (m)
	BEQ m_pressed
	CMP r2,#106 ;check if the direction is left (j)
	BEQ j_pressed
	CMP r2,#105 ;check if the direction is up (i)
	BEQ i_pressed

	B timerexit ;exits if its not becuase the game just started

j_pressed: ;when j is pressed
	SUB r8,r8,#1 ;substract 1 from the offset to go left
	LDR r4,ptr_to_position
	ADD r4,r4,r8
	LDRB r3,[r4];load the char on the board with the offset

	CMP r3,#45 ;check if its '-'
	BEQ timerexit
	CMP r3,#124 ;check if its '|'
	BEQ timerexit
	CMP r3,#42	;check if its '*'
	BEQ timerexit

	MOV r0,#42
	STRB r0,[r4] ;stores '*' on the board
	ADD r5,r5,#1 ;increment the score
	B timerexit ;exits the timer handler

i_pressed:;when i is pressed
	SUB r8,r8,#44 ;substract 44 from the offset to go up
	LDR r4,ptr_to_position
	ADD r4,r4,r8 ;load the char on the board with the offset
	LDRB r3,[r4]

	CMP r3,#45 ;check if its '-'
	BEQ timerexit
	CMP r3,#124  ;check if its '|'
	BEQ timerexit
	CMP r3,#42 ;check if its '*'
	BEQ timerexit

	MOV r0,#42
	STRB r0,[r4] ;stores '*' on the board
	ADD r5,r5,#1 ;increment the score
	B timerexit ;exits the timer handler

m_pressed: ;when m is pressed
	ADD r8,r8,#44 ;add 44 from the offset to go down
	LDR r4,ptr_to_position
	ADD r4,r4,r8
	LDRB r3,[r4] ;load the char on the board with the offset

	CMP r3,#45 ;check if its '-'
	BEQ timerexit
	CMP r3,#124 ;check if its '|'
	BEQ timerexit
	CMP r3,#42 ;check if its '*'
	BEQ timerexit

	MOV r0,#42
	STRB r0,[r4] ;stores '*' on the board
	ADD r5,r5,#1;increment the score
	B timerexit;exits the timer handler

k_pressed: ;when k is pressed
	ADD r8,r8,#1 ;add 1 from the offset to go right
	LDR r4,ptr_to_position
	ADD r4,r4,r8
	LDRB r3,[r4] ;load the char on the board with the offset

	CMP r3,#45 ;check if its '-'
	BEQ timerexit
	CMP r3,#124 ;check if its '|'
	BEQ timerexit
	CMP r3,#42 ;check if its '*'
	BEQ timerexit

	MOV r0,#42
	STRB r0,[r4] ;stores '*' on the board
	ADD r5,r5,#1 ;increment the score
	B timerexit ;exits the timer handler


timerexit:
	MOV r7,r3 ;copies the current char from the board to r7

	MOV r0,r5 ;copies the score to r0
	LDR r4, ptr_to_score_data
	BL convert_to_ascii ;stores the score in memory

	LDR r4,ptr_to_score ;outputs the score
	BL output_string

	LDR r4, ptr_to_board ;outputs the board
	BL output_string

	MOV r4,#0x0024
	MOVT r4,#0x4003
	LDR r9,[r4]
	ORR r9,r8,#1 ;clear interrupts
	STR r9,[r4]
	LDMFD sp!, {r0,r1,r4,r9-r12,lr}
 	BX lr

lab6exit:
	LDR r4, ptr_to_game_end ;outputs the game ended prompt
	BL output_string
	LDR r4, ptr_to_score_data ;outputs the score
	BL output_string
	LDMFD sp!, {r6-r12,lr}
 	MOV pc, lr

 	.end


