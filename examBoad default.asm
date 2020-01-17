;*******************************************************************
; TEMPLATE PROVIDED BY CENTRE
; TITLE: Program 1
; AUTHOR: ########YOUR NAME######
; DATE: #######CURRENT DATE#######
;
; Program description
;
;The program flashes an LED on and off continuously
;*********************************************************************
; DEFINITIONS
;*********************************************************************
 list p=16F88 ; tells the assembler which PIC chip to program for
 radix dec ; set default number radix to decimal
 ;radix hex ; uncomment this to set radix to hex
 __config h'2007', 0x3F50 ; internal oscillator, RA5 as i/o, wdt off
 __config h'2008', 0x3FFF
 errorlevel -302 ; hide page warnings
W EQU h'00' ; pointer to Working register
F EQU h'01' ; pointer to file
;****** REGISTER USAGE ******
;For PIC16F88, user RAM starts at h'20'. The following definitions
;will be found useful in many programs.
; Register page 1
TRISA EQU h'85' ; data direction registers
TRISB EQU h'86'
OSCCON EQU h'8F' ; internal oscillator speed
ANSEL EQU h'9B' ; ADC port enable bits
; Register page 0
STATUS EQU h'03' ; status
PORTA EQU h'05' ; input / output ports
PORTB EQU h'06'
INTCON EQU h'0B' ; interrupt control
ADRESH EQU h'1E' ; ADC result
ADCON0 EQU h'1F' ; ADC control
B0 EQU h'20' ; general use byte registers B0 to B27
B1 EQU h'21'
B2 EQU h'22'
B3 EQU h'23'
B4 EQU h'24'
B5 EQU h'25'
B6 EQU h'26'
B7 EQU h'27'
B8 EQU h'28'
B9 EQU h'29'
B10 EQU h'2A'
© WJEC CBAC Ltd 2018 61
GCE A level Electronics – Chapter 3: Further Microcontrollers
B11 EQU h'2B'
B12 EQU h'2C'
B13 EQU h'2D'
B14 EQU h'2E'
B15 EQU h'2F'
B16 EQU h'30'
B17 EQU h'31'
B18 EQU h'32'
B19 EQU h'33'
B20 EQU h'34' ; used in interrupt routine
B21 EQU h'35' ; used in interrupt routine
B22 EQU h'36'
B23 EQU h'37'
B24 EQU h'38'
B25 EQU h'39'
B26 EQU h'3A'
B27 EQU h'3B'
WAIT1 EQU h'3C' ; counters used in wait delays
WAIT10 EQU h'3D'
WAIT100 EQU h'3E'
WAIT1000 EQU h'3F'
ADCTEMP EQU h'40' ; adc loop counter
;****** REGISTER BITS ******
C EQU h'00' ; carry flag
Z EQU h'02' ; zero flag
RP0 EQU h'05' ; register page bit
INT0IF EQU h'01' ; interrupt 0 flag
INT0IE EQU h'04' ; interrupt 0 enable
GIE EQU h'07' ; global interrupt enable
;*********************************************************************
; VECTORS
;*********************************************************************
;The PIC16F88 reset vectors
 ORG h'00' ; reset vector address
 goto start ; goes to first instruction on reset/power-up
 ORG h'04' ; interrupt vector address
 goto interrupt
;
;*********************************************************************
; SUBROUTINES
;*********************************************************************
; Predefined wait subroutines - wait1ms, wait10ms, wait100ms, wait1000ms
wait1ms ; (199 x 5) + 5 instructions = 1000us = 1ms @ 4MHz resonator
 movlw d'199' ; 1
 movwf WAIT1 ; 1
loop5ns
© WJEC CBAC Ltd 2018 62
GCE A level Electronics – Chapter 3: Further Microcontrollers
 clrwdt ; 1 this loop 1+1+1+2 = 5 instructions
 nop ; 1
 decfsz WAIT1,F ; 1
 goto oop5ns ; 2
 nop ; 1
 return ; 2
 wait10ms
 movlw d'10' ; 10 x 1ms = 10ms
 movwf WAIT10
 loop10ms
 call wait1ms
 decfsz WAIT10,F
 goto loop10ms
 return
 wait100ms
 movlw d'100' ; 100 x 1ms = 100ms
 movwf WAIT100
 loop100ms
 call wait1ms
 decfsz WAIT100,F
 goto loop100ms
 return
 wait1000ms
 movlw d'10' ; 10 x 100ms = 1000ms
 movwf WAIT1000
 loop1000ms
 call wait100ms
 decfsz WAIT1000,F
 goto loop1000ms
 return
 ; Predefined ADC subroutines - readadc0, readac1, readadc2
 readadc0
 movlw b'00000001' ; setup mask for pin A.0
 call readadc ; do the adc conversion
 movwf B0 ; save result in B0
 return
 readadc1
 movlw b'00000010' ; setup mask for pin A.1
 call readadc ; do the adc conversion
 movwf B1 ; save result in B1
 return
 readadc2
 movlw b'00000100' ; setup mask for pin A.2
 call readadc ; do the adc conversion
 movwf B2 ; save result in B2
 return
