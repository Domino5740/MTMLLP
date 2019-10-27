LDI R22, 1
Loop3:
	LDI R20,11
	Loop:
			LDI R21, 145
			Loop2:	DEC R21
					NOP
					NOP
			BRNE Loop2
			DEC R20
	BRNE Loop
	DEC R22
BRNE Loop3
NOP


;( (3+(5*R21))*R20 +3)*R22