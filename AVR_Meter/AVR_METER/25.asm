MainLoop:
RCALL DelayInMs
RJMP MainLoop

DelayInMs:
	LDI R24, 5
	Ms:
		STS $60, R24 
		RCALL DelayOneMs
		LDS R24, $60
		DEC R24
	BRNE Ms
RET

DelayOneMs:
	LDI R25, $7
	LDI R24, $D0
	OneMs:
		SBIW R25:R24, 1
	BRNE OneMs
RET