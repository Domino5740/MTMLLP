.MACRO LOAD_CONST
LDI @0, LOW(@2)
LDI @1, HIGH(@2)
.ENDMACRO
.equ Digits_P = PORTB
.equ Segments_P = PORTD

LDI R18, $FF

LDI R19, 118
MOV R2, R19
LDI R19, 62
MOV R3, R19
LDI R19, 14
MOV R4, R19
LDI R19, 62
MOV R5, R19

LDI R20, $02
LDI R21, $04
LDI R22, $08
LDI R23, $10
OUT DDRD, R18
OUT DDRB, R18

MainLoop:

OUT Digits_P, R20
OUT Segments_P, R2
RCALL DelayInMs
OUT Digits_P, R21
OUT Segments_P, R3
RCALL DelayInMs
OUT Digits_P, R22
OUT Segments_P, R4
RCALL DelayInMs
OUT Digits_P, R23
OUT Segments_P, R5
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