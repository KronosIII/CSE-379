	.data
score:	.string 12,27,"[33m         Score:  ",27,"[32m"
score_data: .string "0",0,0,0,0,0,0
board:	.string 10,13,27,"[37m +---------------------------+ ",10,13
		.string		  	     " |O.....|.............|.....O| ",10,13
		.string		  		 " |.+--+.|.-----------.|.+--+.| ",10,13
		.string		  		 " |.|  |.................|  |.| ",10,13
		.string		  	 	 " |.+--+.|--|-|-|-|-|--|.+--|.| ",10,13
lefttun:.string		  		 " [......|   "
ghost_box: .string						 "          |......] ",10,13
righttun:.string		  	 " |.|--+.|-------------|.+--|.| ",10,13
		.string		  		 " |.|  |........"
position:	.string 		      		    "<........|  |.| ",10,13
		.string		  		 " |.+--+.|.-----------.|.+--+.| ",10,13
		.string		  		 " |O.....|.............|.....O| ",10,13
		.string		  		 " +---------------------------+ ",10,13,0

direction:	.string "j",0,0,0
prev_dir:	.string "j",0,0,0
lives:		.string "3",0
game_end:	.string 12,27,"[31mGAME OVER.",10,13,"Your score is: ",0
pellet_count:	.string "0",0,0,0,0
pause_flag:	.string "0",0,0,0
power_pellet_flag:	.string "0",0
startmenu:	.string 12,27,"[36mHello, welcome to pacman. Use i,j,k and m keys to move pacman around.",10,13,"Press space to start the game",10,13,"Press p to pause the game.",10,13,0
ghost_eaten:.string "0",0,0,0
ghost1: .long 0
ghost2:	.long 2;70
ghost3:	.long 4;71
ghost4:	.long 6;72

ghost1_dir: .long 0
ghost2_dir: .long 0
ghost3_dir: .long 0
ghost4_dir: .long 0

ghost1direction:	.string 0,0,0,0,0

ghost_in_respawn: .long 0
ghost_char: .string "M",0,0

orig_board:	.string 10,13,27,"[37m +---------------------------+ ",10,13
			.string		  	     " |O.....|.............|.....O| ",10,13
			.string		  		 " |.+--+.|.-----------.|.+--+.| ",10,13
			.string		  		 " |.|  |.................|  |.| ",10,13
			.string		  	 	 " |.+--+.|------+------|.+--|.| ",10,13
			.string		  		 "  ......|             |......  ",10,13
			.string		  	 	 " |.|--+.|-------------|.+--|.| ",10,13
			.string		  		 " |.|  |........<........|  |.| ",10,13
			.string		  		 " |.+--+.|.-----------.|.+--+.| ",10,13
			.string		  		 " |O.....|.............|.....O| ",10,13
			.string		  		 " +---------------------------+ ",10,13,0
paused:	.string 12,27,"[36mPAUSED",10,13
		.string			  "Game is paused.",10,13
		.string 	      "Press 1 to unpause game.",10,13
		.string			  "Press 2 to end game.",10,13
		.string			  "Press 3 to restart game.",10,13,0
.text
	.global uart_init
 	.global output_character
 	.global read_character
 	.global output_string
	.global UART0_Handler
 	.global Switches_Handler
 	.global Timer0_Handler
 	.global Timer1_Handler
 	.global interrupt_init
 	.global lab7
 	.global convert_to_int
 	.global convert_to_ascii
 	.global illuminate_RGB_LED
 	.global gpio_init
 	.global randomnum
 	.global points_add_from_ghosts
 	.global in_respawn
 	.global check_wall
 	.global randomnum_left_or_right
ptr_to_ghost1direction: .word ghost1direction
ptr_to_ghost1_dir:	.word ghost1_dir
ptr_to_ghost2_dir:	.word ghost2_dir
ptr_to_ghost3_dir:	.word ghost3_dir
ptr_to_ghost4_dir:	.word ghost4_dir
ptr_to_ghost_char: .word ghost_char
ptr_to_gb: .word ghost_box
ptr_to_gir: .word ghost_in_respawn
ptr_to_ghost1:	.word ghost1
ptr_to_ghost2:	.word ghost2
ptr_to_ghost3:	.word ghost3
ptr_to_ghost4:	.word ghost4
ptr_to_ghost_eaten: .word ghost_eaten
ptr_to_paused: .word paused
ptr_to_orig_board:	.word orig_board
ptr_to_power_pellet_flag: .word power_pellet_flag
ptr_to_startmenu: .word startmenu
ptr_to_pellet_count: .word pellet_count
ptr_to_pause_flag: .word pause_flag
ptr_to_left: .word lefttun
ptr_to_right: .word righttun
ptr_to_score:	.word score
ptr_to_score_data:	.word score_data
ptr_to_board:	.word board
ptr_to_position: .word position
ptr_to_direction:	.word direction
ptr_to_prev_dir:	.word prev_dir
ptr_to_game_end:	.word game_end
ptr_to_lives:	.word lives
;r7 is score
;r8 is offset
lab7:
	STMFD SP!,{r6-r12,lr}
	BL uart_init ;initialize the uart
	BL gpio_init

	LDR r4, ptr_to_startmenu;outputs the menu
	BL output_string

startloop:
	BL read_character
	CMP r0,#32
	BNE startloop

	MOV r7,#0; score
	MOV r8,#0 ;offset
	MOV r6,#0; 8 seconds
	BL interrupt_init ;initializes the interrupts
	LDR r4,ptr_to_score
	BL output_string ;outputs the score

	LDR r4, ptr_to_board ;outputs the board
	BL output_string

