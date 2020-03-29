	.data
	.global userinput
userinput:	.string "123456",0 ;user input stored in memory

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
	.global lab4
	.global convert_to_int
	.global clearmem
	.global replace_cr
	.global div_and_mod

main_prompt: .string "MENU: Enter a number to pick an option: ",0
options_prompt: .string "1 - LEDs, 2 - Push Buttons, 3 - RGB LED, 4 - Keypad, 5 - quit: ",0
led_prompt: .string "Enter a number (0 to 15) to display the number in binary on the LEDs and then press enter. Enter 16 to exit: ",0
pushbtn_prompt: .string "Push a combination of the push button at the same time and then hit enter on the keyboard to display its Hex value. Press 1 to exit. ",0
pushbtn_prompt1: .string "Hex value pushed: ",0
keypad_prompt: .string "Push a key (0 to 9) to be displayed: ",0
rgb_prompt:	.string "Select a number to illuminate the RGB LED",0
rgb_prompt1:	.string"0 - Off, 1 - Red, 2 - Blue, 3 - Purple, 4 - Green, 5 - Yellow, 6 - Exit, 7 - White: ",0
exit_prompt: 	.string"Goodbye",0


ptr_to_main_prompt: .word main_prompt
ptr_to_options: .word options_prompt
ptr_to_led: .word led_prompt
ptr_to_pushbtn: .word pushbtn_prompt
ptr_to_pushbtn1: .word pushbtn_prompt1
ptr_to_keypad: .word keypad_prompt
ptr_to_rgb: .word rgb_prompt
ptr_to_rgb1: .word rgb_prompt1
ptr_to_input:	.word userinput
ptr_to_exit: .word exit_prompt

lab4:
	STMFD SP!,{lr}
lab4loop:
	LDR r4, ptr_to_input
	BL clearmem

	LDR r4, ptr_to_main_prompt
	BL output_string
	MOV r0,#13
	BL output_character ;outputs the menu prompt
	MOV r0,#10
	BL output_character
	LDR r4, ptr_to_options
	BL output_string

	BL read_character
	BL output_character ;reads the user input
	MOV r2,r0 ; store the input in a temp register
	MOV r0,#13
	BL output_character
	MOV r0,#10
	BL output_character
	MOV r0,#10
	BL output_character
	MOV r0,r2 ; store back the user inpur to r0

	SUB r0,r0,#48;converts the user input to an int

	CMP r0, #1 ; if user input is 1, they chose LED option
	BEQ lab4led

	CMP r0,#2 ; if user input is 2, they chose push buttons
	BEQ lab4pushbut

	CMP r0,#3 ;if user input is 3, they chose rgb led
	BEQ lab4rgb

	CMP r0,#4 ; if user input is 4, they chose the keypad
	BEQ lab4keypad
	CMP r0,#5
	BEQ lab4done


lab4led: ; led routine
	LDR r4,ptr_to_led
	BL output_string ;outputs the prompt for led

	LDR r4, ptr_to_input ; read the input
	BL read_string
	LDR r4, ptr_to_input ; replaces the cr with null
	BL replace_cr

	LDR r4, ptr_to_input ; converts the input to int and stores in r1
	BL convert_to_int; returns in r1

	MOV r0,#13
	BL output_character ;outputs newline
	MOV r0,#10
	BL output_character

	MOV r0,r1
	CMP r0,#16 ;if user inputs 16, it goes back to the main menu
	BEQ lab4loop

	BL illuminate_LEDs ;illuminates the led based on user input
	B lab4led ; loops back


lab4pushbut: ; routine for push button
	LDR r4, ptr_to_pushbtn ;outputs the pushbutton prompt
	BL output_string
loop_push:
	BL read_character
	CMP r0,#49 ; if the user enters 1, it exits the routine and back to main menu
	BEQ pushtbutdone

	CMP r0,#13 ; see if the user pressed enter
	BNE loop_push ; if its not, the loops back to the beginning

	MOV r0,#13
	BL output_character ;outputs new line
	MOV r0,#10
	BL output_character

	BL read_from_push_btns ; calls the pushbutton read routine

	CMP r0,#10 ;compares the input with 10
	BLT singledig ;checks if it is less than
	ADD r0,r0,#55 ; if it isnt, adds 55 to get the letter parts of hex
	B pushbutoutput
singledig:
	ADD r0,r0,#48 ;if it is a single digit, it will convert it to a number
pushbutoutput:
	MOV r2,r0 ; moves the temp register to r2
	LDR r4, ptr_to_pushbtn1 ;outputs the second prmompt of pushbutton
	BL output_string
	MOV r0,r2  ;moves the answer to r0
	BL output_character ; ouputs the answer

	MOV r0,#13
	BL output_character
	MOV r0,#10
	BL output_character ; outputs new line
	MOV r0,#10
	BL output_character

	B lab4pushbut ;loops back

pushtbutdone:
	MOV r0,#13
	BL output_character
	MOV r0,#10
	BL output_character ; outputs new line
	MOV r0,#10
	BL output_character
	B lab4loop ; loops back to main menu


lab4rgb: ; rgb led routine
	LDR r4,ptr_to_rgb
	BL output_string ; outputs the prompt for rgb

	MOV r0,#13
	BL output_character
	MOV r0,#10 ; output the new line
	BL output_character

	LDR r4,ptr_to_rgb1 ;outputs the second prompt for rgb
	BL output_string

	BL read_character
	BL output_character ; reads user input
	MOV r2,r0
	SUB r2,r2,#48 ;converts the input to int

	MOV r0,#13
	BL output_character ;outputs new line
	MOV r0,#10
	BL output_character
	MOV r0,#10
	BL output_character

	MOV r0, r2
	CMP r0, #6 ; check if its 6. if it is, it goes back to main menu
	BEQ lab4loop
	BL illuminate_RGB_LED ;illumates the rgb
	B lab4rgb ;loops back to ask for another input for rgb


lab4keypad: ;keypad routine

	LDR r4, ptr_to_keypad
	BL output_string ;outputs the prompt for keypad
keypadloop:
	BL read_keypad ;calls the readkeypad routine
	CMP r0,#0
	BEQ keypadloop ;keeps calling readkeypd if nothing is pressed

	BL output_character ; outputs the key pressed

	MOV r0,#13
	BL output_character
	MOV r0,#10 ;outputs new line
	BL output_character
	MOV r0,#10
	BL output_character

	B lab4loop ;goes to main menu


lab4done:
	LDR r4,ptr_to_exit ;outputs the exit prompt
	BL output_string
	LDMFD SP!, {lr}
	BX lr
	.end