© WJEC CBAC Ltd 2018 63
GCE A level Electronics – Chapter 3: Further Microcontrollers
readadc
; generic sub routine to read ADC 0, 1 or 2 (pass appropriate mask in W)
; to start conversion we need mask (001, 010, 100) in ANSEL bits 0-2
; but the actual channel number (0, 1, 2) in ADCON0 channel select bits
; then set the ADCON0, GO bit to start the conversion
 bsf STATUS,RP0 ; select register page 1
 movwf ANSEL ; move mask value 001,010,100 into ANSEL
 bcf STATUS,RP0 ; select register page 0
 movwf ADCTEMP ; 00000??? get mask value
 rlf ADCTEMP,F ; 0000???x rotate twice
 rlf ADCTEMP,W ; 000???xx
 andlw b'00011000' ; 000??000 mask off the unwanted bits
 iorlw b'00000001' ; 000??001 set the 'ADC on' bit
 movwf ADCON0 ; move working into ADCON0
 movlw d'10' ; 10 x 3 = 30us acquistion time
 movwf ADCTEMP ; re-use ADC1 register as a counter
loopacq
 decfsz ADCTEMP,F ; loop around to create short delay
 goto loopacq ; each loop is 1+2 = 3 instructions = 3us @ 4MHz
 bsf ADCON0,2 ; now start the conversion
loopadc
 clrwdt ; pat the watchdog
 btfsc ADCON0,2 ; is conversion finished?
 goto loopadc ; no, so wait a bit more
 movf ADRESH,W ; move result into W
 return ; return with result in W
;NOTE for PICAXE users: the following five subroutines and two instructions are not supported
;by PICAXE compiler
readtemp1:
readtemp2:
readtemp3:
debug:
lcd:
clrw ; instruction not supported by this template
return : instruction not supported by this template
;*********************************************************************
; MAIN PROGRAM
;*********************************************************************
;****** INITIALISATION ******
start
bsf STATUS,RP0 ; select register page 1
movlw b'01100000' ; set to 4MHz internal operation
movwf OSCCON
clrf ANSEL ; disable ADC (enabled at power-up)
bcf STATUS,RP0 ; select register page 0
;the data direction registers TRISA and TRISB live in the special register set. A '1' in
;these registers sets the corresponding port line to an Input, and a
;'0' makes the corresponding line an output.
© WJEC CBAC Ltd 2018 64
GCE A level Electronics – Chapter 3: Further Microcontrollers
Init
 clrf PORTA ; make sure PORTA output latches are low
 clrf PORTB ; make sure PORTB output latches are low
 bsf STATUS,RP0 ; select register page 1
 movlw b'11111111' ; set port A data direction (0 = output bit, 1 =
 ; input bit)
 movwf TRISA ;
 movlw b'11111110' ; set port B data direction (0 = output bit, 1 =
 ; input bit)
 movwf TRISB ;
 bcf STATUS,RP0 ; select register page 0
;****** PROGRAM ******
;************* remove semicolons from next two lines to enable interrupt routine************
; bsf INTCON,INT0IE; set external interrupt enable
; bsf INTCON,GIE ; enable all interrupts
main
;*********************************************************************
 clrf PORTB ; make sure PORTB outputs are low at the start of
 ; program
begin bsf PORTB,0 ; set bit 0 (the LSB) of PORTB
 call wait1000ms ; call the subroutine named 'wait1000ms' twice
 call wait1000ms
 bcf PORTB,0 ; clear bit 0 (the LSB) of PORTB
 call wait1000ms ; call the subroutine named 'wait1000ms' once
 goto begin ; branch (unconditionally) to the part of the
 ; program labelled 'begin'
;*********************************************************************
; INTERRUPT SERVICE ROUTINE
;*********************************************************************
 W_SAVE EQU B2 ; backup registers used in interrupts
interrupt
 movwf W_SAVE ; Copy W to save register
 btfss INTCON,INT0IF ; check correct interrupt has occurred
 retfie ; no, so return and re-enable GIE
;**********The interrupt service routine (if required) goes here*********
 bcf INTCON,INT0IF ; clear interrupt flag
 movf W_SAVE,W ; restore W
 retfie ; return and re-set GIE bit
 END ; all programs must end with this