lab7loop:
	LDR r4,ptr_to_lives
	LDRB r2,[r4]
	CMP r2,#48
	BGT lab7loop
	LDR r4,ptr_to_game_end
	BL output_string
	MOV r0,r7 ;copies the score to r0
	LDR r4, ptr_to_score_data
	BL output_string

	B lab7exit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pellet_count_routine:
	STMFD SP!,{r0-r12,lr}
	LDR r4,ptr_to_pellet_count
	BL convert_to_int
	ADD r1,r1,#1
	MOV r0,r1
	LDR r4,ptr_to_pellet_count
	BL convert_to_ascii
	LDMFD sp!, {r0-r12,lr}
	MOV pc, lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reg_ghost:
	STMFD SP!,{r0,r2-r6,r9-r12,lr}
	LDR r4,ptr_to_position
	ADD r4,r4,r8 ;loads the address of pacman's position

	LDR r5,ptr_to_gb ;address for ghost spawn box
	LDR r6,ptr_to_ghost1 ;the offset value for ghost1
	LDR r2,[r6]
	ADD r3,r5,r2 ;current position of ghost1
	CMP r4,r3 ;check if they are equal
	ITT EQ
	MOVEQ r1,#0 ;set a flag to 0
	BEQ isghost

checkg2:
	LDR r6,ptr_to_ghost2 ;address for ghost spawn box
	LDR r2,[r6] ;the offset value for ghost2
	ADD r3,r5,r2 ;current position of ghost2
	CMP r4,r3;check if they are equal
	ITT EQ
	MOVEQ r1,#0;set a flag to 0
	BEQ isghost

checkg3:
	LDR r6,ptr_to_ghost3 ;address for ghost spawn box
	LDR r2,[r6];the offset value for ghost3
	ADD r3,r5,r2;current position of ghost3
	CMP r4,r3;check if they are equal
	ITT EQ
	MOVEQ r1,#0
	BEQ isghost

checkg4:
	LDR r6,ptr_to_ghost4 ;address for ghost spawn box
	LDR r2,[r6];the offset value for ghost4
	ADD r3,r5,r2;current position of ghost4
	CMP r4,r3;check if they are equal
	ITT EQ
	MOVEQ r1,#0;set a flag to 0
	BEQ isghost
	B regghostexit
isghost: ;this is for wen pacman encounters a ghost
	LDR r4,ptr_to_ghost_char
	LDRB r3,[r4] ;check if the ghost is a big ghost
	CMP r3,#77
	BEQ bigghost

	LDR r4,ptr_to_ghost_eaten
	LDRB r0,[r4] ;loads the ghost eaten from memory
	SUB r0,r0,#48 ;convert it to int
	MOV r1,r7 ;copy the score to r1
	BL points_add_from_ghosts ;calls the function in C
	MOV r7,r0 ;copy the new score in r7

	LDR r4,ptr_to_ghost_eaten
	LDRB r3,[r4]
	ADD r3,r3,#1 ;increments the ghost eaten
	STRB r3,[r4] ;stores it back into memory

	CMP r3,#52 ;check if the ghost eaten is 4
	ITT EQ
	MOVEQ r3,#48 ; if it is, reset it back to 0
	STRBEQ r3,[r4]

	LDR r4,ptr_to_gir
	LDR r1,[r4] ;loads how many ghost are in the respawn
	STR r1,[r6] ;stores it in the ghost offset
	ADD r1,r1,#2 ;increments it so the ghost dont overlap in the ghost repawn
	STRB r1,[r4]
	MOV r1,#0 ;sets the flag to 0

	B regghostexit

bigghost: ;when pacman encounters the bigghost
	LDR r4,ptr_to_lives
	LDRB r1,[r4] ;load the lives
	SUB r1,r1,#1 ;decrement lives
	STRB r1,[r4]

	LDR r4,ptr_to_position
	ADD r4,r4,r8 ;address to current position
	MOV r2,#32 ;char for space
	;STRB r2,[r4,r9]
	STRB r2,[r4]

	LDR r4,ptr_to_position
	MOV r2,#60 ;char for pacman
	STRB r2,[r4] ;stores it in on the board
	MOV r8,#0

	MOV r2,#106
	LDR r4,ptr_to_direction ;put direction to j
	STRB r2,[r4]
	MOV r1,#1 ;set a flag to 1
regghostexit:
	LDMFD sp!, {r0,r2-r6,r9-r12,lr}
	MOV pc, lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

newlevel:
	STMFD SP!,{r0-r7,r9-r12,lr}
	LDR r4,ptr_to_ghost1 ;reset the offset for the ghosts
 	MOV r0,#0
 	STR r0,[r4]
 	LDR r4,ptr_to_ghost2
 	MOV r0,#2
 	STR r0,[r4]
 	LDR r4,ptr_to_ghost3
 	MOV r0,#4
 	STR r0,[r4]
	LDR r4,ptr_to_ghost4
 	MOV r0,#6
 	STR r0,[r4]

	MOV r8,#0 ;reset the offset

	MOV r4,#0x0028
	MOVT r4,#0x4003 ;pacman interval period;
	LDR r2,[r4] ;loads the intervel

	MOV r3,#75
	MUL r2,r2,r3
	MOV r3,#100
	UDIV r2,r2,r3;increases it by 25%
	STR r2,[r4]

	MOV r4,#0x1028
	MOVT r4,#0x4003 ;ghost interval period
	LDR r2,[r4] ;loads the intervel
	MOV r3,#75
	MUL r2,r2,r3
	MOV r3,#100
	UDIV r2,r2,r3;increases it by 25%
	STR r2,[r4]

	MOV r2,#106
	LDR r4,ptr_to_direction ;put direction to j
	STRB r2,[r4]

	LDR r4,ptr_to_pellet_count
	MOV r0,#48
	STRB r0,[r4],#1
	MOV r0,#0
	STRB r0,[r4],#1 ;clears the pellet count in memory
	STRB r0,[r4],#1
	STRB r0,[r4]

	LDR r0,ptr_to_board
	LDR r1,ptr_to_orig_board
newlevloop:
	LDRB r2,[r1],#1 ;loads the character from original board
	STRB r2,[r0],#1 ;stores it in the playing board
	CMP r2,#0 ;if the char is not the null byte, it will loop back
	BNE newlevloop
	LDMFD sp!, {r0-r7,r9-r12,lr}
	MOV pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UART0_Handler:
 	STMFD SP!,{r3-r6,r9-r12,lr}
 	; Store register lr on stack
 	BL read_character ;reads keyboard input for direction

	CMP r0,#112 ;checks if the character is p
	BEQ pressedp
	B checkpause
