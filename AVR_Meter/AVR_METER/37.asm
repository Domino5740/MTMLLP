.MACRO LOAD_CONST
LDI @0, LOW(@2)
LDI @1, HIGH(@2)
.ENDMACRO
.equ Digits_P = PORTB
.equ Segments_P = PORTD

MainLoop:
LDI R16, 5
RCALL Square

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

Square:
	LDI R30, Low(Table<<1)
	LDI R31, High(Table<<1)
	ADC R30, R16
	LPM R16, Z
RET

Table: .db 0, 1, 4, 9, 16, 25, 36, 49, 64, 81