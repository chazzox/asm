initialization:
    bsf STATUS, RP0 			;	selects bank 1 (this is so we can config our in/out pins)
        movlw b'00000000' 			;	set PORTB all outputs (A '0' means output, A '1' means input. We can set each
        movwf TRISB					;	We can set each bit individualy. Each port having 8-bits or 8 pins.
	    
        movlw b'11111000' 			;	set PORTA pins 0, 1, and 2 outputs. pins 3, 4, 5, 6 and 7 inputs
	    movwf TRISA 				;	remember PORTA pin 5 cannot be an input.
	bcf STATUS, RP0 			;	select bank 0
;   now we are defining our registers as easy to read/understand text
	clrf PORTA
	clrf PORTB
	workingReg equ h'00'
    buttonPressCounter equ b0
    mode equ b1
    digit1 equ b2
    digit equ b3
	tempButtonStore equ b4
	ledNum equ b5

main:
	call getPress
	call validatePress
	
getPress:
	call getMode
	movlw buttonPressCounter
	sublw d'01'
	btfsc  STATUS,C
	call getNum
	
return						;	returns to the sub that called this routine 

getNum:
	bsf PORTA, 0				;	lets scan the first column of keys		
		btfsc PORTA, 3			;	has the 1 key been pressed? if yes then
			movlw d'01'				;	copy decimal number 01 into w. but if not then continue on.
		btfsc PORTA, 4			;	has the 4 key been pressed? if yes then
			movlw d'04'				;	copy decimal number 04 into w. but if not then continue on.
		btfsc PORTA, 5			;	has the 7 key been pressed? if yes then
			movlw d'07'				;	copy decimal number 07 into w. but if not then continue on.		
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
	clrf workingReg
return

getMode:
	bsf PORTA, 3			;	lets scan the outer column
			btfsc PORTA, 3			;	has the mode key been pressed? if yes then
				movlw d'10'				;	copy decimal number 03 into w. but if not then continue on.
			btfsc PORTA, 3			;	has the mode key been pressed? if yes then
				call buttonPressCounterEvent
			
			btfsc PORTA, 4			;	has the 6 key been pressed? if yes then
				movlw d'11'				;	copy decimal number 06 into w. but if not then continue on.
			btfsc PORTA, 4			;	has the mode key been pressed? if yes then
				call buttonPressCounterEvent
	bcf PORTA, 2			;	now we have finished scanning the last column of keys
	movwf mode
	clrf workingReg
return

buttonPressCounterEvent:
	movlw d'1'
	addwf buttonPressCounter
return

validatePress:
	
return
	


displayNum:
	movlw mode
	addlw ledNum
	; if bigger 10
	movwf PORTB
return

calculate:

addSub:

minusSub:

error:

clearSub: