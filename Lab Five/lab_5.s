	.data
	.global switch2
	.global switch3
	.global switch4
	.global switch5
	.global keystroke
switch2:	.string "0",0,0,0,0 ;store the count for switch 2 (left most button)
switch3:	.string "0",0,0,0,0	;store the count for switch 3
switch4:	.string "0",0,0,0,0 ;store the count for switch 4
switch5:	.string "0",0,0,0,0 ;store the count for switch 5 (right most buttons)
keystroke:	.string "0",0,0,0,0 ;store the count for the keystrokes except q

	.text
	.global uart_init
 	.global output_character
 	.global read_character
 	.global output_string
 	.global read_from_push_btns
	.global UART0_Handler
 	.global Switches_Handler
 	.global interrupt_init
 	.global lab5
 	.global gpio_init
 	.global outputstrings
 	.global convert_to_int
 	.global convert_to_ascii


prompt: .string "Press the push buttons or keyboard to continuously update the count.",10,13,"Press 'q' to quit",10,13,0
but2_output:	.string "Switch 2: ",0
but3_output:	.string ", Switch 3: ",0
but4_output:	.string ", Switch 4: ",0
but5_output:	.string ", Switch 5: ",0
keystroke_output: .string ", Keystrokes: ",0
exit_prompt:	.string "Goodbye",0

ptr_to_prompt: .word prompt
ptr_to_but2_output: .word but2_output
ptr_to_but3_output: .word but3_output
ptr_to_but4_output: .word but4_output
ptr_to_but5_output: .word but5_output
ptr_to_keystroke_output: .word keystroke_output

ptr_to_switch2: .word switch2
ptr_to_switch3: .word switch3
ptr_to_switch4: .word switch4
ptr_to_switch5: .word switch5
ptr_to_keystroke:	.word keystroke
ptr_to_exit_prompt:	.word exit_prompt


lab5:
	STMFD SP!,{r0-r12,lr}
	 ; Store register lr on stack

	BL uart_init
	BL gpio_init ;initialize port D aka the push buttons
	BL interrupt_init ;intialize the interupts
	BL outputstrings
	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character
	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character



lab5loop: ;unconditionally loop
	CMP r7,#113
	BEQ lab5exit
	B lab5loop
 ; Your code is placed here



outputstrings: ;outputs the prompt string along with the all the counts
	STMFD SP!,{r0-r12,lr}
	LDR r4, ptr_to_prompt ;output the prompt
	BL output_string


	LDR r4,ptr_to_but2_output ;outputs switch 2 data
	BL output_string
	LDR r4,ptr_to_switch2
	BL output_string

	LDR r4,ptr_to_but3_output ;outputs switch 3 data
	BL output_string
	LDR r4,ptr_to_switch3
	BL output_string

	LDR r4,ptr_to_but4_output ;outputs switch 4 data
	BL output_string
	LDR r4,ptr_to_switch4
	BL output_string

	LDR r4,ptr_to_but5_output ;outputs switch 5 data
	BL output_string
	LDR r4,ptr_to_switch5
	BL output_string

	LDR r4, ptr_to_keystroke_output ;outputs the keystroke data
	BL output_string
	LDR r4,ptr_to_keystroke
	BL output_string

	LDMFD sp!, {r0-r12,lr}
	MOV pc, lr


