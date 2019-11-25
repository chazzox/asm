
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;											;
;	PIC Microcontroller Tutorial Module 6	;
;											;
;	By Brad Slattery 2009					;
;	www.bradsprojects.com					;
;	brad@bradsprojects.com					;
;											;
;	'Designing electronic projects,			;
;	to spread the name of Jesus'			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;																						;
								;	NOTE: If you are brand new to programming, then don't concern yourself to			;
								;	much with all of these initial lines of code. You can read up all about this		;
								;	at a later date if you wish. I'm sure that you would rather make an LED flash		;
								;	or make something interesting happen straight away right?							;
								;	All you have to know for now is that we will be placing our code just underneath	;
								;	the SETUP label, and then underneath the BEGIN label. it's really quite simple!		;
								;																						;
								;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	LIST p=16f648a 				;	tell assembler what chip we are using (if you are using the 16f628a, then
	include "P16f648a.inc"		;	make sure you change this line and the previous line to read p16f628a
	__config h'3f18'			;	sets the configuration settings - internal oscillator, watchdog timer OFF
								;	Power Up Timer DISABLED, Master Clear DISABLED, Brown Out Detect DISABLED,
								;	Low Voltage Programming DISABLED, Data EE Read Protect Disabled,
								;	Code Protect OFF. (this will remain the same for all tutorials)


PC equ h'02'					;	The program counter will be refered to as PC - The program counter is
								;	a little counter within the microcontroller to let itself know what line number
								;	it is upto when running a program. We can make the microcontroller jump to a certain
								;	line number by changing the value stored in PC. (we will do this in a later tutorial)

	cblock h'20'				;	Within this cblock and endc, we can define our variables. More info on this, later.
	delay_1						;	set aside 1 byte for a variable called delay_1
	delay_2						;	set aside 1 byte for a variable called delay_1
	what_button					;	this variable is used in identifying which button we have pressed.
	endc						;	that's the end of defining our variables



	org h'0000'					;	This line just tells the microcontroller what address to start running our program from.
								;	It will always be 0000 hex for all the tutorials.


	movlw h'07'					;	This will turn the comparators OFF.	
	movwf CMCON 				;	(we just want to use the ports as digital ports)


	bsf STATUS, RP0 			;	select bank 1 (to enable us to change the Input / Output status of our ports)
	movlw b'00000000' 			;	set PORTB all outputs (A '0' means output, A '1' means input. We can set each
	movwf TRISB					;	We can set each bit individualy. Each port having 8-bits or 8 pins.
	movlw b'11111000' 			;	set PORTA pins 0, 1, and 2 outputs. pins 3, 4, 5, 6 and 7 inputs
	movwf TRISA 				;	remember PORTA pin 5 cannot be an input.
	bcf STATUS, RP0 			;	select bank 0


	goto setup					;	Now skip straight to setup.


digit_data						;	This routine holds all the data for our various digits.
	movf what_button, w			;	before we get here, the what_button variable will contain
								;	a certain number that we copy into the w register.
	addwf PC					;	We then add this number to our program counter which will jump
								;	us straight to a certain retlw statement which will correspond
								;	to the number that we pressed on the keypad.
	retlw b'11000000'			;	this is the data for the number 0
	retlw b'11110011'			;	this is the data for the number 1	
	retlw b'10100100'			;	this is the data for the number 2
	retlw b'10100001'			;	this is the data for the number 3
	retlw b'10010011'			;	this is the data for the number 4
	retlw b'10001001'			;	this is the data for the number 5
	retlw b'10001000'			;	this is the data for the number 6
	retlw b'11100011'			;	this is the data for the number 7
	retlw b'10000000'			;	this is the data for the number 8
	retlw b'10000001'			;	this is the data for the number 9
	retlw b'11010010'			;	this is the data for *
	retlw b'10101101'			;	this is the data for #



setup							;	I always have a title labeled 'setup' this is where we set everything up
		clrf what_button		;	this ensures that we will display '0' on the display at startup
		clrf PORTA				;	we are not scanning for any keypresses yet, so make PORTA all zero's


begin							;	and here is our main program
	call check_keypad			;	call the check_keypad sub-routine and then return
	call display_digit			;	call the display_digit routine and then return
	goto begin					;	go back to the beginning and do it all again.



check_keypad					;	This routine will scan the keypad for any key presses.

		movf what_button, w		;	we want to copy our last digit that was pressed into w
								;	so just in case we DON'T press a key in this keypad scan
								;	because at the end of this sub-routine, we will automatically
								;	w back into what_button variable. This ensures that we keep the
								;	last digit pressed on the display.

		bsf PORTA, 0			;	lets scan the first column of keys		
		btfsc PORTA, 3			;	has the 1 key been pressed? if yes then
		movlw d'01'				;	copy decimal number 01 into w. but if not then continue on.
		btfsc PORTA, 4			;	has the 4 key been pressed? if yes then
		movlw d'04'				;	copy decimal number 04 into w. but if not then continue on.
		btfsc PORTA, 7			;	has the 7 key been pressed? if yes then
		movlw d'07'				;	copy decimal number 07 into w. but if not then continue on.
		btfsc PORTA, 6			;	has the * key been pressed? if yes then
		movlw d'10'				;	copy decimal number 10 into w. but if not then continue on.
		bcf PORTA, 0			;	now we have finished scanning the first column of keys
	
		bsf PORTA, 1			;	lets scan the middle column of keys
		btfsc PORTA, 3			;	has the 2 key been pressed? if yes then
		movlw d'02'				;	copy decimal number 02 into w. but if not then continue on.
		btfsc PORTA, 4			;	has the 5 key been pressed? if yes then
		movlw d'05'				;	copy decimal number 05 into w. but if not then continue on.
		btfsc PORTA, 7			;	has the 8 key been pressed? if yes then
		movlw d'08'				;	copy decimal number 08 into w. but if not then continue on.
		btfsc PORTA, 6			;	has the 0 key been pressed? if yes then
		movlw d'00'				;	copy decimal number 00 into w. but if not then continue on.
		bcf PORTA, 1			;	now we have finished scanning the middle column of keys
	
		bsf PORTA, 2			;	lets scan the last column of keys
		btfsc PORTA, 3			;	has the 3 key been pressed? if yes then
		movlw d'03'				;	copy decimal number 03 into w. but if not then continue on.
		btfsc PORTA, 4			;	has the 6 key been pressed? if yes then
		movlw d'06'				;	copy decimal number 06 into w. but if not then continue on.
		btfsc PORTA, 7			;	has the 9 key been pressed? if yes then
		movlw d'09'				;	copy decimal number 09 into w. but if not then continue on.
		btfsc PORTA, 6			;	has the # key been pressed? if yes then
		movlw d'11'				;	copy decimal number 11 into w. but if not then continue on.
		bcf PORTA, 2			;	now we have finished scanning the last column of keys

		movwf what_button		;	When we get here, we will have a certain number in our w register,
								;	we then copy it from w into what_button so we can use it to jump
								;	to a certain retlw instruction to grab the relevant data to display 
								;	the digit that we pressed.

	return						;	and now return to the main routine



display_digit					;	This sub-routine will show the digit on the display
	call digit_data				;	call digit_data to grab our relevent 8-bits of info
								;	for whatever button we had pressed.
	movwf PORTB					;	and move this 8-bits of data to PORTB for display on the display
	return						;	and then return to our main program



	end							;	We always need to have end at the end, even if we don't want the program
								;	to actually end, it still must be here!