.include "inter.inc"
.include "notas.inc"
.include "vader.inc"
.include "all.txt"
.text
/* Configuro GPIOs 4, 9, 10, 11, 17, 22 y 27 como salida */
ldr r0, = GPBASE
ldr r1, = 0b00001000000000000001000000000000
str r1, [ r0, # GPFSEL0 ]
/* guia bits xx999888777666555444333222111000 */
ldr r1, = 0b00000000001000000000000000001001
str r1, [ r0, # GPFSEL1 ]
ldr r1, = 0b00000000001000000000000001000000
str r1, [ r0, # GPFSEL2 ]
/* Programo C1 y C3 para dentro de 2 microsegundos */
ldr r0, = STBASE
ldr r1, [ r0, # STCLO ]
ldr r2, =2
add r1, r2
str r1, [ r0, # STC1 ]
str r1, [ r0, # STC3 ]
/* Habilito C1 para IRQ */
ldr r0, = INTBASE
mov r1, # 0b0010
str r1, [ r0, # INTENIRQ1 ]
/* Habilito C3 para FIQ */
mov r1, # 0b10000011
str r1, [ r0, # INTFIQCON ]
/* Habilito interrupciones globalmente */
mov r0, # 0b00010011 @ Modo SVC, FIQ & IRQ activo
msr cpsr_c, r0
/* Repetir para siempre */
bucle : b bucle

/* Rutina de tratamiento de interrupci ón IRQ */
irq_handler :
push { r0, r1, r2 ,r3,r4}
ldr r0, = STBASE
ldr r1, = GPBASE
ldr r2, = cuenta
ldr r4, = NUMNOTAS
/* guia bits 10987654321098765432109876543210 */
ldr r3, = 0b00001000010000100000111000000000
str r3, [ r1, # GPCLR0 ] @ Apago todos los LEDs
ldr r3, [r4]
adds r3, # 1
cmp r3, #70
moveq r3, #0
str r3,[r4]
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
ldr r2, = 500000 @ 5 Hz
add r3, r2
str r3, [ r0, # STC1 ]
pop { r0, r1, r2, r3,r4 }
subs pc, lr, #4

cuenta : .word 1 @ Entre 1 y 6, LED a encender
secuen :
 .word 0b1000000000000000000000000000
.word 0b0000010000000000000000000000
.word 0b0000000000100000000000000000
.word 0b0000000000000000100000000000
.word 0b0000000000000000010000000000
.word 0b0000000000000000001000000000

notas: .word NUMNOTAS
bitson : .word 0 @ Bit 0 = Estado del altavoz

fiq_handler:
ldr      r8, =GPBASE
ldr      r9, =bitson
ldr	 r11,=NUMNOTAS
ldr	 r12,=notaFS
/* Hago  sonar  altavoz  invirtiendo  estado  de  bitson  */
ldr      r10, [r9]
eors     r10, #1
str      r10, [r9]
/* Leo  cuenta y luego  elemento  correspondiente  en  secuen  */
ldr      r10, [r11]
ldr      r9, [r12, +r10,  LSL #2]
/* Pongo  estado  altavoz  según variable  bitson  */
mov      r10, #0b10000      @ GPIO 4 (altavoz)
streq    r10, [r8, #GPSET0]
strne    r10, [r8, #GPCLR0]
/*  Reseteo  estado  interrupción de C3 */
ldr      r8, =STBASE
mov      r10, #0b1000
str      r10, [r8, #STCS]
/*  Programo  retardo  según valor leído en  array */
ldr      r10, [r8, #STCLO]
add      r10, r9
str      r10, [r8, #STC3]
/* Salgo de la RTI */
subs     pc, lr, #4
