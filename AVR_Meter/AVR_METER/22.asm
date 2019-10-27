MainLoop:
LDI R22, 2
RCALL DelayInMs
RJMP MainLoop

DelayInMs:
	Loop:
		LDI R25, $7
		LDI R24, $D0
		SUBB:
			SBIW R25:R24, 1
		BRNE SUBB
	DEC R22
	BRNE Loop
RET