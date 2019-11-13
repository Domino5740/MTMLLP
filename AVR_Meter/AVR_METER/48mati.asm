.MACRO LOAD_CONST
	LDI @1,LOW(@2)
	LDI @0,HIGH(@2)
.ENDMACRO 


.MACRO SET_DIGIT
	PUSH R16
	MOV R16, Dig@0
	RCALL DigitTo7segCode
	LDI R20, (2)<<@0 
	OUT Segments_P, R16
	OUT Digits_P, R20
	RCALL DelayNmSecconds
	POP R16
.ENDMACRO



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
; digit temps
.def Dig0=R22 ; 
.def Dig1=R23 ;
.def Dig2=R24 ;
.def Dig3=R25 ;


.cseg
.org 0			RJMP	Start
.org OC1Aaddr	RJMP	timer_isr
.org $0B		rjmp	pulse_isr

pulse_isr:
	push	R16
    push	R17
	push	R20
	IN R20, SREG

	CLC
	ADD R0, R3
	ADC R1, R2

	MOV R16, R0
	MOV R17, R1
	LSR		R17
	ROR		R16
	RCALL NumberToDigits

	OUT SREG, R20
	pop		R20
    pop		R17
    pop		R16
	reti

timer_isr:
	push	R16
    push	R17
	push	R20
	IN R20, SREG

	MOV R16, R0
	MOV R17, R1
	LSR		R17
	ROR		R16
	RCALL NumberToDigits


	OUT SREG, R20
	pop		R20
    pop		R17
    pop		R16
reti

START:

LDI		R17, 12
OUT		TCCR1B, R17
LDI		R17, 0
OUT		TCCR1A, R17
LDI		R17, HIGH(31250)
OUT		OCR1AH, R17
LDI		R17, LOW(31250)
OUT		OCR1AL, R17
LDI		R17, $C0
OUT		TIMSK, R17

LDI		R17, $20
OUT		GIMSK, R17
OUT		GIFR, R17
LDI		R17, $01
OUT		PCMSK0, R17

SEI

LOAD_CONST R27, R26, 1


LDI R30, Low(Table<<1) 
LDI R31, High(Table<<1)


LDI R19, 127
LDI R20, $FE
OUT DDRD, R19
OUT DDRB, R20


.EQU Digits_P = PORTB 
.EQU Segments_P = PORTD 


Table: .db 0x3F, 0x6, 0x5b, 0x4F, 0x66, 0x6D, 0x7D, 0x7, 0x7F, 0x6F


CLR R0
CLR R1
CLR R2

LDI R29, 1
MOV R3, R29


clr R16
clr R17
RCALL NumberToDigits

MAIN:
	SET_DIGIT 3
	SET_DIGIT 2
	SET_DIGIT 1
	SET_DIGIT 0
	NOP
RJMP MAIN

Divide:
	PUSH R24
	PUSH R25
	CLR R24
	CLR R25
	Compare:
		CP R16, R18
		CPC R17,R19
		BRLO Exit
	SUB R16,R18
	SBC R17,R19
	ADIW R25:R24, 1
	RJMP Compare
	Exit:
	MOV R18, R24 
	MOV R19, R25
	POP R25
	POP R24
RET

NumberToDigits:
	LOAD_CONST YH, YL, 1000
	RCALL Divide
	MOV Dig0, QL
	LOAD_CONST YH, YL, 100
	RCALL Divide
	MOV Dig1, QL
	LOAD_CONST YH, YL, 10
	RCALL Divide
	MOV Dig2, QL
	MOV Dig3, RL
RET

DigitTo7segCode:
	PUSH R30
	PUSH R31
	ADD R30, R16
	BRCS Increment_old
	LPM R16, Z 
	POP R31
	POP R30

RET

Increment_old:
	INC R31


DelayNmSecconds:
	PUSH R26
	PUSH R27 
	DelayLoop:
		RCALL	DelaymSeccond
		SBIW	R27:R26,1
		BRNE	DelayLoop
	POP R27
	POP R26
RET

DelaymSeccond:
	PUSH R26
	PUSH R27
	LOAD_CONST R27, R26, 1998
	ODEJMUJ: SBIW R27:R26, 1
	BRNE ODEJMUJ
	POP R27
	POP R26
RET