.MACRO LOAD_CONST
	LDI @0, LOW(@2)
	LDI @1, HIGH(@2)
.ENDMACRO

.MACRO SET_DIGIT
	LDI R16, 2<<@0
	OUT Digits_P, R16
	MOV R16, Dig@0
	RCALL DigitTo7SegCode
	OUT Segments_P, R16
	RCALL DelayOneMs
.ENDMACRO

.equ Digits_P = PORTB
.equ Segments_P = PORTD

;*** Divide ***
; X/Y -> Qotient,Reminder
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

;*** NumberToDigits ***
;input : Number: R16-17
;output: Digits: R16-19
;internals: X_R,Y_R,Q_R,R_R - see _Divider
; internals
.def Dig0=R20 ; Digits temps
.def Dig1=R21 ;
.def Dig2=R22 ;
.def Dig3=R23 ;

.def PulseEdgeCtrL=R28
.def PulseEdgeCtrH=R29

.cseg ; segment pamiêci kodu programu
.org 0 RJMP _main ; skok do programu g³ównego
.org OC1Aaddr RJMP _timer_ISR ; skok do obs³ugi przerwania timera
.org PCIBaddr RJMP _ext_ISR

_timer_ISR:
	PUSH R4
	IN R4, SREG
	MOV R17, PulseEdgeCtrH
	MOV R16, PulseEdgeCtrL
	LSR R17
	ROR R16
	RCALL NumberToDigits
	CLR PulseEdgeCtrL
	CLR PulseEdgeCtrH
	OUT SREG, R4
	POP R4
RETI
_ext_ISR:
	PUSH R4
	IN R4, SREG
	ADIW PulseEdgeCtrH:PulseEdgeCtrL, 1
	OUT SREG, R4
	POP R4
RETI

_main:

;GPIO INIT
LDI R16, $FE
OUT DDRB, R16
LDI R16, 127
OUT DDRD, R16

;ext_init
LDI R16, 1
OUT PCMSK0, R16
LDI R16, 32
OUT GIMSK, R16

;timer_init
LDI R16, 0
OUT TCCR1A, R16
LDI R16, 12
OUT TCCR1B, R16
LDI R16, HIGH(31249)
OUT OCR1AH, R16
LDI R16, LOW(31249)
OUT OCR1AL, R16
LDI R16, 192
OUT TIMSK, R16
SEI

MainLoop:
SET_DIGIT 0
SET_DIGIT 1
SET_DIGIT 2
SET_DIGIT 3
NOP
RJMP MainLoop

DelayInMs:
	PUSH R25
	PUSH R24
	PUSH R16
	PUSH R17
	MOV R25, R17
	MOV R24, R16
		Delay:
		RCALL DelayOneMs
		SBIW R25:R24, 1
		BRNE Delay
	POP R17
	POP R16
	POP R24
	POP R25
RET

DelayOneMs:
	PUSH R25
	PUSH R24
	LOAD_CONST R24, R25, 2000
		OneMs:
		SBIW R25:R24, 1
	BRNE OneMs
	POP R24
	POP R25
RET

DigitTo7SegCode:
	PUSH R30
	LDI R30, LOW(seg<<1)
	ADD R30, R16
	LPM R16, Z
	POP R30
RET

seg: .db $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F

Divide:
	PUSH QCtrL
	PUSH QCtrH
	CLR QCtrL
	CLR QCtrH
	Compare:
		CP XL, YL
		CPC XH, YH
		BRLO Exit
		SUB XL, YL
		SBC XH, YH
		ADIW QctrH:QctrL, 1
		BRNE Compare
	Exit:
		MOV QL, QctrL
		MOV QH, QctrH
	POP QCtrH
	POP QCtrL
RET

NumberToDigits:
	PUSH R18
	PUSH R19
	LOAD_CONST R18, R19, 1000
	RCALL Divide
	MOV Dig0, QL
	LOAD_CONST R18, R19, 100
	RCALL Divide
	MOV Dig1, QL
	LOAD_CONST R18, R19, 10
	RCALL Divide
	MOV Dig2, QL
	MOV Dig3, RL
	POP R19
	POP R18
RET