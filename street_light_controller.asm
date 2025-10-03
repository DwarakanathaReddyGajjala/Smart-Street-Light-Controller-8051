ORG 0400H
DB "VISITOR COUNTER PERSON EXIT PERSON ENTRY COUNT: NO PERSON INVALID OPERATION"

ORG 0000H

MOV DPTR,#0400H          ; Data pointer at ROM address 0400H
MOV P1,#0FFH             ; Port 1 as input
MOV R6,#00H              ; R6 acts as person counter

ACALL Lcd_setup
ACALL Display
ACALL Check

; ---------------- LCD Setup ----------------
Lcd_setup:
    MOV A,#38H           ; Setup: 2 line, 5x7 matrix display
    ACALL command
    MOV A,#0CH           ; Display ON, Cursor OFF
    ACALL command
    MOV A,#01H           ; Clear old data
    ACALL command
    MOV A,#06H           ; Cursor increment mode
    ACALL command
    MOV A,#80H           ; Cursor home (leftmost)
    ACALL command
    RET

; ---------------- LCD Command ----------------
command:
    MOV P2,A
    CLR P3.0             ; RS = 0 (command)
    CLR P3.1             ; R/W = 0 (write)
    SETB P3.2            ; Latch high
    CLR P3.2             ; Falling edge
    ACALL Delay
    RET

; ---------------- LCD Data Write ----------------
work:
    MOV P2,A
    SETB P3.0            ; RS = 1 (data)
    CLR P3.1             ; R/W = 0 (write)
    SETB P3.2
    CLR P3.2
    ACALL Delay
    RET

; ---------------- Delay Routine ----------------
Delay:                   ; ~10 ms delay for LCD
    MOV TMOD,#01H        ; Timer0, Mode 1
    MOV TL0,#0D4H        ; Lower byte
    MOV TH0,#060H        ; Upper byte
    MOV TCON,#10H        ; Start Timer0
WAIT: 
    JNB TCON.5,WAIT      ; Wait for overflow
    MOV TCON,#00H        ; Stop Timer0
    RET

; ---------------- Display Welcome Message ----------------
Display:
    MOV R3,#0Fh          ; End address
    MOV R2,#00h          ; Start address
    ACALL lcd_displayer
    RET

; ---------------- Check Entry/Exit ----------------
Check:
    ACALL Delay
    MOV A,P1             ; Read sensor input
    MOV B,#00H
    CJNE A,B,find        ; If not 00H, vehicle detected
    SJMP Check

find:
    ACALL Delay
    CJNE A,#04h,EXIT     ; If not entry, check exit
    CLR C
    CJNE A,#08h,ENTRY    ; If not exit, must be entry

; ---------------- Entry Routine ----------------
ENTRY:
    ACALL Delay
    ACALL Lcd_setup
    MOV R2,#1Ch
    MOV R3,#28h
    ACALL lcd_displayer
    ACALL Entry_count
    SJMP Check

Entry_count:
    MOV A,#0C0H
    ACALL command
    MOV R2,#29h
    MOV R3,#2Fh
    ACALL lcd_displayer
    ; Increment counter
    CLR C
    MOV A,R6
    ADD A,#01
    MOV R6,A
    DA A
    MOV R2,A
    ACALL ConvertDisplay
    RET

; ---------------- Exit Routine ----------------
EXIT:
    ACALL Delay
    ACALL Lcd_setup
    CJNE R6,#00h,counter
    ; If no persons, show error
    MOV R2,#3Ah
    MOV R3,#41h
    ACALL lcd_displayer
    MOV A,#0C0H
    ACALL command
    MOV R2,#42h
    MOV R3,#4Bh
    ACALL lcd_displayer
    ACALL Delay
    SJMP Check

counter:
    MOV R2,#10h
    MOV R3,#1Bh
    ACALL lcd_displayer
    ACALL Exit_count
    SJMP Check

Exit_count:
    MOV A,#0C0H
    ACALL command
    CLR C
    CJNE R6,#00h,start
    ACALL message
    RET

start:
    MOV A,R6
    CLR C
    SUBB A,#01
    MOV R6,A
    DA A
    MOV R4,A
    CLR C
    CJNE R6,#00h,continue
    ACALL message

continue:
    MOV R2,#29h
    MOV R3,#2Fh
    CLR C
    ACALL lcd_displayer
    MOV A,R4
    MOV R2,A
    ACALL ConvertDisplay
    ACALL Check

; ---------------- Convert Binary to ASCII ----------------
ConvertDisplay:
    CLR C
    MOV B,#10h
    MOV A,R2
    DIV AB
    ADD A,#30h
    ACALL work
    MOV A,B
    ADD A,#30h
    ACALL work
    RET

; ---------------- Error Message ----------------
message:
    MOV R2,#30h
    MOV R3,#39h
    ACALL lcd_displayer
    ACALL Check
    RET

; ---------------- LCD Display Routine ----------------
lcd_displayer:
    MOV A,R2
    MOV B,R3
do:
    MOVC A,@A+DPTR
    ACALL work
    INC R2
    CLR C
    MOV A,R2
    CJNE A,B,do
    RET

Here: 
    SJMP Here
END
