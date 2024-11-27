;hello
;using assembly language for turning LED on


.include "/sdcard/a/digital-design/assembly/setup/m328Pdef/m328Pdef.inc"


; Pin mappings:
; P = Pin 2 (PORTD bit 2)
; Q = Pin 3 (PORTD bit 3)
; R = Pin 4 (PORTD bit 4)
; S = Pin 5 (PORTD bit 5)
; LED1 = Pin 6 (PORTD bit 6)
; LED2 = Pin 7 (PORTD bit 7)
; LED3 = Pin 8 (PORTB bit 0)
; LED4 = Pin 9 (PORTB bit 1)

.def temp = r16    ; Temporary register
.def result = r17  ; Result register

; Initial setup
ldi temp, 0xFF      ; Set all pins as output
out DDRD, temp      ; Set PORTD pins (2, 3, 4, 5, 6, 7) as output
out DDRB, temp      ; Set PORTB pins (0, 1) as output

ldi temp, 0x00      ; Set all pins to low initially (LED off)
out PORTD, temp     ; Set PORTD (LEDs) to low
out PORTB, temp     ; Set PORTB (LEDs) to low

; Main loop
loop:
    ; Read inputs
    in temp, PIND         ; Read PORTD (Pins 2 to 5) into temp
    andi temp, 0x3C       ; Mask out all other bits (leaving bits 2-5 for P, Q, R, S)
    swap temp             ; Swap nibbles to get P in the lower nibble
    andi temp, 0x0F       ; Mask to get P, Q, R, S

    ; Extract individual bits for P, Q, R, S
    lsr temp              ; P (bit 0)
    mov r18, temp         ; Save P
    lsr temp              ; Q (bit 1)
    mov r19, temp         ; Save Q
    lsr temp              ; R (bit 2)
    mov r20, temp         ; Save R
    lsr temp              ; S (bit 3)
    mov r21, temp         ; Save S

    ; Compute terms:
    ; P overline RS
    mov temp, r20         ; Load R into temp
    and temp, r21         ; AND with S (R && S)
    com temp              ; Invert (overline of RS)
    and temp, r18         ; AND with P (P overline RS)
    mov r22, temp         ; Save the result of P overline RS

    ; PQR
    mov temp, r18         ; Load P into temp
    and temp, r19         ; AND with Q
    and temp, r20         ; AND with R
    mov r23, temp         ; Save the result of PQR

    ; overline P RS
    com r18               ; Invert P
    mov temp, r20         ; Load R into temp
    and temp, r21         ; AND with S (R && S)
    and temp, r18         ; AND with !P (overline P RS)
    mov r24, temp         ; Save the result of overline P RS

    ; overline P Q overline R
    com r18               ; Invert P
    com r20               ; Invert R
    and temp, r19         ; AND with Q
    and temp, r20         ; AND with !R
    and temp, r18         ; AND with !P (overline P Q overline R)
    mov r25, temp         ; Save the result of overline P Q overline R

    ; Combine all terms
    or r22, r23           ; Combine P overline RS and PQR
    or r22, r24           ; Combine with overline P RS
    or r22, r25           ; Combine with overline P Q overline R
    mov result, r22       ; Save final result

    ; Set LEDs based on the result
    ; LED1: P overline RS
    tst r22               ; Test the result
    breq no_led1          ; If 0, do not turn on LED1
    sbi PORTD, 6          ; Set LED1 (PORTD pin 6)
no_led1:

    ; LED2: PQR
    tst r23               ; Test the result for PQR
    breq no_led2          ; If 0, do not turn on LED2
    sbi PORTD, 7          ; Set LED2 (PORTD pin 7)
no_led2:

    ; LED3: overline P RS
    tst r24               ; Test the result for overline P RS
    breq no_led3          ; If 0, do not turn on LED3
    sbi PORTB, 0          ; Set LED3 (PORTB pin 0)
no_led3:

    ; LED4: overline P Q overline R
    tst r25               ; Test the result for overline P Q overline R
    breq no_led4          ; If 0, do not turn on LED4
    sbi PORTB, 1          ; Set LED4 (PORTB pin 1)
no_led4:

    rjmp loop             ; Repeat the loop

