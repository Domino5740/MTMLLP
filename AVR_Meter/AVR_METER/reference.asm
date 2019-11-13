 ;### MACROS & defs (.equ)###

; Macro LOAD_CONST loads given registers with immediate value, example: LOAD_CONST  R16,R17 1234 
.MACRO LOAD_CONST  
	LDI @0, LOW(@2)
	LDI @1, HIGH(@2)
.ENDMACRO 

/*** Display ***/
.equ DigitsPort = PORTB             ; TBD
.equ SegmentsPort = PORTD           ; TBD
.equ DisplayRefreshPeriod = 1   ; TBD

; SET_DIGIT diplay digit of a number given in macro argument, example: SET_DIGIT 2
.MACRO SET_DIGIT  
	LDI R17, 2 << @0
	OUT DigitsPort, R17

	MOV R16, Dig_@0
	RCALL DigitTo7segCode
	OUT SegmentsPort, R16
	
	LOAD_CONST R16, R17, DisplayRefreshPeriod
	RCALL DealyInMs

.ENDMACRO 

; ### GLOBAL VARIABLES ###

.def PulseEdgeCtrL=R0
.def PulseEdgeCtrH=R1

.def Dig_0=R2
.def Dig_1=R3
.def Dig_2=R4
.def Dig_3=R5

; ### INTERRUPT VECTORS ###
.cseg		     ; segment pamiêci kodu programu 

.org	 0      rjmp	_main	 ; skok do programu g³ównego
.org OC1Aaddr	rjmp  _Timer_ISR; TBD
.org PCIaddr   rjmp  _ExtInt_ISR; TBD ; skok do procedury obs³ugi przerwania zenetrznego 

; ### INTERRUPT SEERVICE ROUTINES ###

_ExtInt_ISR: 	 ; procedura obs³ugi przerwania zewnetrznego
	push	R16
    push	R17
	push	R20
	IN R20, SREG

	CLC
	ADD R0, R6
	ADC R1, R7

	OUT SREG, R20
	pop		R20
    pop		R17
    pop		R16

reti   ; powrót z procedury obs³ugi przerwania (reti zamiast ret)      

_Timer_ISR:
    push R16
    push R17
    push R18
    push R19
	PUSH R20
	IN R20, SREG
	NOP

	MOV R16, R0
	MOV R17, R1

	LSR R17
	ROR R16

	RCALL _NumberToDigits

	MOV Dig_3, R16
	MOV Dig_2, R17
	MOV Dig_1, R18
	MOV Dig_0, R19

	CLR R0
	CLR R1

	OUT SREG, R20
	POP R20
	pop R19
    pop R18
    pop R17
    pop R16

  reti

; ### MAIN PROGAM ###

_main: 
    ; *** Initialisations ***
	LDI R17, 1
	MOV R6, R17
	CLR R7
	LDI R30, LOW(TABLE<<1)
	LDI R31, HIGH(TABLE<<1)

    ;--- Ext. ints --- PB0
    LDI R17, 32
	OUT GIMSK, R17
	LDI R17, 1
	OUT PCMSK0, R17

	;--- Timer1 --- CTC with 256 prescaller
    LDI R17, 12
	OUT TCCR1B, R17
	LDI R17, HIGH(31250)
	OUT OCR1AH, R17
	LDI R17, LOW(31250)
	OUT OCR1AL, R17
	LDI R17, 192
	OUT TIMSK, R17
			
	;---  Display  --- 
	LDI R17, 254
	OUT DDRB, R17
	LDI R17, 127
	OUT DDRD, R17

	; --- enable gloabl interrupts
    SEI



MainLoop:   ; presents Digit0-3 variables on a Display
			SET_DIGIT 0
			SET_DIGIT 1
			SET_DIGIT 2
			SET_DIGIT 3

			RJMP MainLoop

; ### SUBROUTINES ###

;*** NumberToDigits ***
;converts number to coresponding digits
;input/otput: R16-17/R16-19
;internals: X_R,Y_R,Q_R,R_R - see _Divider

; internals
.def Dig0=R22 ; Digits temps
.def Dig1=R23 ; 
.def Dig2=R24 ; 
.def Dig3=R25 ; 

_NumberToDigits:

	push Dig0
	push Dig1
	push Dig2
	push Dig3

	; thousands 
    LOAD_CONST R18, R19, 1000
	RCALL _Divide
	MOV Dig3, R18

	; hundreads 
    LOAD_CONST R18, R19, 100
	RCALL _Divide
	MOV Dig2, R18   

	; tens 
    LOAD_CONST R18, R19, 10
	RCALL _Divide
	MOV Dig1, R18   

	; ones 
    MOV Dig0, R16 

	; otput result
	mov R16,Dig0
	mov R17,Dig1
	mov R18,Dig2
	mov R19,Dig3

	pop Dig3
	pop Dig2
	pop Dig1
	pop Dig0

	ret

;*** Divide ***
; divide 16-bit nr by 16-bit nr; X/Y -> Qotient,Reminder
; Input/Output: R16-19, Internal R24-25

; inputs
.def XL=R16 ; divident  
.def XH=R17 

.def YL=R18 ; divider
.def YH=R19 

; outputs

.def RL=R16 ; reminder 
.def RH=R17 

.def QL=R18 ; quotient
.def QH=R19 

; internal
.def QCtrL=R24
.def QCtrH=R25

_Divide:push R24 ;save internal variables on stack
        push R25
		CLR R24
		CLR R25
        COMPARE:CP R16, R18
				CPC R17, R19
				BRLO EXIT
		SUB R16, R18
		SBC R17, R19
		ADIW R25:R24, 1		
		BRNE COMPARE
		EXIT:
			MOV R18, R24
			MOV R19, R25
		pop R25 ; pop internal variables from stack
		pop R24

		ret

; *** DigitTo7segCode ***
; In/Out - R16

Table: .db 0x3f,0x06,0x5B,0x4F,0x66,0x6d,0x7D,0x07,0xff,0x6f

DigitTo7segCode:
	push R30
	push R31

	ADD R30, R16
	ADC R31, R7
	LPM R16, Z

	pop R31
	pop R30
ret

; *** DelayInMs ***
; In: R16,R17

DealyInMs:  
            push R24
			push R25

            DELAY_LOOP: RCALL OneMsLoop
						SUB R16, R6
						SBC R17, R7
						BRNE DELAY_LOOP
			pop R25
			pop R24

			ret

; *** OneMsLoop ***
OneMsLoop:	
			push R24
			push R25 
			
			LOAD_CONST R24,R25,2000                    

L1:			SBIW R24:R25,1 
			BRNE L1

			pop R25
			pop R24

			ret