pressedp:
	LDR r4,ptr_to_pause_flag
	MOV r2,#49 ;make the pause flag to 1
	STRB r2,[r4]
	LDR r4,ptr_to_paused ;output the pause menu
	BL output_string
	B uartexit

checkpause:
	LDR r4,ptr_to_pause_flag
	LDRB r1,[r4]
	CMP r1,#49 ;check if the pause flag is 1
	BEQ ispaused
	B pause_flag_0

ispaused: ;if the pause flag is 1
	CMP r0,#49
	BEQ check1 ;check if the user enters 1
	CMP r0,#50
	BEQ check2 ;checks if the user enters 2
	CMP r0,#51
	BEQ check3;checks if the user enters 3
	B uartexit
check1:
	LDR r4,ptr_to_pause_flag
	MOV r1,#48 ;makes the pause flag to 0
	STRB r1,[r4]
	B uartexit

check2:
	LDR r4,ptr_to_pause_flag
	MOV r1,#48  ;make the pause flag to 0
	STRB r1,[r4]
	LDR r4,ptr_to_lives
	MOV r2,#0 ;make the lives to 0 so it makes the game over
	STRB r2,[r4]
	B uartexit
check3:
	BL newlevel
	LDR r4,ptr_to_pause_flag
	MOV r1,#48 ;makes the pause flag to 0
	STRB r1,[r4]
	MOV r7,#0

	MOV r4,#0x0028
	MOVT r4,#0x4003 ; interval period for pacman;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOV r0,#0x1200
	MOVT r0,#0x7A
	STR r0,[r4]

	MOV r4,#0x1028
	MOVT r4,#0x4003 ; interval period for ghosts;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOV r0,#0x6155
	MOVT r0,#0x51
	STR r0,[r4]

	B uartexit
pause_flag_0:
	LDR r4,ptr_to_direction ;loads current direction
	LDRB r5,[r4]
	LDR r4,ptr_to_prev_dir ;put it in the prev
	STRB r5,[r4]

	CMP r0,r5 ;compares the keyboard press with previous direction
 	BEQ uartexit

 	LDR r4,ptr_to_direction ;if its not the same
 	STRB r0,[r4] ;store the new keypress in direction
 	B uartexit

uartexit:
	MOV r4,#0xC044 ;clear interrupt for rxim bit
	MOVT r4,#0x4000
	LDR r3,[r4]
	ORR r3,r2,#16
	STR r3,[r4]
	LDMFD sp!, {r3-r6,r9-r12,lr}
 	BX lr
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Timer1_Handler:;ghost timer
 	STMFD SP!,{r0,r1,r4,r6,r9-r12,lr}
 	MOV r0,#93
	LDR r4,ptr_to_right ;put the barriers for the rihgt tunnel
	SUB r4,r4,#4
	STRB r0,[r4]

	MOV r0,#91
	LDR r4,ptr_to_left ;barrier for the left tunnel
	ADD r4,r4,#1
	STRB r0,[r4]

 	LDR r4,ptr_to_pause_flag
	LDRB r1,[r4] ;check if the pause flag is 1
	CMP r1,#49
	BEQ timer1exitpause

	LDR r5,ptr_to_ghost1
	LDR r9,ptr_to_ghost1_dir
	BL ghost_movement

	LDR r9,ptr_to_ghost2_dir
	LDR r5,ptr_to_ghost2
	BL ghost_movement

	LDR r9,ptr_to_ghost3_dir
	LDR r5,ptr_to_ghost3
	BL ghost_movement

	LDR r9,ptr_to_ghost4_dir
	LDR r5,ptr_to_ghost4
	BL ghost_movement
timer1exit:
	MOV r0,r7 ;copies the score to r0
	LDR r4, ptr_to_score_data
	BL convert_to_ascii ;stores the score in memory
	LDR r4,ptr_to_score
	BL output_string ;outputs the score

	LDR r4, ptr_to_board ;outputs the board
	BL output_string

timer1exitpause:
 	MOV r4,#0x1024
	MOVT r4,#0x4003
	LDR r9,[r4]
	ORR r9,r8,#1 ;clear interrupts
	STR r9,[r4]

 	LDMFD sp!, {r0,r1,r4,r6,r9-r12,lr}
 	BX lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ghost_movement: ;r5 -address of the offset value for the ghost,r9- direction address
 	STMFD SP!,{r0-r12,lr}
	LDR r0,[r5]
	BL in_respawn ;check if ghost is in respawn
	CMP r0,#0 ;if it isnt
	BEQ checkpacman
	;BEQ ghostmoveexit
	LDR r4,ptr_to_power_pellet_flag
	LDRB r1,[r4]
	CMP r1,#48
	BEQ out_of_respawn
	B ghostmoveexit

out_of_respawn:
	LDR r1,[r5]
	MOV r0,#66
	SUB r1,r1,r0 ;move the ghosts out of respawn
	STR r1,[r5]
	LDR r4,ptr_to_gir
	MOV r0,#0
	;LDR r0,[r4]
	;SUB r0,r0,#1
	STR r0,[r4]

	BL randomnum_left_or_right
	STR r0,[r9]

	B ghostmoveexit
	;;;do it when the ghost can move out of respawn

checkpacman:
	LDR r3,[r5]
	LDR r4,ptr_to_gb
	ADD r4,r4,r3

	MOV r1,#-1 ;left
	PUSH {r1}
	BL is_pacman_around
	POP {r1}
	CMP r0,#0 ;check if pacman is around
	BEQ checkdown

	LDR r4,ptr_to_power_pellet_flag
	LDRB r6,[r4]
	CMP r6,#49 ;check the power pellet flag
	BEQ goawayleft

	LDR r3,[r5]
	ADD r3,r3,r1 ;move the ghost left
	STR r3,[r5];update the offset
	STR r1,[r9] ;storing the direction to mem
	B ghostmoveexit

