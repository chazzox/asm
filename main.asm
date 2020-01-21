initialization:
    bsf STATUS, RP0 					;	selects bank 1 (this is so we can config our in/out pins)
        movlw b'00000000' 				;	set PORTB all outputs (A '0' means output, A '1' means input. We can set each
        movwf TRISB						;	We can set each bit individualy. Each port having 8-bits or 8 pins.
	    
        movlw b'11111000' 				;	set PORTA pins 0, 1, and 2 outputs. pins 3, 4, 5, 6 and 7 inputs
	    movwf TRISA 					;	remember PORTA pin 5 cannot be an input.
	bcf STATUS, RP0 					;	select bank 0
	clrf PORTA
	clrf PORTB
	; now we are defining our registers as easy to read/understand text
    displayNum equ b0
    mode equ b1
	BCDconverted equ b2
	digit1 equ b3
	digit2 equ b4
	latestPress equ b5
	inputCounter equ b6
	FLAG_REG equ b7
	nonBCD equ b8
	clrw 

	; this is the constant definition section, here we difine numbers for writing
	; to the led as well as move some numbers into the registers i just simplified 
	; led pin out numbers, usefull for easier to read code when debugging
	; can be removed if momeory optimisations are needed 
	led0 equ b'11011101'
	led1 equ b'00000101'
	led2 equ b'10101101'
	led3 equ b'10101101'
	led4 equ b'00110101'
	led5 equ b'10111001'
	led6 equ b'11110001'
	led7 equ b'00001101'
	led8 equ b'11111101'
	led9 equ b'00111101'
	dpr equ  b'00000010'

main:
    call getPress
	bsf PORTA, 3						; scanning the column mode of keys 
			btfsc PORTA, 5				; has the mode key been pressed? if yes then
				call calculate
	bcf PORTA, 3

getPress:
	call getNum
	call getMode
	
return									; returns to the sub that called this routine 

getNum:                                 ; scans the number rows
	clrw
	bsf PORTA, 0						; lets scan the first column of keys		
		btfsc PORTA, 4					; has the 1 key been pressed? if yes then
			incf inputCounter,1
		btfsc PORTA, 4					; has the 1 key been pressed? if yes then
			movlw d'1'					; copy decimal number 01 into w. but if not then continue on.
		
		btfsc PORTA, 5					; has the 4 key been pressed? if yes then
			incf inputCounter,1
		btfsc PORTA, 5					; has the 4 key been pressed? if yes then
			movlw d'4'					; copy decimal number 04 into w. but if not then continue on.

		btfsc PORTA, 6					; has the 7 key been pressed? if yes then
			incf inputCounter,1
		btfsc PORTA, 6					; has the 7 key been pressed? if yes then
			movlw d'7'					; copy decimal number 07 into w. but if not then continue on.		
	bcf PORTA, 0						; now we have finished scanning the first column of keys

	bsf PORTA, 1						; lets scan the middle column of keys
		btfsc PORTA, 4					; has the 1 key been pressed? if yes then
			incf inputCounter,1
		btfsc PORTA, 4					; has the 1 key been pressed? if yes then
			movlw d'1'					; copy decimal number 01 into w. but if not then continue on.
		
		btfsc PORTA, 5					; has the 4 key been pressed? if yes then
			incf inputCounter,1
		btfsc PORTA, 5					; has the 4 key been pressed? if yes then
			movlw d'4'					; copy decimal number 04 into w. but if not then continue on.

		btfsc PORTA, 6					; has the 7 key been pressed? if yes then
			incf inputCounter,1
		btfsc PORTA, 6					; has the 7 key been pressed? if yes then
			movlw d'7'					; copy decimal number 07 into w. but if not then continue on.		
	bcf PORTA, 1						; now we have finished scanning the middle column of key

	bsf PORTA, 2						; lets scan the third column of keys
		btfsc PORTA, 4					; has the 1 key been pressed? if yes then
			incf inputCounter,1
		btfsc PORTA, 4					; has the 1 key been pressed? if yes then
			movlw d'1'					; copy decimal number 01 into w. but if not then continue on.
		
		btfsc PORTA, 5					; has the 4 key been pressed? if yes then
			incf inputCounter,1
		btfsc PORTA, 5					; has the 4 key been pressed? if yes then
			movlw d'4'					; copy decimal number 04 into w. but if not then continue on.

		btfsc PORTA, 6					; has the 7 key been pressed? if yes then
			incf inputCounter,1
		btfsc PORTA, 6					; has the 7 key been pressed? if yes then
			movlw d'7'					; copy decimal number 07 into w. but if not then continue on.		
	bcf PORTA, 2						; now we have finished scanning the third column of keys

	bsf PORTA, 3						; lets scan the third column of keys
		btfsc PORTA, 4					; has the 1 key been pressed? if yes then
			incf inputCounter,1
		btfsc PORTA, 4					; has the 1 key been pressed? if yes then
			movlw d'1'					; copy decimal number 01 into w. but if not then continue on.
		
		btfsc PORTA, 5					; has the 4 key been pressed? if yes then
			incf inputCounter,1
		btfsc PORTA, 5					; has the 4 key been pressed? if yes then
			movlw d'4'					; copy decimal number 04 into w. but if not then continue on.

		btfsc PORTA, 6					; has the 7 key been pressed? if yes then
			incf inputCounter,1
		btfsc PORTA, 6					; has the 7 key been pressed? if yes then
			movlw d'7'					; copy decimal number 07 into w. but if not then continue on.		
	bcf PORTA, 3						; now we have finished scanning the third column of keys
`	movwf latestPress
	call storeNumber
	call displayPress
return



getMode:
	movlw d'10' 						; our default mode is + however, this will be overwitten if the mode key is pressed wihin the clock
	bsf PORTA, 3						; scanning the column mode of keys 
			btfsc PORTA, 5				; has the mode key been pressed? if yes then
				movlw d'1'				; has the + key been pressed 
			btfsc PORTA, 6				; has the 6 key been pressed? if yes then
				movlw d'2'				; copy decimal number 06 into w. but if not then continue on.
	bcf PORTA, 3						; as the scanninig of mode keys has finished, changing pinOut to logic b'0'
	movwf mode
	clrw
return

displayPress:
	movf latestPress,0
	movwf nonBCD
	clrw
	call BCDconveter
	call display
return 

BCDconveter:
    movf nonBCD,0
	sublw d'1' 						; is the result == 0 
	btfsc  STATUS,C
		movlw led0
	btfsc  STATUS,C
		movwf BCDconverted btfsc  STATUS,C return

	movf nonBCD,0
	sublw d'2' 						; is the result == 1
	btfsc  STATUS,C
		movlw led1
	btfsc  STATUS,C
		movwf BCDconverted 
	btfsc  STATUS,C
		return

	movf nonBCD,0
	sublw d'3' 						; is the result == 2 
	btfsc  STATUS,C
		movlw led2
	btfsc  STATUS,C
		movwf BCDconverted 
	btfsc  STATUS,C
			return

	movf nonBCD,0
	sublw d'4' 						; is the result == 3 
	btfsc  STATUS,C
		movlw led3
	btfsc  STATUS,C
		movwf BCDconverted 
	btfsc  STATUS,C
		return

	movf nonBCD,0
	sublw d'5' 						; is the result == 4 
	btfsc  STATUS,C
		movlw led4
	btfsc  STATUS,C
		movwf BCDconverted 
	btfsc  STATUS,C
		return

	movf nonBCD,0
	sublw d'6' 						; is the result == 5
	btfsc  STATUS,C
		movlw led5
	btfsc  STATUS,C
		movwf BCDconverted 
	btfsc  STATUS,C
		return

	movf nonBCD,0
	sublw d'7' 						; is the result == 6 
	btfsc  STATUS,C
		movlw led6
	btfsc  STATUS,C
		movwf BCDconverted
	btfsc  STATUS,C
		return

	movf nonBCD,0 
	sublw d'8' 						; is the result == 7 
	btfsc  STATUS,C
		movlw led7
	btfsc  STATUS,C
		movwf BCDconverted 
	btfsc  STATUS,C
		return

	movf nonBCD,0
	sublw d'9' 						; is the result == 8 
	btfsc  STATUS,C
		movlw led8
	btfsc  STATUS,C
		movwf BCDconverted 
	btfsc  STATUS,C
		return

	movf nonBCD,0	
	sublw d'10' 						; is the result == 9
	btfsc  STATUS,C
		movlw led9
	btfsc  STATUS,C
		movwf BCDconverted 	
	btfsc  STATUS,C
		return
return

display:
    movf BCDconverted,0
    movwf PORTB
return


calculate:
	nop