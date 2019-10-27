.MACRO LOAD_CONST
	LDI @0, LOW(@2)
	LDI @1, HIGH(@2)
.ENDMACRO

.MACRO SET_DIGIT
	LDI R28, 1<<(@0+1)
	OUT Digits_P, R28
	LDI R16, @1
	RCALL DigitTo7segCode
	OUT Segments_P, R16
	RCALL DelayInMs
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


SER R19
OUT DDRD, R19
OUT DDRB, R19

MainLoop:
SET_DIGIT 0, 1
SET_DIGIT 1, 3
SET_DIGIT 2, 3
SET_DIGIT 3, 7
RJMP MainLoop

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
	PUSH R31
	LDI R30, LOW(seg<<1)
	LDI R31, HIGH(seg<<1)
	ADC R30, R16
	LPM R16, Z
	POP R31
	POP R30
RET

seg: .db $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F