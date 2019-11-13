.MACRO LOAD_CONST
	LDI @0, LOW(@2)
	LDI @1, HIGH(@2)
.ENDMACRO

.MACRO SET_DIGIT
	LDI R28, (1<<(@0+1))
	OUT Digits_P, R28
	PUSH R16
	RCALL DigitTo7segCode
	OUT Segments_P, R16
	POP R16
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
.def Counter_3 = R16
.def Counter_2 = R17
.def Counter_1 = R18
.def Counter_0 = R19
.def Loop_Con = R20


SER R20
OUT DDRD, R20
OUT DDRB, R20
LDI Loop_Con, 10

MainLoop:
SET_DIGIT 3
PUSH Counter_3
MOV Counter_3, Counter_2
SET_DIGIT 2
MOV Counter_3, Counter_1
SET_DIGIT 1
MOV Counter_3, Counter_0
SET_DIGIT 0
POP Counter_3

INC Counter_3
RCALL DelayInMs
CP Counter_3, Loop_Con
BRNE MainLoop
INC Counter_2
CLR Counter_3
CP Counter_2, Loop_Con
BRNE MainLoop

CLR Counter_2
INC Counter_1
CLR Counter_3
RCALL DelayInMs
CP Counter_1, Loop_Con
BRNE MainLoop

CLR Counter_1
INC Counter_0
CLR Counter_3
RCALL DelayInMs
CP Counter_0, Loop_Con
BRNE MainLoop

CLR Counter_3
CLR Counter_2
CLR Counter_1
CLR Counter_0
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
	LDI R30, LOW(seg<<1)
	ADD R30, R16
	LPM R16, Z
	POP R30
RET

seg: .db $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F