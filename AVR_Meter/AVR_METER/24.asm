MainLoop:
RCALL DelayInMs
RJMP MainLoop

DelayInMs:
	LDI R25, 0
	LDI R24, 5
	Ms:
		RCALL DelayOneMs
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