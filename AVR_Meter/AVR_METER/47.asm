.MACRO LOAD_CONST
	LDI @0, LOW(@2)
	LDI @1, HIGH(@2)
.ENDMACRO

.MACRO SET_DIGIT
	LDI R17, (1<<(@0+1))
	OUT Digits_P, R17
	MOV R16, Dig@0
	RCALL DigitTo7segCode
	OUT Segments_P, R16
	RCALL DelayOneMs
.ENDMACRO

.equ Digits_P = PORTB
.equ Segments_P = PORTD
.equ Digit_0 = 0
.equ Digit_1 = 1
.equ Digit_2 = 2
.equ Digit_3 = 3
.equ Digit_4 = 4
.equ Digit_5 = 5
.equ Digit_6 = 6
.equ Digit_7 = 7
.equ Digit_8 = 8
.equ Digit_9 = 9

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
; internals
.def Dig0 = R20
.def Dig1 = R21
.def Dig2 = R22
.def Dig3 = R23

.def PulseEdgeCtrL = R28
.def PulseEdgeCtrH = R29
.def CondL = R26
.def CondH = R27

;********************************

.cseg ; segment pamiêci kodu programu
.org 0 rjmp _main ; skok po resecie (do programu g³ównego)
.org OC1Aaddr rjmp _timer_isr ; skok do obs³ugi przerwania timera

_timer_isr: ; procedura obs³ugi przerwania timera
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R19
	ADIW PulseEdgeCtrH:PulseEdgeCtrL, 1
	MOV R17, PulseEdgeCtrH
	MOV R16, PulseEdgeCtrL
	RCALL NumberToDigits
	MOV Dig3, R16
	MOV Dig2, R17
	MOV Dig1, R18
	MOV Dig0, R19
	POP R19
	POP R18
	POP R17
	POP R16
reti ; powrót z procedury obs³ugi przerwania (reti zamiast ret)

_main:

;inicjalizacja timera i kierunku pinów
SER R20
OUT DDRD, R20
OUT DDRB, R20
LOAD_CONST CondL, CondH, 9999
CLR Dig0

;inicjalizacja counter
LDI R17, 0
OUT TCCR1A, R17
LDI R17, 12
OUT TCCR1B, R17
LDI R17, HIGH(312)
OUT OCR1AH, R17
LDI R17, LOW(312)
OUT OCR1AL, R17
LDI R17, 192
OUT TIMSK, R17
SEI

MainLoop:
SET_DIGIT 0
SET_DIGIT 1
SET_DIGIT 2
SET_DIGIT 3
CP PulseEdgeCtrL, CondL
CPC PulseEdgeCtrH, CondH
BRLO MainLoop
CLR PulseEdgeCtrL
CLR PulseEdgeCtrH
RJMP MainLoop

;___________________
;Subprograms
DelayInMs:
	PUSH R24
	PUSH R25
	PUSH R16
	PUSH R17
	LOAD_CONST R16, R17, 5
	MOV R25, R17
	MOV R24, R16
	POP R17
	POP R16
	Ms:
		RCALL DelayOneMs
		SBIW R25:R24, 1
	BRNE Ms
	POP R25
	POP R24
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

DigitTo7segCode:
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
		BRLO EXIT
		SUB XL, YL
		SBC XH, YH
		ADIW QctrH:QctrL, 1
		BRNE Compare
	EXIT:
		MOV QL, QctrL 
		MOV QH, QctrH
		POP QCtrH
		POP QCtrL
RET


NumberToDigits:
	PUSH Dig0
	PUSH Dig1
	PUSH Dig2
	PUSH Dig3
	;1k
	LOAD_CONST YL, YH, 1000
	RCALL Divide
	MOV Dig0, YL
	;100
	LOAD_CONST YL, YH, 100
	RCALL Divide
	MOV Dig1, YL
	;10
	LOAD_CONST YL, YH, 10
	RCALL Divide
	MOV Dig2, YL
	;1
	MOV Dig3, XL
	;output
	MOV XL, Dig3
	MOV XH, Dig2
	MOV YL, Dig1
	MOV YH, Dig0
	POP Dig3
	POP Dig2
	POP Dig1
	POP Dig0
RET