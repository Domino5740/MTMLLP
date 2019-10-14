LDI R22, 1
Loop3:
	LDI R20,8
	Loop:
			LDI R21, 193
			Loop2:	DEC R21
					NOP
					NOP
			BRNE Loop2
			DEC R20
	BRNE Loop
	DEC R22
BRNE Loop3
; [((5*R21)+3)*R20)+1018]*R22