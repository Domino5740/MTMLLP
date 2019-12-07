.MACRO LOAD_CONST
	LDI @0, LOW(@2)
	LDI @1, HIGH(@2)
.ENDMACRO

.equ Digits_P = PORTB
.equ Segments_P = PORTD

.def ThreadA_LSB = R16
.def ThreadA_MSB = R17
.def ThreadB_LSB = R18
.def ThreadB_MSB = R19
.def CurrentThread = R20

.cseg ; segment pamiêci kodu programu
.org 0 RJMP _main ; skok do programu g³ównego
.org OC1Aaddr RJMP _timer_ISR ; skok do obs³ugi przerwania timera

_timer_ISR:
	INC CurrentThread
	ANDI CurrentThread, 1
	CPI CurrentThread, 1
	BRNE GoToThreadA
	GoToThreadB:
	POP ThreadA_MSB
	POP ThreadA_LSB
	PUSH ThreadB_LSB
	PUSH ThreadB_MSB
	RJMP Exit
	GoToThreadA:
	POP ThreadB_MSB
	POP ThreadB_LSB
	PUSH ThreadA_LSB
	PUSH ThreadA_MSB
	Exit:
RETI

_main:

;GPIO INIT
LDI R23, $FE
OUT DDRB, R23
LDI R23, 127
OUT DDRD, R23
;threads_init
LDI ThreadA_LSB, LOW(ThreadA)
LDI ThreadA_MSB, HIGH(ThreadA)
LDI ThreadB_LSB, LOW(ThreadB)
LDI ThreadB_MSB, HIGH(ThreadB)
;timer_init
LDI R23, 9
OUT TCCR1B, R23
LDI R23, HIGH(100)
OUT OCR1AH, R23
LDI R23, LOW(100)
OUT OCR1AL, R23
LDI R23, 192
OUT TIMSK, R23
CLR R23
SEI

ThreadA:
	LDI R23, 2
	OUT Digits_P, R23
	LDI R23, $3F
	OUT Segments_P, R23
	LOAD_CONST R26, R27, 5000
	OneMsA:
		SBIW R27:R26, 1
	BRNE OneMsA	
RJMP ThreadA

ThreadB:
	LDI R23, 4
	OUT Digits_P, R23
	LDI R23, $06
	OUT Segments_P, R23
	LOAD_CONST R28, R29, 5000
	OneMsB:
		SBIW R29:R28, 1
	BRNE OneMsB
RJMP ThreadB