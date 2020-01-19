.include "inter.inc"
.include "all.txt"
ldr r0, = GPBASE
mov r1, # 0b00001000000000000000000000000000
str r1, [r0, # GPFSEL0 ]
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
push {r0, r1, r2}
/* Conmuto variable de estado del LED */
ldr r0, = ledst @ Leo puntero a v. ledst
ldr r1, [r0] @ Leo variable
eors r1, #1 @ Invierto bit 0, act. flag Z
str r1, [r0] @ Escribo variable
/* Enciendo o apago todos los LEDs en funci ón del flag Z */
ldr r0, = GPBASE
/* guia bits 10987654321098765432109876543210 */
ldr r1, = 0b00000000000000000000001000000000
streq r1, [r0, # GPSET0 ]
strne r1, [r0, # GPCLR0 ]
ldr r0, = STBASE
mov r1, # 0b0010
str r1, [r0, # STCS ]
/* Programo siguiente interrupci ón medio segundo despu és */
ldr r1, [r0, # STCLO ]
ldr r2, = 500000 @1 Hz
add r1, r2
str r1, [r0, # STC1 ]
/* Recupero registros y salgo */
pop {r0, r1, r2}
subs pc, lr, #4

ledst : .word 0
