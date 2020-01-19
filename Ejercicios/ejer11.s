.include "inter.inc"
.include "all.txt"
ldr r0, = GPBASE
mov r1, # 0b00001000000000000000000000000000
str r1, [r0, # GPFSEL0 ]
/* guia bits xx999888777666555444333222111000 */
ldr r1, = 0b00000000001000000000000000001001
str r1, [r0, # GPFSEL1 ]
ldr r1, = 0b00000000001000000000000001000000
str r1, [r0, # GPFSEL2 ]
/* Programo contador C1 para dentro de 2 microsegundos */
ldr r0, = STBASE
ldr r1, [r0, # STCLO ]
add r1, #2
str r1, [r0, # STC1 ]
ldr r0, = INTBASE
mov r1, # 0b0010
str r1, [r0, # INTENIRQ1 ]
mov r0, # 0b01010011 @ Modo SVC, IRQ activo
msr cpsr_c, r0
/* Repetir para siempre */
bucle : b bucle
/* Rutina de tratamiento de interrupci ón */
fiq_handler:
irq_handler :
push { r0, r1, r2, r3 }
/* Leo origen de la interrupci ón */
ldr r0, = STBASE
ldr r1, = GPBASE
ldr r2, [ r0, # STCS ]
ands r2, # 0b0010
/* Si es C1, ejecuto secuencia de LEDs */
ldr r2, = cuenta
/* guia bits 10987654321098765432109876543210 */
ldr r3, = 0b00001000010000100000111000000000
str r3, [ r1, # GPCLR0 ] @ Apago todos los LEDs
ldr r3, [ r2 ] @ Leo variable cuenta
subs r3, # 1 @ Decremento
moveq r3, # 6 @ Si es 0, volver a 6
str r3, [ r2 ] @ Escribo cuenta
ldr r3, [ r2, + r3, LSL #2 ] @ Leo secuencia
str r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
/* Reseteo estado interrupci ón de C1 */
mov r3, # 0b0010
str r3, [ r0, # STCS ]
/* Programo siguiente interrupci ón en 200ms */
ldr r3, [ r0, # STCLO ]
ldr r2, = 300000 @ 5 Hz
add r3, r2
str r3, [ r0, # STC1 ]
pop { r0, r1, r2, r3 }
subs pc, lr, #4

cuenta : .word 1 @ Entre 1 y 6, LED a encender
/* guia bits 7654321098765432109876543210 */
secuen : .word 0b1000000000000000000000000000
.word 0b0000010000000000000000000000
.word 0b0000000000100000000000000000
.word 0b0000000000000000100000000000
.word 0b0000000000000000010000000000
.word 0b0000000000000000001000000000


ledst : .word 0
	