;
; IntSwitch.asm
;
; Created: 12/31/2015 10:51:44 AM
; Author : Gayfi_000
;
.equ	led  = 0		; First blue led
.equ	led1 = 1		; Second blue led
.equ	ledp = 0b11		; Port byte for ddrb
.org	0x0000			; Main is located in address 0000
	jmp main			; Jump to main
.org	0x0002			; Int0 interupt should be at 0002
	jmp int0_serv		; Jump to int0_serv

; Main Code
main: sei				; allow interrupts
    sbi EIMSK, INT0		; allow int0
	rcall init_AD		; Initialize A/D converter
AD:
	lds r16, adch		; Read A/D result into r16
	cpi r16, 24			; Compare r16 to 26
	brlo AD				; Branch if lower to AD
	
	ldi r16, ledp		; Load r16 with bit for led
	out ddrb, r16		; Make led output and other pins input
	nop					; Wait for ddrb to change
	cbi portb, led		; Turn off led
	cbi portb, led1		; Turn off led
	rcall delay_1ms		; Delay 1ms so that led appears off
	sbi portb, led		; Turn on led
	sbi portb, led		; Turn on led
    rjmp AD				; relative jump to AD, loop until interupt


; Interupt service routine
; Turns the led on for a little while and then back off.
int0_serv:

	ldi r16, ledp		; Load r16 with bit for led
	out ddrb, r16		; Make led output and other pins input
on:
	sbi portb, led      ; Set bit of led
	sbi portb, led1		; Set bit of led

	push r17			; Push r17 to the stack
	ldi r17, 255		; Load r17 with 100
delay2:
	push r16			; Push r16 onto stack
	ldi r16, 255		; Load r16 with 100
delay1:
	nop					; No operation
	nop					; Waste time
	nop					; We got time to burn
	nop					; BURN TIME
	nop
	nop
	nop
	nop					; BURN MORE TIME
	nop					
	dec r16				; Decrement r16
	brne delay1			; Branch to delay1 if not equal to 0
	pop r16				; Pop r16 from stack
	dec r17				; Decrement r17
	brne delay2			; Branch to delay2 if not equal to 0
	pop r17				; Pop r17 from stack

off:
	cbi portb, led		; Clear bit of led
	cbi portb, led1		; Clear bit of led2
	reti				; Return

; Subroutines

; Initialize A/D
init_AD:
	push r16			; Push register 16 to stack
	
	ldi r16, 0x3f		; Digital input disable.
	sts	didr0, r16		
	ldi r16, 0x20		; 8bits, select channel 0
	sts admux, r16		; 
	ldi r16, 0xe0		; Continually update adch
	sts	adcsra, r16
	rcall delay_1ms		; Delay 1ms
	pop r16				; Pop register 16 from stack
	ret 				; Return

; Delay 1 ms
delay_1ms:
	push r16			; Save value in r16
	ldi r16, 99			;Accounts for overhead of 12 cycles.
delay_1ms1:				; 10 us/loop
	nop					; 1 cycle
	nop
	nop
	nop
	nop
	nop
	nop
	dec r16				; Decrement r16
	brne delay_1ms1	    ; 2 cycle
	pop r16				; Restore the value in r16
	ret					; Return