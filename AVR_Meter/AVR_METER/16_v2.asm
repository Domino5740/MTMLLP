LDI R20,9
Loop:
		LDI R21, 177
		Loop2:	DEC R21
				NOP
				NOP
		BRNE Loop2
		DEC R20
BRNE Loop
DEC R22
NOP
; 0,01 sekundy
; 0,00125 sekundy
; ((5*R21)+3)*R20)+1016
;(4+[5*R21])*R20-1