init:
	bsf STATUS, RP0 			;	selects bank 1 (this is so we can config our in/out pins)
	what_button equ b1
	char1press equ b2
	char1 equ b3
	char2 equ b4
	temp equ b5
    digit_counter equ b6
	movlw b'00000000' 			;	set PORTB all outputs (A '0' means output, A '1' means input. We can set each
	movwf TRISB					;	We can set each bit individualy. Each port having 8-bits or 8 pins.
	movlw b'11111000' 			;	set PORTA pins 0, 1, and 2 outputs. pins 3, 4, 5, 6 and 7 inputs
	movwf TRISA 				;	remember PORTA pin 5 cannot be an input.
	bcf STATUS, RP0 			;	select bank 0
	clrf what_button
	clrf PORTA

begin:
	call check_keypad			;	call the check_keypad sub-routine and then return
	call display_digit			;	call the display_digit routine and then return
	goto begin					;	go back to the beginning and do it all again.

check_keypad:					;	This routine will scan the keypad for any key presses.

	movf what_button, w		; moving last button preseed into working register in case no button is pressed during in this scan
	; sanning through keypad matrix
	bsf PORTA, 0			;	lets scan the first column of keys		
		btfsc PORTA, 3			;	has the 1 key been pressed? if yes then
		movlw d'01'				;	copy decimal number 01 into w. but if not then continue on.
		btfsc PORTA, 4			;	has the 4 key been pressed? if yes then
		movlw d'04'				;	copy decimal number 04 into w. but if not then continue on.
		btfsc PORTA, 5			;	has the 7 key been pressed? if yes then
		movlw d'07'				;	copy decimal number 07 into w. but if not then continue on.				;	copy decimal number 10 into w. but if not then continue on.
	bcf PORTA, 0			;	now we have finished scanning the first column of keys
	bsf PORTA, 1			;	lets scan the middle column of keys
		btfsc PORTA, 3			;	has the 2 key been pressed? if yes then
		movlw d'02'				;	copy decimal number 02 into w. but if not then continue on.
		btfsc PORTA, 4			;	has the 5 key been pressed? if yes then
		movlw d'05'				;	copy decimal number 05 into w. but if not then continue on.
		btfsc PORTA, 5			;	has the 8 key been pressed? if yes then
		movlw d'08'				;	copy decimal number 08 into w. but if not then continue on.				;	copy decimal number 00 into w. but if not then continue on.
	bcf PORTA, 1			;	now we have finished scanning the middle column of keys
	bsf PORTA, 2			;	lets scan the last column of keys
		btfsc PORTA, 3			;	has the 3 key been pressed? if yes then
		movlw d'03'				;	copy decimal number 03 into w. but if not then continue on.
		btfsc PORTA, 4			;	has the 6 key been pressed? if yes then
		movlw d'06'				;	copy decimal number 06 into w. but if not then continue on.
		btfsc PORTA, 5			;	has the 9 key been pressed? if yes then
		movlw d'09'				;	copy decimal number 09 into w. but if not then continue on.
	bcf PORTA, 2			;	now we have finished scanning the first column of keys
	
	movwf what_button ; moves the value of the working reg into our what_button variable (this is the key key pressed value)
return						;	returns to main (as that is the last sub that called check_keypad)

; 0:'10111101'
; 1:'10100000'
; 2:'00111110'
; 3:'10101100'
; 4:'10101011'
; 5:'10011011'
; 6:'10111111'
; 7:'10110000'
; 8:'11111111'
; 9:'01110111'


digit_data:
    movwf temp
	; checking if equal to 0
		sublw d'1'
		btfsc  STATUS,C
		movlw b'10111101'
		btfsc  STATUS,C 
		movwf PORTB	
    movwf temp
	; checking if equal to 1
		sublw d'2'
		btfsc  STATUS,C
		movlw b'10111101'
		btfsc  STATUS,C
		movwf PORTB	
    movwf temp
	; checking if equal to 2
		sublw d'3'
		btfsc  STATUS,C
		movlw b'10111101'
		btfsc  STATUS,C 
		movwf PORTB	
    movwf temp
	; checking if equal to 3
		sublw d'4'
		btfsc  STATUS,C
		movlw b'10111101'
		btfsc  STATUS,C 
		movwf PORTB	
	movf what_button, w

digit_data2:
    movwf digit_counter
    incf digit_counter
    subwf temp, digit_counter
        btfsc  STATUS,C
        movlw b'10111101'
		btfsc  STATUS,C
		movwf PORTB	




; procedure that displays out button that was pressed 
display_digit:					
	call digit_data
	movwf PORTB
return		; returns to the sub that initially called display_digit				


; procedure that displays mode of calculation
; disp_add:
; 	movlw b'binary number for dot on right side
; 	movwf PORTB
; disp_sub:
; 	movlw b'binary number for dot on left side
; 	movwf PORTB

;calculate:

end				; all things must come to an end, including this program
