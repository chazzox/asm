init:
	; variables to be defined: cblock h'20'
	; variables to be defined: delay_1		
	; variables to be defined: delay_2		
	; variables to be defined: what_button	

	bsf STATUS, RP0 			;	selects bank 1 (this is so we can config our in/out pins)
	what_button equ b1
	movlw b'00000000' 			;	set PORTB all outputs (A '0' means output, A '1' means input. We can set each
	movwf TRISB					;	We can set each bit individualy. Each port having 8-bits or 8 pins.
	movlw b'11111000' 			;	set PORTA pins 0, 1, and 2 outputs. pins 3, 4, 5, 6 and 7 inputs
	movwf TRISA 				;	remember PORTA pin 5 cannot be an input.
	bcf STATUS, RP0 			;	select bank 0
	
	
	clrf what_button
	clrf PORTA
	goto begin					;	Now skip straight to setup.

; logic is to be replaced
;digit_data:						; this stores the va;ues of each 
	; movf what_button, w			
	; addwf PC
	; replace with if statements depedning on w value (working register
	; retlw b'11000000'			;	this is the data for the number 0
	; retlw b'11110011'			;	this is the data for the number 1	
	; retlw b'10100100'			;	this is the data for the number 2
	; retlw b'10100001'			;	this is the data for the number 3
	; retlw b'10010011'			;	this is the data for the number 4
	; retlw b'10001001'			;	this is the data for the number 5
	; retlw b'10001000'			;	this is the data for the number 6
	; retlw b'11100011'			;	this is the data for the number 7
	; retlw b'10000000'			;	this is the data for the number 8
	; retlw b'10000001'			;	this is the data for the number 9
	; retlw b'11010010'			;	this is the data for *
	; retlw b'10101101'			;	this is the data for #


begin:
	call check_keypad			;	call the check_keypad sub-routine and then return
	call display_digit			;	call the display_digit routine and then return
	goto begin					;	go back to the beginning and do it all again.



check_keypad:					;	This routine will scan the keypad for any key presses.

	movf what_button, w		; moving last button preseed into working register in case no button is pressed during in this scan

	; sanning through keypad matrics

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

	movwf what_button ; moves the value of the working reg into our what_button variable (this is the key key pressed value)

return						;	returns to main (as that is the last sub that called check_keypad)


; function to display out button that has been pressed 
display_digit:					
	;call digit_data
	movwf PORTB
return		; returns to the sub that initially called display_digit				



end				; all things must come to an end, including this program