goawayleft:;; for going away from pacman;;;;; continue here
	LDR r3,[r5] ;load the offset value to the right
	SUB r3,r3,r1 ;increment offset to go right
	LDR r4,ptr_to_gb
	LDRB r0,[r4,r3] ;load the char on the board
	BL check_wall
	CMP r0,#0 ;check if there is a wall to the right
	ITTTT EQ ;if its not a wall
	STREQ r3,[r5] ;update the offset to the right
	MOVEQ r10,#1
	STREQ r10,[r9]
	BEQ ghostmoveexit

	LDR r3,[r5]
	MOV r10,#33
	SUB r3,r3,r10
	LDRB r0,[r4,r3] ;load the char upward
	BL check_wall
	CMP r0,#0 ;check if there is a wall upward
	ITTTT EQ ; if its not wall
	STREQ r3,[r5] ;update the offset upwards
	RSBEQ r10,r10,#0
	STREQ r10,[r9] ;store the direction updwards
	BEQ ghostmoveexit

	LDR r3,[r5]
	MOV r10,#33
	ADD r3,r3,r10
	LDRB r0,[r4,r3] ;load the offset below the current position
	BL check_wall
	CMP r0,#0 ;check if there is a wall
	ITTT EQ ;if there isnt a wall
	STREQ r3,[r5] ;update the offset downwards
	STREQ r10,[r9] ;store the direction downwards
	BEQ ghostmoveexit

checkdown:
	MOV r1,#33 ;down
	BL is_pacman_around
	CMP r0,#0
	BEQ checkright

	LDR r4,ptr_to_power_pellet_flag
	LDRB r6,[r4]
	CMP r6,#49 ;check if pacman is powerd
	BEQ goawaydown

	LDR r3,[r5] ;if not, move the ghost down (towards pacman)
	ADD r3,r3,r1
	STR r3,[r5] ;update the offset of the ghost to go down
	STR r1,[r9] ;update the direction to down

	B ghostmoveexit

goawaydown:
	LDR r3,[r5] ;load the offset value
	SUB r3,r3,r1 ;increment offset to go up
	LDR r4,ptr_to_gb
	LDRB r0,[r4,r3] ;load the char on the board
	BL check_wall
	CMP r0,#0 ;check if there is a wall upwards
	ITT EQ ;if its not a wall
	STREQ r3,[r5] ;update the offset upwards
	BEQ ghostmoveexit

	LDR r3,[r5]
	MOV r10,#1
	SUB r3,r3,r10
	LDRB r0,[r4,r3] ;load the char left
	BL check_wall
	CMP r0,#0 ;check if there is a wall leftward
	ITTTT EQ ; if its not wall
	STREQ r3,[r5] ;update the offset leftward
	MOVEQ r10,#-1
	STREQ r10,[r9] ;store left to the direction
	BEQ ghostmoveexit

	LDR r3,[r5]
	MOV r10,#1
	ADD r3,r3,r10
	LDRB r0,[r4,r3] ;load the offset right of the current position
	BL check_wall
	CMP r0,#0 ;check if there is a wall
	ITTT EQ ;if there isnt a wall
	STREQ r3,[r5] ;update the offset rightwards
	STREQ r10,[r9] ;store the direction
	BEQ ghostmoveexit

checkright:
	MOV r1,#1 ;rihgt
	BL is_pacman_around ;check if pacman is around
	CMP r0,#0
	BEQ checkup

	LDR r4,ptr_to_power_pellet_flag
	LDRB r6,[r4]
	CMP r6,#49 ;check if pacman is powered
	BEQ goawayright
	LDR r3,[r5]
	ADD r3,r3,r1 ;if it isnt, move towards pacman
	STR r3,[r5]
	STR r1,[r9]
	B ghostmoveexit

goawayright:
	LDR r3,[r5] ;load the offset value
	SUB r3,r3,r1 ;increment offset to go right
	LDR r4,ptr_to_gb
	LDRB r0,[r4,r3] ;load the char on the board
	BL check_wall
	CMP r0,#0 ;check if there is a wall to the left
	ITT EQ ;if its not a wall
	STREQ r3,[r5] ;update the offset to the left
	BEQ ghostmoveexit

	LDR r3,[r5]
	MOV r10,#33
	ADD r3,r3,r10
	LDRB r0,[r4,r3] ;load the char down
	BL check_wall
	CMP r0,#0 ;check if there is a wall downward
	ITTTT EQ ; if its not wall
	STREQ r3,[r5] ;update the offset downward
	MOVEQ r10,#33
	LDREQ r10,[r9] ;update the direction
	BEQ ghostmoveexit

	LDR r3,[r5]
	MOV r10,#33
	SUB r3,r3,r10
	LDRB r0,[r4,r3] ;load the offset upwards of the current position
	BL check_wall
	CMP r0,#0 ;check if there is a wall
	ITTTT EQ ;if there isnt a wall
	STREQ r3,[r5] ;update the offset upwards
	RSBEQ r10,r10,#0
	STREQ r10,[r9] ;store the direction
	BEQ ghostmoveexit

	LDR r3,[r5]
	ADD r3,r3,r1
	STR r3,[r5]
	B ghostmoveexit

checkup:
	MOV r1,#33 ;up
	RSB r1,r1,#0
	BL is_pacman_around ;check if pacman is around
	CMP r0,#0 ;if it isnt
	BEQ moverandomly ;branch

	LDR r4,ptr_to_power_pellet_flag
	LDRB r6,[r4]
	CMP r6,#49 ;check if pacman is powered
	BEQ goawayup
	LDR r3,[r5]
	ADD r3,r3,r1
	STR r3,[r5] ;if it isnt, go towards pacman
	STR r1,[r9]
	B ghostmoveexit

goawayup:
	LDR r3,[r5] ;load the offset value
	SUB r3,r3,r1 ;increment offset to go up
	LDR r4,ptr_to_gb
	LDRB r0,[r4,r3] ;load the char on the board
	BL check_wall
	CMP r0,#0 ;check if there is a wall upwards
	ITT EQ ;if its not a wall
	STREQ r3,[r5] ;update the offset tupwards
	BEQ ghostmoveexit

	LDR r3,[r5]
	MOV r10,#1
	SUB r3,r3,r10
	LDRB r0,[r4,r3] ;load the char left
	BL check_wall
	CMP r0,#0 ;check if there is a wall left
	ITTTT EQ ; if its not wall
	STREQ r3,[r5] ;update the offset left
	MOVEQ r10,#-1
	LDREQ r10,[r9] ;update the direction
	BEQ ghostmoveexit

	LDR r3,[r5];;;;;;;;;;;;;
	MOV r10,#1
	ADD r3,r3,r10
	LDRB r0,[r4,r3] ;load the offset right of the current position
	BL check_wall
	CMP r0,#0 ;check if there is a wall
	ITTT EQ ;if there isnt a wall
	STREQ r3,[r5] ;update the offset rightwards
	STREQ r10,[r9] ;store the direction
	BEQ ghostmoveexit

