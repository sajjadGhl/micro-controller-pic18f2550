; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
#include <p18f2550.inc>
LIST P=18F2550
CONFIG WDT=OFF ; WATCHDOG TIMER OFF
CONFIG FOSC = XT_XT ; CONFIGURE CLOCK SOURCE TO EXTERNAL CRYSTAL
CONFIG LVP = OFF ; LOW VOLTAGE PROGRAMMING DISABLED
CONFIG BOR = OFF ; Brown Out Reset OFF
CONFIG VREGEN = OFF ; USB voltage regulator OFF
CONFIG PBADEN = OFF ; PORTB<4:0> pins are configured as digital I/O on Reset.
CONFIG MCLRE = ON ; MCLR pin enabled; RE3 input pin disabled.

    
RES_VECT  CODE    0x0000            ; processor reset vector
    ORG 0X00
    COUNT	EQU	    0x14
    SET_COUNT   EQU	    0X15
    RESET_COUNT EQU	    0X16
    CALL SET_PWM_10
    GOTO    MAIN                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program

MAIN
    ; B=OUTPUT
    CLRF TRISB
    
    ; C6, C7=INPUT
    BSF TRISC, 6
    BSF TRISC, 7
    
    ;C0, C1 OUTPUT
    BCF TRISC, 0
    BSF TRISC, 1
    
    ;;;;;;;;;;;;;;;;;;;;;; SELECT MODE (C6, C7) ;;;;;;;;;;;;;;;;;;;;;;
    BTFSS PORTC, 6
    GOTO MAIN_PWD
    
    BTFSS PORTC, 7
    GOTO MAIN_ABSHAR
    
    GOTO MAIN_ONE_OF_N

    GOTO MAIN
    
MAIN_ABSHAR
    CALL ABSHAR
    GOTO MAIN
    
MAIN_ONE_OF_N
    CALL ONE_OF_N
    GOTO MAIN
    
MAIN_PWD
    ; IF BUTTON PRESSED, ADD 10%
    BTFSS PORTC, 1
    CALL ADD_TO_PWM
    
    CALL PWD
    GOTO MAIN
   
    
SET_PWM_10
    MOVLW D'1'
    MOVWF SET_COUNT
    MOVLW D'9'
    MOVWF RESET_COUNT
    RETURN
    
ADD_TO_PWM
    INCF SET_COUNT
    DCFSNZ RESET_COUNT
    CALL SET_PWM_10
    RETURN
    
PWD 
    BSF PORTC, 0
    MOVF SET_COUNT, W
    MULLW D'10'
    CALL LOOP_DELAY

    BCF PORTC, 0
    MOVF RESET_COUNT, W
    MULLW D'10'
    CALL LOOP_DELAY

    RETURN    
    
    
ABSHAR
    MOVLW 0X00
    CALL SEND
    MOVLW D'5' ; 500ms
    CALL LOOP_DELAY
    
    MOVLW B'00000001'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00000011'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00000111'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00001111'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00011111'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00111111'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'01111111'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'11111111'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
  
    MOVLW B'01111111'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00111111'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00011111'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00001111'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00000111'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00000011'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00000001'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY	
    
    MOVLW 0X00
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    RETURN
    
    
ONE_OF_N
    CLRF PORTB
    MOVLW D'5' ; FOR 500 ms DELAY
    CALL LOOP_DELAY

    MOVLW B'00000001'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00000010'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00000100'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00001000'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00010000'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'00100000'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'01000000'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    MOVLW B'10000000'
    CALL SEND
    MOVLW D'5'
    CALL LOOP_DELAY
    
    RETURN
    
SEND
    MOVWF PORTB
    RETURN

    
LOOP_DELAY
    ; COUNT <= W
    MOVWF COUNT,A
    AGAIN
	CALL DELAY ;LOOP BODY
    DECF COUNT,F,A
    BNZ AGAIN
    RETURN
    
    
DELAY ; 0.1S
    MOVLW D'25'            ; Load delay value (25 x 4ms = 0.1 sec)
    MOVWF 0x20              ; Store delay value in memory
    delay_loop
	MOVLW D'250'        ; Load inner loop delay value (250 x 4us = 1ms)
	MOVWF 0X21
	delay_inner
	    NOP             ; Delay for one instruction cycle (4us @ 4 MHz)
	    DECFSZ 0x21, F   ; Decrement delay value
	    GOTO delay_inner ; Loop until delay value is zero
	DECFSZ 0x20, F       ; Decrement outer loop delay value
	GOTO delay_loop      ; Loop until outer loop delay value is zero
    RETURN
    
    
END