.MACRO LOAD_CONST
LDI @0, LOW(@2)
LDI @1, HIGH(@2)
.ENDMACRO
.equ Digits_P = PORTB
.equ Segments_P = PORTD
.def Digit_0 = R2
.def Digit_1 = R3
.def Digit_2 = R4
.def Digit_3 = R5


LDI R18, $FF

LDI R19, $3F
MOV R2, R19
LDI R19, $06
MOV R3, R19
LDI R19, $5B
MOV R4, R19
LDI R19, $4F
MOV R5, R19

LDI R20, $02
LDI R21, $04
LDI R22, $08
LDI R23, $10
OUT DDRD, R18
OUT DDRB, R18

MainLoop:

OUT Digits_P, R20
OUT Segments_P, Digit_0
RCALL DelayInMs
OUT Digits_P, R21
OUT Segments_P, Digit_1
RCALL DelayInMs
OUT Digits_P, R22
OUT Segments_P, Digit_2
RCALL DelayInMs
OUT Digits_P, R23
OUT Segments_P, Digit_3
RCALL DelayInMs
RJMP MainLoop

DelayInMs:
	LOAD_CONST R16, R17, 5
	MOV R25, R17
	MOV R24, R16
	Ms:
		PUSH R25
		PUSH R24
		RCALL DelayOneMs
		POP R24
		POP R25
		SBIW R25:R24, 1
	BRNE Ms
RET

DelayOneMs:
	LOAD_CONST R24, R25, 2000
	OneMs:
		SBIW R25:R24, 1
	BRNE OneMs
RET