moverandomly:

	LDR r10,[r9] ;direction
	LDR r11,[r5] ;offset
	LDR r4,ptr_to_gb
	ADD r11,r4,r11 ;get the current address of the ghost
	LDRB r0,[r11,r10] ;load the char ahead of the ghost depending on the direction
	BL check_wall
	CMP r0,#0
	BEQ not_walled


	MOV r3,#0;counter
	LDRB r0,[r11,#-1];left of the ghost
	PUSH {r3}
	BL check_wall
	POP {r3}
	ADD r3,r3,r0
	LDRB r0,[r11,#1];right of the ghost
	PUSH {r3}
	BL check_wall
	POP {r3}
	ADD r3,r3,r0
	LDRB r0,[r11,#33];bottom of the ghost
	PUSH {r3}
	BL check_wall
	POP {r3}
	ADD r3,r3,r0
	MOV r2,#33
	RSB r2,r2,#0
	LDRB r0,[r11,r2];right of the ghost
	PUSH {r3}
	BL check_wall
	POP {r3}
	ADD r3,r3,r0


	CMP r3,#1 ;check if its a junction
	BGT loop_random

	LDRB r0,[r11,#-1];left of the ghost
	MOV r12,r0
	BL check_wall
	CMP r0,#1
	BEQ rightdir

	CMP r10,#1
	BEQ rightdir
	MOV r3,#-1
	STR r3,[r9]
	B ghostmoveexit
rightdir:
	LDRB r0,[r11,#1];left of the ghost
	MOV r12,r0
	BL check_wall
	CMP r0,#1
	BEQ downdir

	CMP r10,#-1
	BEQ downdir
	MOV r3,#1
	STR r3,[r9]
	B ghostmoveexit
downdir:
	LDRB r0,[r11,#33];left of the ghost
	MOV r12,r0
	BL check_wall
	CMP r0,#1
	BEQ updir
	MOV r3,#33
	RSB r3,r3,#0
	CMP r10,r3
	BEQ updir

	MOV r3,#33
	STR r3,[r9]
	B ghostmoveexit
updir:
	MOV r3,#33
	RSB r3,r3,#0
	STR r3,[r9]
	B ghostmoveexit
loop_random:
	BL randomnum
	MOV r6,r0
	LDRB r2,[r11,r0] ;load the char in direction returned
	MOV r0,r2
	PUSH {r2}
	BL check_wall ;check if that char is a wall
	POP {r2}
	CMP r0,#1 ;if it is, gets another random diretion
	BEQ loop_random

	;RSB r12,r6,#0
	;CMP r12,r10
	;BEQ loop_random

	STR r6,[r9] ;stores the direction in memory
	LDR r0,[r5]
	ADD r0,r0,r6 ;increases the offset
	STR r0,[r5] ;store in the offset in mem
	B ghostmoveexit

not_walled:
	MOV r3,#0;counter
	LDRB r0,[r11,#-1];left of the ghost
	PUSH {r3}
	BL check_wall
	POP {r3}
	ADD r3,r3,r0
	LDRB r0,[r11,#1];right of the ghost
	PUSH {r3}
	BL check_wall
	POP {r3}
	ADD r3,r3,r0
	LDRB r0,[r11,#33];bottom of the ghost
	PUSH {r3}
	BL check_wall
	POP {r3}
	ADD r3,r3,r0
	MOV r2,#33
	RSB r2,r2,#0
	LDRB r0,[r11,r2];right of the ghost
	PUSH {r3}
	BL check_wall
	POP {r3}
	ADD r3,r3,r0

	CMP r3,#1 ;check if its a junction
	BGT same_direction

loop_random1:
	BL randomnum
	LDRB r2,[r11,r0] ;load the char in direction returned
	MOV r6,r0
	MOV r0,r2
	PUSH {r2}

	BL check_wall ;check if that char is a wall
	POP {r2}
	CMP r0,#1 ;if it is, gets another random diretion
	BEQ loop_random1

	;RSB r12,r6,#0
	;CMP r12,r10
	;BEQ loop_random1

	STR r6,[r9] ;stores the direction in memory
	LDR r0,[r5]
	ADD r0,r0,r6 ;increases the offset
	STR r0,[r5] ;store in the offset in mem
	B ghostmoveexit

same_direction:
	LDR r0,[r5];load the offset of the ghost
	LDR r1,[r9];load th direction
	ADD r0,r0,r1;update the offset
	STR r0,[r5]

ghostmoveexit:

 	LDMFD sp!,{r0-r12,lr}
 	MOV pc, lr
 	;;;;;;;;;;;;;;;;;;;;;;;;;;

moveghosts:
	STMFD SP!,{r1-r12,lr};

	LDMFD sp!,{r1-r12,lr}
 	MOV pc, lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
is_pacman_around:
 	STMFD SP!,{r1-r12,lr};r1 will be the direction, r0 will return the result

 	MOV r3,#0;counter
	MOV r0,#0;output
ips_loop:
	LDR r6,ptr_to_position
	ADD r6,r6,r8
	ADD r3,r3,#1
 	LDRB r2,[r4,r1] ;load the chracter ahead
 	ADD r4,r4,r1
	PUSH {r1}
	MOV r0,r2
	BL check_wall ;check if its a wall
	POP {r1}
	CMP r0,#1
	ITT EQ
	MOVEQ r0,#0
	BEQ pacmanaroundexit

 	CMP r2,#60 ;check for '<'
 	ITT EQ
 	MOVEQ r0,#1
 	BEQ pacmanaroundexit

 	CMP r3,#4
 	BLT ips_loop

pacmanaroundexit:
 	LDMFD sp!,{r1-r12,lr}
 	MOV pc, lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Timer0_Handler:
 	STMFD SP!,{r0,r1,r4,r5,r9-r12,lr}


 	LDR r4,ptr_to_pause_flag
	LDRB r1,[r4] ;check if the pause flag is 1
	CMP r1,#49
	BEQ timerexitpause

	MOV r9,#0
	BL reg_ghost
	CMP r1,#1
	BEQ timerexit

 	LDR r4,ptr_to_pellet_count
 	BL convert_to_int ;loads the pellet count
 	CMP r1,#119
 	ITT EQ	;reverts the board back to its original for a new level
 	BLEQ newlevel ;reset the board
 	BEQ timerexit

 	LDR r2,ptr_to_power_pellet_flag
	LDRB r3,[r2] ;check if pacman ate the power pellet
	CMP r3,#49
	BNE exec1
	LDR r4, ptr_to_ghost_char
	MOV r0,#109
	STRB r0,[r4]

 	MOV r4,#0x0028
	MOVT r4,#0x4003 ; pacman interval period;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR r0,[r4]
	ADD r6,r6,r0

	MOV r1,#0x2000 ;8seconds
	MOVT r1,#0x7A1

	MOV r3,#0x1028 ;ghost interval
	MOVT r3,#0x4003
	LDR r2,[r3]

	STR r2,[r4] ;stores ghost speed into pacman
	STR r0,[r3]; storing pacman speed into ghost

	MOV r0,#2 ;make the rgb blue
	BL illuminate_RGB_LED

	CMP r6,r1
	BLT exec

	LDR r4, ptr_to_ghost_char
	MOV r0,#77
	STRB r0,[r4]

	LDR r4,ptr_to_ghost_eaten
	MOV r3,#48
	STRB r3,[r4] ;reset the ghost eaten to 0

	MOV r4,#0x0028
	MOVT r4,#0x4003 ; pacman interval period;
	LDR r0,[r4]

	MOV r3,#0x1028 ;ghost interval
	MOVT r3,#0x4003
	LDR r2,[r3]

	STR r2,[r4] ;stores ghost speed into pacman
	STR r0,[r3]; storing pacman speed into ghost

	MOV r6,#0 ;set the 8 second count to 0
	LDR r4,ptr_to_power_pellet_flag
	MOV r1,#48 ;clear the power pellet flag
	STRB r1,[r4]

	LDR r4, ptr_to_lives
	LDRB r1,[r4]

	CMP r1,#51 ;3 lives
	IT EQ
	MOVEQ r0, #4
	CMP r1,#50 ;2 lives
	IT EQ
	MOVEQ r0,#5
	CMP r1,#49 ;1 life
	IT EQ
	MOVEQ r0,#1
	BL illuminate_RGB_LED

	LDR r4,ptr_to_ghost_eaten
	MOV r3,#48
	STRB r3,[r4] ;stores it back into memory


exec1:
	LDR r4, ptr_to_lives
	LDRB r1,[r4]
	CMP r1,#51 ;3 lives
	IT EQ
	MOVEQ r0, #4
	CMP r1,#50 ;2 lives
	IT EQ
	MOVEQ r0,#5
	CMP r1,#49 ;1 life
	IT EQ
	MOVEQ r0,#1

	BL illuminate_RGB_LED
exec:

	LDR r1, ptr_to_left
	LDR r4,ptr_to_position
	ADD r4,r4,r8
	CMP r1,r4 ;checks the address of the left tunnel is equal to the address of the current position
	BNE right_tel ;if its not equal, it will check for the right tunnel

	MOV r0,#32 ;character for space
	LDR r4,ptr_to_left ;load the space for the left tunnel
	STRB r0,[r4] ;replaces pacman with a space

	MOV r0,#60 ;character for pacman (<)
	LDR r4,ptr_to_right ;load the pointer to the right tunnel
	SUB r4,r4,#3 ;offset for the right tunnel address
	STRB r0,[r4] ;write pacman in the right tunnel
	LDR r5,ptr_to_position
	SUB r8,r4,r5 ;updates the offset
	B timermain

right_tel:
	LDR r1, ptr_to_right
	SUB r1,r1,#3
	LDR r4,ptr_to_position
	ADD r4,r4,r8
	CMP r1,r4 ;checks if the right tunnel address if equal to the position address
	BNE timermain ;if it isnt, it goes to the timermain

	MOV r0,#32 ;character for space
	LDR r4,ptr_to_right ;address for the right tunnel
	SUB r4,r4,#3 ;offset to right tunnel address
	STRB r0,[r4] ;writes the space to the right tunnel address

	MOV r0,#60 ;character of pacman (<)
	LDR r4,ptr_to_left ;address of the left tunnel
	STRB r0,[r4] ;stores pacman in the left tunnel
	LDR r5,ptr_to_position
	SUB r8,r4,r5 ;update the new offset


	B timermain

timermain:
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
	B timerexit

k_pressed:
	ADD r8,r8,#1 ;increase the offset to the right of the board
	LDR r4,ptr_to_position
	ADD r4,r4,r8 ;address to the address to the right of pacman
	LDRB r3,[r4] ;loads the char

	CMP r3,#45 ;check if its '-'
	BEQ kwall
	CMP r3,#124 ;check if its '|'
	BEQ kwall
	CMP r3,#43 ;check if its '+'
	BEQ kwall
	B klabel

kwall:
	LDR r4,ptr_to_prev_dir
	LDRB r5,[r4] ;loads the previous direction
	LDR r4,ptr_to_direction ;address to the current direction
	CMP r5,#107 ;check if its k
	BNE kwall1


kwall1: ;if the user hits a key and there is a wall, pacman wont stop
	LDR r4,ptr_to_prev_dir
	LDRB r0,[r4] ;gets the prev direction

	SUB r8,r8,#1

	CMP r0,#109 ;if the prev direction is m
	BEQ m_pressed ;goes to mpressed

	CMP r0,#105 ;if the prev direction is i
	BEQ i_pressed ;foes to ipressed

	CMP r0,#106 ;if the prev direction is j
	BEQ j_pressed ;goes to j pressed

	B timerexit

klabel:
	LDR r4,ptr_to_position ;gets the address of the position
	LDRB r0,[r4,r8] ;loads its with the char with the offset
	CMP r0,#46 ;checks if its a pellet
	ITT EQ
	ADDEQ r7,r7,#10 ;increment the score  by 10
	BLEQ pellet_count_routine

	LDR r4,ptr_to_power_pellet_flag ;load the power pellet flag address
	MOV r1,#49 ;load 1 to r1
	CMP r0,#79 ;check if r0 is the power pellet
	ITTTT EQ
	ADDEQ r7,r7,#50 ;increments the score bby 50
	STRBEQ r1,[r4] ;set the power pellet flag to 1
	MOVEQ r6,#0 ;clear the counter timer
	BLEQ pellet_count_routine
	CMP r0,#79
	ITTT EQ
	LDREQ r4,ptr_to_ghost_char
	MOVEQ r3,#109
	STRBEQ r3,[r4]

checkghost:
	;MOV r9,#-1
	;BL reg_ghost
	;CMP r1,#1
	;BEQ timerexit

	LDR r4,ptr_to_position
	ADD r4,r4,r8
	MOV r0,#60 ;write pacman to the board
	STRB r0,[r4]

	MOV r0,#32
	STRB r0,[r4,#-1] ;make the previous position a space

	MOV r0,#107
	LDR r4,ptr_to_prev_dir
	STRB r0,[r4] ;stores k as the prev position

	B timerexit

m_pressed:
	ADD r8,r8,#33 ;change the offset to 1 space down on the board
	LDR r4,ptr_to_position
	ADD r4,r4,r8 ;add offset to the position address
	LDRB r3,[r4] ;load the char there

	CMP r3,#45 ;check if its '-'
	BEQ mwall
	CMP r3,#124 ;check if its '|'
	BEQ mwall
	CMP r3,#43 ;check if its '+'
	BEQ mwall
	B mlabel

mwall:
	LDR r4,ptr_to_prev_dir
	LDRB r5,[r4] ;load the previous direction
	LDR r4,ptr_to_direction
	CMP r5,#109 ;check if its m
	BNE mwall1


mwall1: ;if the user hits a key and there is a wall, pacman wont stop
	LDR r4,ptr_to_prev_dir
	LDRB r0,[r4] ;load the previous direction
	SUB r8,r8,#33

	CMP r0,#107 ;check if its k
	BEQ k_pressed ;goes to k_pressed

	CMP r0,#105 ;check if its i
	BEQ i_pressed ; goes to ipressed

	CMP r0,#106 ;check if its j
	BEQ j_pressed ;goes to jpressed
	B timerexit

mlabel:
	LDR r4,ptr_to_position
	LDRB r0,[r4,r8] ;load the character at the current position
	CMP r0,#46 ;check if its a pellet
	ITT EQ
	ADDEQ r7,r7,#10 ;increment the score by 10
	BLEQ pellet_count_routine

	LDR r4,ptr_to_power_pellet_flag
	MOV r1,#49 ;chracter for 1
	CMP r0,#79 ;check if the character is a power pellet
	ITTTT EQ
	ADDEQ r7,r7,#50 ;increment the score by 50
	STRBEQ r1,[r4] ;sets the power pellet flag
	MOVEQ r6,#0 ;clear the counter timer
	BLEQ pellet_count_routine

checkghostm:
	;MOV r9,#33
	;RSB r9,r9,#0
	;BL reg_ghost
	;CMP r1,#1
	;BEQ timerexit

	LDR r4,ptr_to_position
	ADD r4,r4,r8 ;address to current position
	MOV r0,#60 ;char for pacman
	STRB r0,[r4] ;stores it in on the board
	MOV r0,#32 ; char for space
	SUB r4,r4,#33
	STRB r0,[r4] ;stores space on the board
	MOV r0,#109
	LDR r4,ptr_to_prev_dir
	STRB r0,[r4] ;stores m in the prev dir memory
	B timerexit

i_pressed:
	SUB r8,r8,#33 ;offset to go up the board
	LDR r4,ptr_to_position
	ADD r4,r4,r8 ;address for the next position
	LDRB r3,[r4] ;loads the character

	CMP r3,#45 ;check if its '-'
	BEQ iwall
	CMP r3,#124 ;check if its '|'
	BEQ iwall
	CMP r3,#43 ;check if its '+'
	BEQ iwall

	B ilabel

iwall:
	LDR r4,ptr_to_prev_dir
	LDRB r5,[r4] ;loads the prev direction
	LDR r4,ptr_to_direction
	CMP r5,#105 ;checks if its i
	BNE iwall1

iwall1:
	LDR r4,ptr_to_prev_dir
	LDRB r0,[r4] ;loads the prev direction
	ADD r8,r8,#33 ;puts back to the prev offset

	CMP r0,#107 ;check if its k
	BEQ k_pressed ;goes to kpressed

	CMP r0,#109 ;check if its m
	BEQ m_pressed;goes to mpressed

	CMP r0,#106 ;check if its j
	BEQ j_pressed ;goes to jpressed
	B timerexit

ilabel:
	LDR r4,ptr_to_position
	LDRB r0,[r4,r8] ;loads the char at the position
	CMP r0,#46 ;check if its a pellet
	ITT EQ
	ADDEQ r7,r7,#10 ;increments the score by 10
	BLEQ pellet_count_routine

	LDR r4,ptr_to_power_pellet_flag
	MOV r1,#49 ;char for 1
	CMP r0,#79;check if its power pellet
	ITTTT EQ
	ADDEQ r7,r7,#50 ;increments the score by 50
	STRBEQ r1,[r4]
	MOVEQ r6,#0 ;clear the counter timer
	BLEQ pellet_count_routine

checkghosti:
	;MOV r9,#33
	;BL reg_ghost
	;CMP r1,#1
	;BEQ timerexit

	LDR r4,ptr_to_position
	ADD r4,r4,r8 ;gets the current address
	MOV r0,#60 ;char for pacman
	STRB r0,[r4] ;writes it on the board
	MOV r0,#32 ;char for space
	STRB r0,[r4,#33] ;stores it on the board
	MOV r0,#105
	LDR r4,ptr_to_prev_dir
	STRB r0,[r4] ;puts i in the prev direction
	B timerexit

j_pressed:
	SUB r8,r8,#1
	LDR r4,ptr_to_position
	ADD r4,r4,r8;decrease it to get the address to the right of pacman
	LDRB r3,[r4] ;load the char

	CMP r3,#45 ;check if its '-'
	BEQ jwall
	CMP r3,#124 ;check if its '|'
	BEQ jwall
	CMP r3,#43 ;check if its '+'
	BEQ jwall
	B jlabel

jwall:
	LDR r4,ptr_to_prev_dir
	LDRB r5,[r4] ;loads the prev direction
	LDR r4,ptr_to_direction
	CMP r5,#106 ;check if its j
	BNE jwall1

jwall1:
	LDR r4,ptr_to_prev_dir
	LDRB r0,[r4] ;loads the prev direction
	ADD r8,r8,#1 ;increase the offset

	CMP r0,#107 ;check if its k
	BEQ k_pressed ;goes to kpressed

	CMP r0,#109 ;check if its m
	BEQ m_pressed; goes to mpressed

	CMP r0,#105 ;check if its i
	BEQ i_pressed ;goes to ipressed
	B timerexit

jlabel:
	LDR r4,ptr_to_position
	LDRB r0,[r4,r8] ;load the char in current position

	CMP r0,#46 ;check if its pellet
	ITT EQ
	ADDEQ r7,r7,#10 ;increment the score by 10
	BLEQ pellet_count_routine

	LDR r3,ptr_to_power_pellet_flag
	MOV r1,#49 ;char for 1
	CMP r0,#79 ;check if its the power pellet
	ITTTT EQ
	ADDEQ r7,r7,#50 ;increments the score by 50
	STRBEQ r1,[r3] ;set the power pellet flag
	MOVEQ r6,#0 ;clear the counter timer
	BLEQ pellet_count_routine

checkghostj:
	;MOV r9,#1
	;BL reg_ghost
	;CMP r1,#1
	;BEQ timerexit

	LDR r4,ptr_to_position
	ADD r4,r4,r8 ;address to current position
	MOV r0,#60 ; char for pacman
	STRB r0,[r4] ;stores pacman on the board
	MOV r0,#32
	STRB r0,[r4,#1] ;stores space on the board

	MOV r0,#106
	LDR r4,ptr_to_prev_dir
	STRB r0,[r4] ;stores j in prev direction

	B timerexit

timerexit:
	MOV r0,#93
	LDR r4,ptr_to_right
	SUB r4,r4,#4
	LDRB r2,[r4]

	MOV r0,#91
	LDR r4,ptr_to_left
	ADD r4,r4,#1
	STRB r0,[r4]

	MOV r0,r7 ;copies the score to r0
	LDR r4, ptr_to_score_data
	BL convert_to_ascii ;stores the score in memory
	LDR r4,ptr_to_score
	BL output_string ;outputs the score

	LDR r4, ptr_to_board ;outputs the board
	BL output_string
timerexitpause:
	MOV r4,#0x0024
	MOVT r4,#0x4003
	LDR r9,[r4]
	ORR r9,r8,#1 ;clear interrupts
	STR r9,[r4]
 	LDMFD sp!, {r0,r1,r4,r5,r9-r12,lr}
 	BX lr
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
output_string:
    STMFD   SP!, {r1-r3,r5-r12,lr}
output_string_loop:
	LDR r5,ptr_to_gb ;initial positon of ghost
	LDR r6,ptr_to_ghost1
	LDR r2,[r6]
	ADD r6,r5,r2 ;address of the ghost1
	CMP r4,r6 ;check if the address is the same of the ghost
	ITTTT EQ
	LDREQ r3,ptr_to_ghost_char
	LDREQ r0,[r3] ;put the char in r0 to be printed out
	ADDEQ r4,r4,#1;increment the address
	BEQ skiploadchar

	LDR r6,ptr_to_ghost2
	LDR r2,[r6]
	ADD r6,r5,r2 ;address of the ghost2
	CMP r4,r6 ;check if the address is the same of the ghost
	ITTTT EQ
	LDREQ r3,ptr_to_ghost_char
	LDREQ r0,[r3] ;put the char in r0 to be printed out
	ADDEQ r4,r4,#1;increment the address
	BEQ skiploadchar

	LDR r6,ptr_to_ghost3
	LDR r2,[r6]
	ADD r6,r5,r2 ;address of the ghost3
	CMP r4,r6 ;check if the address is the same of the ghost
	ITTTT EQ
	LDREQ r3,ptr_to_ghost_char
	LDREQ r0,[r3] ;put the char in r0 to be printed out
	ADDEQ r4,r4,#1;increment the address
	BEQ skiploadchar

	LDR r6,ptr_to_ghost4
	LDR r2,[r6]
	ADD r6,r5,r2 ;address of the ghost4
	CMP r4,r6 ;check if the address is the same of the ghost
	ITTTT EQ
	LDREQ r3,ptr_to_ghost_char
	LDREQ r0,[r3] ;put the char in r0 to be printed out
	ADDEQ r4,r4,#1;increment the address
	BEQ skiploadchar

    LDRB    r0, [r4], #1        ; char loaded into r0
skiploadchar:
    MOV r2, #0xC000  ;Set r0 equal to the base address
    MOVT r2, #0x4000
    BL      output_character    ; output char in r0
    CMP     r0, #0x0            ; Check if loop has reached the NULL termniator '\0'
    BNE     output_string_loop  ; If Loop has not reached Null Character read next char

    LDMFD sp!, {r1-r3,r5-r12,lr}
    MOV pc, lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lab7exit:
	MOV r4, #0x000C
	MOVT r4, #0x4003 ;disable timer0 section
	LDR r0,[r4]
	BFC r0,#0,#1
	STR r0,[r4]

	MOV r4, #0x100C
	MOVT r4, #0x4003 ;disable timer1 section
	LDR r0,[r4]
	BFC r0,#0,#1
	STR r0,[r4]


	LDMFD sp!, {r6-r12,lr}
 	MOV pc, lr
 	.end
