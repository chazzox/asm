initialization:
    bsf STATUS, RP0 				;	selects bank 1 (this is so we can config our in/out pins)
        movlw b'00000000' 			;	set PORTB all outputs (A '0' means output, A '1' means input. We can set each
        movwf TRISB					;	We can set each bit individualy. Each port having 8-bits or 8 pins.
	    
        movlw b'11111000' 			;	set PORTA pins 0, 1, and 2 outputs. pins 3, 4, 5, 6 and 7 inputs
	    movwf TRISA 				;	remember PORTA pin 5 cannot be an input.
	bcf STATUS, RP0 				;	select bank 0
	clrf PORTA
	clrf PORTB
	; now we are defining our registers as easy to read/understand text
    displayLiteralgf equ b0
    mode equ b1
    digit1 equ b2
    digit equ b3
	tempButtonStore equ b4
	result equ b5
	
	ledNum equ b6
	clrw

	; this is the constant definition section, here we difine numbers for writing
	; to the led as well as move some numbers into the registers i just simplified 
	movlw b'00000000'
	movwf result
	; led pin out numbers, usefull for easier to read code when debugging, can be removed if momeory optimisations are needed 
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

; this the main function, erverything works through here and everything will eventually loop back to here
main:
	call getPress
	
getPress:
	call getMode
	call getNum	
return						;	returns to the sub that called this routine 

getNum:
	bsf PORTA, 0				;	lets scan the first column of keys		
		btfsc PORTA, 3			;	has the 1 key been pressed? if yes then
			movlw d'01'				;	copy decimal number 01 into w. but if not then continue on.
		btfsc PORTA, 4			;	has the 4 key been pressed? if yes then
			movlw d'04'				;	copy decimal number 04 into w. but if not then continue on.
		btfsc PORTA, 5			;	has the 7 key been pressed? if yes then
			movlw d'07'			;	copy decimal number 07 into w. but if not then continue on.		
	bcf PORTA, 0				;	now we have finished scanning the first column of keys

	bsf PORTA, 1				;	lets scan the middle column of keys
		btfsc PORTA, 3			;	has the 2 key been pressed? if yes then
			movlw d'02'				;	copy decimal number 02 into w. but if not then continue on.
		btfsc PORTA, 4			;	has the 5 key been pressed? if yes then
			movlw d'05'				;	copy decimal number 05 into w. but if not then continue on
		btfsc PORTA, 5			;	has the 8 key been pressed? if yes then
			movlw d'08'				;	copy decimal number 08 into w. but if not then continue on.
	bcf PORTA, 1			;	now we have finished scanning the middle column of key

	bsf PORTA, 2			;	lets scan the third column of keys
		btfsc PORTA, 3			;	has the 3 key been pressed? if yes then
			movlw d'03'				;	copy decimal number 03 into w. but if not then continue on.
		btfsc PORTA, 4			;	has the 6 key been pressed? if yes then
			movlw d'06'				;	copy decimal number 06 into w. but if not then continue on.
		btfsc PORTA, 5			;	has the 9 key been pressed? if yes then
			movlw d'09'				;	copy decimal number 09 into w. but if not then continue on.
	bcf PORTA, 2			;	now we have finished scanning the third column of keys
	movwf tempButtonStore
	clrw
return

getMode:
	movlw d'10' 				; our default mode is + however, this will be overwitten if the mode key is pressed wihin the clock
	bsf PORTA, 3			;	scanning the column mode of keys 
			btfsc PORTA, 3			;	has the mode key been pressed? if yes then
				movlw d'10'				; has the + key been pressed 
			btfsc PORTA, 4			;	has the 6 key been pressed? if yes then
				movlw d'11'				;	copy decimal number 06 into w. but if not then continue on.
	bcf PORTA, 3			;	as the scanninig of mode keys has finished, changing pinOut to logic b'0'
	movwf mode
	clrw
	call display 
return

display:
	movf mode,1
	addwf result,0
	sublw d'10'
	clrw
	btfsc  STATUS,C
	call displayDig				; if the numebr is smaller than 9, it will need the two digit display function to run
	call display2dig 			; 
	movf displayLiteral,1
	movwf PORTA


displayDig:
	movf result,1
	sublw d'01' 					; is the result == 0 
	btfsc  STATUS,C
		movlw led0
	btfsc  STATUS,C
		return 

	movf result,1
	sublw d'02' 					; is the result == 1
	btfsc  STATUS,C
		movlw led1
	btfsc  STATUS,C
		return 

	movf result,1
	sublw d'03' 					; is the result == 2 
	btfsc  STATUS,C
		movlw led2
	btfsc  STATUS,C
		return 
	
	movf result,1
	sublw d'04' 					; is the result == 3 
	btfsc  STATUS,C
		movlw led3
	btfsc  STATUS,C
		return 

	movf result,1
	sublw d'05' 					; is the result == 4 
	btfsc  STATUS,C
		movlw led4
	btfsc  STATUS,C
		return 

	movf result,1
	sublw d'06' 					; is the result == 5
	btfsc  STATUS,C
		movlw led5
	btfsc  STATUS,C
		return 

	movf result,1
	sublw d'07' 					; is the result == 6 
	btfsc  STATUS,C
		movlw led6
	btfsc  STATUS,C
		return
	
	movf result,1 
	sublw d'08' 					; is the result == 7 
	btfsc  STATUS,C
		movlw led7
	btfsc  STATUS,C
		return 
	
	movf result,1
	sublw d'09' 					; is the result == 8 
	btfsc  STATUS,C
		movlw led8
	btfsc  STATUS,C
		return 
	
	movf result,1	
	sublw d'10' 					; is the result == 8 s
	btfsc  STATUS,C
		movlw led9
	btfsc  STATUS,C
		return 	
return


display2dig:
	movlw led0
	movwf PORTB

calculate:


addSub:

minusSub:

error:

clearSub: