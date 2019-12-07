.def CurrentThread=R20

.cseg ; segment pamiêci kodu programu
.org 0 RJMP _main ; skok do programu g³ównego
.org OC1Aaddr RJMP _timer_ISR ; skok do obs³ugi przerwania timera

_timer_ISR:
	PUSH R21
	INC CurrentThread
	LDI R21, 1
	AND R21, CurrentThread
	CPI R21, 1
	BREQ Odd
	DEC CurrentThread
	DEC CurrentThread
	Odd:
	POP R21
	NOP
RETI

_main:

;GPIO INIT
LDI R16, $FE
OUT DDRB, R16
LDI R16, 127
OUT DDRD, R16
CLR R20
;timer_init
LDI R16, 9
OUT TCCR1B, R16
LDI R16, HIGH(100)
OUT OCR1AH, R16
LDI R16, LOW(100)
OUT OCR1AL, R16
LDI R16, 192
OUT TIMSK, R16
SEI

ThreadA:
NOP
NOP
NOP
NOP
NOP
RJMP ThreadA