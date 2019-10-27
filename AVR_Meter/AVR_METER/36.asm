// Program odczytuje 4 bajty z tablicy sta³ych zdefiniowanej w pamiêci kodu do rejestrów R20...R23
ldi R30, Low(Table<<1) // inicjalizacja rejestru Z
ldi R31, High(Table<<1)
lpm R20, Z // odczyt pierwszej sta³ej z tablicy Table
adiw R31:R30,1 // inkrementacja Z
lpm R21, Z // odczyt drugiej sta³ej
adiw R31:R30,1 // inkrementacja Z
lpm R22, Z // odczyt trzeciej sta³ej
adiw R31:R30,1 // inkrementacja Z
lpm R23, Z // odczyt czwartej sta³ej
nop
Table: .db 0x57, 0x58, 0x59, 0x5A // UWAGA: liczba bajtów zdeklarowanych w pamiêci kodu musi byæ parzysta