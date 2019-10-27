MainLoop:
RCALL DelayNCycles
RJMP MainLoop
DelayNCycles:
	NOP
	RCALL BANG
	NOP
	NOP
RET
	BANG:
		NOP
		NOP
	RET
;zgadzaja sie