org 0400H 
DB "VISITOR COUNTER PERSON EXIT PERSON ENTRY COUNT: NO PERSON INVALID 
OPERATION" 
 
 
org 0000H 
 
MOV DPTR,#0400H   ; its used as data pointer that means its locates at 0400H ADDRESS of ROM 
 
MOV P1,#0FFH            ; assigning PORT 1 as input 
 
MOV R6,#00h             ; R6 ACTS AS COUNTER 
 
ACALL Lcd_setup 
 
ACALL Display 
 
ACALL Check 
 
Lcd_setup: 
MOV A,#38H               ;setup 2 line 5*7 matrix display 
ACALL command 
MOV A,#0CH               ;Display ON and cursor ON and cursor OFF 
ACALL command 
MOV A,#01H               ;Clear the old data 
ACALL command 
MOV A,#06H              ; cursor increment mode 
ACALL command 
MOV A,#80H              ;cursor home and starts left most point 
ACALL command 
RET 
 
 
command: 
   MOV P2,A             ;command on port A 
   CLR P3.0             ; register select as 0 for command 
   CLR P3.1             ; display mode as write mode(R/!W) 
   SETB P3.2            ; Make latch as 1 
   CLR P3.2             ; to falling edge 
   ACALL Delay 
   RET 
 
work: 
   MOV P2,A     ;data on port A 
   SETB P3.0    ; register select as 1 for data 
   CLR P3.1     ; display mode as write mode(R/!W) 
   SETB P3.2    ; Make latch as 1 
   CLR P3.2     ; to falling edge 
   ACALL Delay 
   RET 
 
 
 
Delay:                                               ;10ms delay for LCD 
   SOLN: MOV TMOD, #01H        ; Program        TMOD -->(0000   0001)2  ...     Timer0 , Mode1 
   MOV TL0, #0D4H                       ;Load   lower   byte    of      Count 
   MOV TH0, #060H                       ;Load   upper   byte    of      Count 
   MOV TCON, #10H                       ;Program TCON   --> (0001       0000)2 …        start   Time 
   WAIT: JNB TCON.5, WAIT         ;Wait for overflow 
   MOV TCON, #00H                       ;Stop   Timer0 
   RET 
 
 
Display: 
   MOV R3,#0Fh                  ;display of welcome message 
   MOV R2,#00h 
   ACALL lcd_displayer 
   RET 
 
 
Check: 
   ACALL Delay 
   MOV A,P1              ;read the data 
   MOV B,#00H 
   CJNE A,B,find        ;check the data if 00h(initial case) 
   SJMP Check 
 
                               
find: 
   ACALL Delay 
   CJNE A,#04h,EXIT      ;checking with entry if not equal than its must be exit 
   CLR C 
   CJNE A,#08h,ENTRY  ;checking with eXIT if not equal than its must be ENTRY 
 
                          
ENTRY: 
   ACALL Delay 
   ACALL Lcd_setup 
   MOV R2,#1Ch                  ; displaying of person entering 
   MOV R3,#28h 
   ACALL lcd_displayer 
   ACALL Entry_count            ; counting of persons 
   SJMP Check 
 
                            
Entry_count: 
   MOV A,#0C0H 
   ACALL command 
   MOV R2,#29h                  ;displaying of "COUNT:" 
   MOV R3,#2Fh 
   ACALL lcd_displayer 
 
   
 
 
                                                ;count increment 
   CLR C 
   MOV A,R6                          ; getting data from R6 register 
   ADD A,#01                        ; adding "1" 
   MOV R6,A                          ;new data stored back to R6 counter register 
   DA A                                    ; converting from hex to decimal value (after addition only) 
   MOV R2,A 
   ACALL ConvertDisplay    ; converting data to ASCII code 
   RET 
 
EXIT: 
   ACALL Delay 
   ACALL Lcd_setup 
   CJNE R6,#00h,counter         ; check the counter 
   MOV R2,#3Ah 
   MOV R3,#41h 
   ACALL lcd_displayer             ; if zero then give error message "INVALID" 
   MOV A,#0C0H                         ; Force cursor to second line 
   ACALL command 
   MOV R2,#42h                          ; showing of error message "Operation" 
   MOV R3,#4Bh 
   ACALL lcd_displayer 
   ACALL Delay                             ;go back to checking 
   SJMP Check 
 
counter:                         
   MOV R2,#10h 
   MOV R3,#1Bh 
   ACALL lcd_displayer 
   ACALL Exit_count             ; counting of persons 
   SJMP Check 
                            
Exit_count: 
   MOV A,#0C0H 
   ACALL command 
    CLR C 
   CJNE R6,#00h,start           ; check for zero if zero then display NO PERSON 
   ACALL message 
   RET 
 
start: 
   MOV A,R6                      ;get data from counter 
   CLR C                               ; clear carry other wise it subtraction would be with carry 
   SUBB A,#01                   ; subtract with "01" 
   MOV R6,A                       ; store to R6 
   DA A                                 ; converting from hex to decimal value (after addition only) 
   MOV R4,A                       ; lets store it at R4 (DAA data) upcoming operations may distrub A 
   CLR C 
   CJNE R6,#00h,continue                ;BEFORE MOVING ON LETS CHECK IF ANY PERSON IS THERE 
   ACALL message 
 
 
 
 
continue:                       ; 
   MOV R2,#29h 
   MOV R3,#2Fh 
   CLR C 
   ACALL lcd_displayer 
   MOV A,R4                     ;value showing 
   MOV R2,A 
   ACALL ConvertDisplay 
   ACALL Check 
 
 
 
ConvertDisplay: 
    CLR C   ; Clear carry flag 
    MOV B,#10h 
    MOV A,R2 
    DIV AB                   ; Divide A by B, quotient in A, remainder in B 
    ADD A, #30h         ; Convert quotient to ASCII 
    ACALL work          ; Display the ASCII character 
    MOV A, B               ; Move the remainder back to A 
    ADD A, #30h         ; Convert remainder to ASCII 
    CALL work            ; Display the ASCII character 
    RET 
 
message:                        ;Displaying of "NO PERSON" 
   MOV R2,#30h 
   MOV R3,#39h 
   ACALL lcd_displayer 
   ACALL Check 
   RET 
 
lcd_displayer:          ;sending bit by bit to LCD display 
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
 
Here: SJMP Here 
END 