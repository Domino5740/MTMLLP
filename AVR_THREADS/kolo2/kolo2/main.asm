.MACRO LOAD_CONST  
 ldi  @0,low(@2)
 ldi  @1,high(@2)
.ENDMACRO 

.equ DigitsPort = PORTB
.equ SegmentsPort  = PORTD
.def ThreadA_LSB = R16
.def ThreadA_MSB = R17
.def ThreadB_LSB = R18
.def ThreadB_MSB = R19
.def CurrentThread = R20

.cseg		     ; segment pamiêci kodu programu 

.org	 0      rjmp	_main	 ; skok do programu g³ównego
.org OC1Aaddr	rjmp _Timer_ISR


_Timer_ISR:
	IN R2, SREG
	INC CurrentThread
	ANDI CurrentThread, 1
	CPI CurrentThread, 1
	BRNE GoToThreadA
	GoToThreadB:
	MOV R0, R2
	OUT SREG, R1
	POP ThreadA_MSB
	POP ThreadA_LSB
	PUSH ThreadB_LSB
	PUSH ThreadB_MSB
reti
	GoToThreadA:
	MOV R1, R2
	OUT SREG, R0
	POP ThreadB_MSB
	POP ThreadB_LSB
	PUSH ThreadA_LSB
	PUSH ThreadA_MSB
reti

_main: 
			// Ports
			LDI R16,0x06
			OUT DDRB,R16

			LDI R16,0xFF
			OUT DDRD,R16
			LDI R16, 2
			MOV R3, R16
			LDI R16, 4
			MOV R4, R16
			LDI R16, $3F
			OUT SegmentsPort, R16

			; *** Timer1 ***
			.equ TimerPeriodConst=100

			ldi R16, (1<<CS10)|(1<<WGM12) ; prescaler 256 & ctc mode
			out TCCR1B,R16

			ldi R16,high(TimerPeriodConst); 
			out OCR1AH,R16

			ldi R16,low(TimerPeriodConst) 
			out OCR1AL,R16 

			ldi R16,1<<OCIE1A ; interrupt on match
			out TIMSK,R16 
			;Threads
			LDI ThreadA_LSB, LOW(ThreadA)
			LDI ThreadA_MSB, HIGH(ThreadA)
			LDI ThreadB_LSB, LOW(ThreadB)
			LDI ThreadB_MSB, HIGH(ThreadB)
			CLR CurrentThread
			SEI

			ThreadA:
			LOAD_CONST R24, R25, 500
			L2A:
	 			LOAD_CONST R26, R27, 2000
				L1A:
					SBIW R26:R27, 1
				BRNE L1A
            SBIW  R24:R25,1 
			BRNE  L2A
			EOR R5, R3
			OUT DigitsPort, R5
			RJMP ThreadA

			ThreadB:
			LOAD_CONST R28, R29, 100
			L2B:
	 			LOAD_CONST R30, R31, 2000
				L1B:
					SBIW R30:R31, 1
				BRNE L1B
            SBIW  R28:R29,1 
			BRNE  L2B
			EOR R5, R4
			OUT DigitsPort, R5
			RJMP ThreadB