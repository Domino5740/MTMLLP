LDI R20, 8
Loop:
		LDI R21, 224
		Loop2:	DEC R21
				NOP
				NOP
		BRNE Loop2
		DEC R20
BRNE Loop