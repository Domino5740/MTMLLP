		AREA	MAIN_CODE, CODE, READONLY
		GET		LPC213x.s
		
DIGIT_0 RN R8
DIGIT_1 RN R9
DIGIT_2 RN R10
DIGIT_3 RN R11
CURRENT_DIGIT RN R12

		ENTRY
__main
__use_two_region_memory
		EXPORT			__main
		EXPORT			__use_two_region_memory
		
;IO0DIR = F00F0 ustawienie wyjsciowych portow
	LDR R4, =0xF0000
	LDR R5, =IO0DIR
	STR R4, [R5]
	
;IO1DIR = FF0000 ustawienie wyjsciowych portow
	LDR R4, =0xFF0000
	LDR R5, =IO1DIR
	STR R4, [R5]
;inicjalizacja licznika dekadowego i zerowanie licznika cyfr
	LDR DIGIT_0, =0
	LDR DIGIT_1, =0
	LDR DIGIT_2, =0
	LDR DIGIT_3, =0
	LDR CURRENT_DIGIT, =0

main_loop
;IO0CLR = 0xF0000 wygaszanie wyswietlaczy
	LDR R4, =0xF0000
	LDR R5, =IO0CLR
	STR R4, [R5]
	
;IO1CLR = 0xFF0000 wygaszanie cyfr
	LDR R4, =0xFF0000
	LDR R5, =IO1CLR
	STR R4, [R5]
	
;zmiana wyswietlacza
	LDR R4, =0x80000
	LDR R5, =IO0SET
	MOV R4, R4, LSR CURRENT_DIGIT ;przesuniecie stalej
	STR R4, [R5]
	
;porównanie i przypisanie R6 odpowiedniej wartosci
	CMP CURRENT_DIGIT, #0
	MOVEQ R6, DIGIT_0
	CMP CURRENT_DIGIT, #1
	MOVEQ R6, DIGIT_1
	CMP CURRENT_DIGIT, #2
	MOVEQ R6, DIGIT_2
	CMP CURRENT_DIGIT, #3
	MOVEQ R6, DIGIT_3
	
;zmiana R6 na kod 7seg i zmiana liczby 
	ADR R5, sevseg
	ADD R5, R5, R6
	LDRB R4, [R5]
	LSL R4, #16
	LDR R5, =IO1SET
	STR R4, [R5]
	
;inkrementacja digits - decades counter
	ADD DIGIT_0, #1
	CMP DIGIT_0, #10
	LDREQ DIGIT_0, =0
	ADDEQ DIGIT_1, #1
	CMP DIGIT_1, #10
	LDREQ DIGIT_1, =0
	ADDEQ DIGIT_2, #1
	CMP DIGIT_2, #10
	LDREQ DIGIT_2, =0
	ADDEQ DIGIT_3, #1
	CMP DIGIT_3, #10
	LDREQ DIGIT_3, =0
	
;CURRENT_DIGIT = (CURRENT_DIGIT+1)%4 - inkrementacja licznika cyfr,
	ADD CURRENT_DIGIT, #1
	CMPS CURRENT_DIGIT, #4
	EOREQ CURRENT_DIGIT, CURRENT_DIGIT
	LDR R0, =10
	BL delay_in_ms
	b				main_loop
		
delay_in_ms		LDR R1, =15000
				MUL R0, R1, R0

loop_1ms			SUBS R0, R0, #1
					BNE loop_1ms
				BX LR
				
sevseg DCB 0x3f,0x06,0x5B,0x4F,0x66,0x6d,0x7D,0x07,0x7f,0x6f

	END