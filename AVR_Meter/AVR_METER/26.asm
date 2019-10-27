MainLoop:
RCALL DelayInMs
RJMP MainLoop

DelayInMs:
	LDI R25, 0
	LDI R24, 5
	Ms:
		STS $60, R24
		STS $61, R25
		RCALL DelayOneMs
		LDS R24, $60
		LDS R25, $61
		SBIW R25:R24, 1
	BRNE Ms
RET

DelayOneMs:
	LDI R25, $7
	LDI R24, $D0
	OneMs:
		SBIW R25:R24, 1
	BRNE OneMs
RET