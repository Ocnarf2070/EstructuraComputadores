.include "inter.inc"
.include "all.txt"
.text
/* Configuro GPIO 9 como salida */
ldr r0, = GPBASE
/* guia bits xx999888777666555444333222111000 */
mov r1, # 0b00001000000000000000000000000000
str r1, [ r0, # GPFSEL0 ]
/* Programo contador C1 para futura interrupci ón */
ldr r0, = STBASE
ldr r1, [ r0, # STCLO ]
ldr r2, = 4000000 @ 4,19 segundos
adds r1,r2
str r1, [ r0, # STC1 ]
/* Habilito interrupciones, local y globalmente */
ldr r0, = INTBASE
mov r1, # 0b0010
str r1, [ r0, # INTENIRQ1 ]
mov r0, # 0b01010011 @ Modo SVC, IRQ activo
msr cpsr_c, r0
/* Repetir para siempre */
bucle : b bucle
/* Rutina de tratamiento de interrupci ón */

fiq_handler:
irq_handler :
push { r0, r1 } @ Salvo registros
ldr r0, = GPBASE
/* guia bits 10987654321098765432109876543210 */
mov r1, # 0b00000000000000000000001000000000
str r1, [ r0, # GPSET0 ] @ Enciendo LED
pop { r0, r1 } @ Recupero registros
subs pc, lr, #4 @ Salgo de la RTI