interrupt_init:
	STMFD SP!,{r0-r12,lr}
	 ; Store register lr on stack
	MOV r4,#0x7000 ;base register for port d
	MOVT r4,#0x4000

	LDR r2,[r4,#0x404]
	MOV r1,#0xFFF0
	MOVT r1,#0xFFFF ;GPIOIS, setting it to edge sensitive
	AND r2,r2,r1
	STR r2,[r4,#0x404]

	LDR r2,[r4,#0x408]
	MOV r1,#0xFFF0
	MOVT r1,#0xFFFF ;GPIOIBE, allow register to control pin
	AND r2,r2,r1
	STR r2,[r4,#0x408]

	LDR r2,[r4,#0x40C]
	ORR r2,r2,#0xF
	STR r2,[r4,#0x40C]; ;GPIOIEV SET HIGH RISING EDGE

	LDR r2,[r4,#0x410]
	ORR r2,r2,#0xF
	STR r2,[r4,#0x410]; ;GPIOIM, enable it

	MOV r4,#0xE100
	MOVT r4,#0xE000

	LDR r2,[r4]
	ORR r2,r2,#0x28 ;enable interupts in the NVIC for the uart and port d
	STR r2,[r4]

	MOV r4,#0xC038
	MOVT r4,#0x4000 ; set RXIM mask bit to 1
	LDR r0,[r4]
	ORR r0,r0,#16
	STR r0,[r4]


	 ; Your code is placed here
	LDMFD sp!, {r0-r12,lr}
 	MOV pc, lr
UART0_Handler:
 	STMFD SP!,{r1-r6,r8-r12,lr}
 	; Store register lr on stack

 	MOV r4,#0xC044 ;clear interrupt for rxim bit
	MOVT r4,#0x4000
	LDR r1,[r4]
	ORR r1,r1,#16
	STR r1,[r4]

	BL read_character ;reads the character input from keyboard

	CMP r0,#113 ;check if it is q
	BEQ uart_handler_exit

	LDR r4,ptr_to_keystroke
	BL convert_to_int ;load the count from memory
	ADD r1,r1,#1 ;increment count
	LDR r4,ptr_to_keystroke ;convert it to ascii and puts it in memory
	MOV r0,r1
	BL convert_to_ascii

	BL outputstrings ;prints the prompt along with the updated count

	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character

	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character
uart_handler_exit:
	MOV r7,r0
 	; Your code is placed here
	LDMFD sp!, {r1-r6,r8-r12,lr}
 	BX lr
Switches_Handler:
 	STMFD SP!,{lr}
 	; Store register lr on stack
	MOV r4,#0x7000 ;base register for port d
	MOVT r4,#0x4000

	LDR r2,[r4,#0x41C]
	ORR r2,r2,#0xF ;GPIO interrupt clear for port D
	STR r2,[r4,#0x41C]
	BL read_from_push_btns ;reads the input from push button



	CMP r0, #8
	BEQ switch2_clicked ;check is switch 2 is clicked

	CMP r0,#4
	BEQ switch3_clicked ;check is switch 3 is clicked

	CMP r0,#2
	BEQ switch4_clicked;check is switch 4 is clicked

	CMP r0,#1
	BEQ switch5_clicked ;check is switch 5 is clicked


switch2_clicked:

	LDR r4,ptr_to_switch2
	BL convert_to_int ;loads the count from memory and converts it to int
	ADD r1,r1,#1 ;increments the count

	LDR r4,ptr_to_switch2
	MOV r0,r1
	BL convert_to_ascii ;converts it to ascii and store the updated count in memory

	BL outputstrings ;prints the prompt along with the updated count
	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character

	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character
	MOV r0,#0
	B switch_exit

switch3_clicked:
	LDR r4,ptr_to_switch3
	BL convert_to_int ;loads the count from memory and converts it to int
	ADD r1,r1,#1 ;increments the count

	LDR r4,ptr_to_switch3 ;converts it to ascii and store the updated count in memory
	MOV r0,r1
	BL convert_to_ascii

	BL outputstrings ;prints the prompt along with the updated count
	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character

	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character
	MOV r0,#0
	B switch_exit

switch4_clicked:
	LDR r4,ptr_to_switch4 ;loads the count from memory and converts it to int
	BL convert_to_int
	ADD r1,r1,#1 ;increments the count

	LDR r4,ptr_to_switch4 ;converts it to ascii and store the updated count in memory
	MOV r0,r1
	BL convert_to_ascii

	BL outputstrings ;prints the prompt along with the updated count
	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character

	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character
	MOV r0,#0
	B switch_exit

switch5_clicked:

	LDR r4,ptr_to_switch5 ;loads the count from memory and converts it to int
	BL convert_to_int
	ADD r1,r1,#1 ;increments the count

	LDR r4,ptr_to_switch5;converts it to ascii and store the updated count in memory
	MOV r0,r1
	BL convert_to_ascii

	BL outputstrings ;prints the prompt along with the updated count
	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character

	MOV r0,#10 ;print the new line
	BL output_character
	MOV r0,#13;print the cr
	BL output_character
	MOV r0,#0
	B switch_exit

switch_exit:
	MOV r5,#0x4240 ;debounce
	MOVT r5,#0xF
debloop:
	SUB r5,r5,#1
	CMP r5,#0
	BNE debloop
 	; Your code is placed here
 	LDMFD sp!, {lr}
 	BX lr

lab5exit:
	LDR r4, ptr_to_exit_prompt
	BL output_string
	LDMFD sp!, {r0-r12,lr}
 	MOV pc, lr
 	.end



