.include "inter.inc"
.include "all.txt"
.include "notas.inc"
.include "song1.txt"
@ Configuro GPIOs 4, 9, 10, 11, 17, 22 y 27 como salida

	ldr r0, = GPBASE

	/* guia bits xx999888777666555444333222111000 */
	ldr r1, = 0b00001000000000000001000000000000
	str r1, [r0, # GPFSEL0 ]
	ldr r1, = 0b00000000001000000000000000001001
	str r1, [r0, # GPFSEL1 ]
	ldr r1, = 0b00000000001000000000000001000000
	str r1, [r0, # GPFSEL2 ]

@ Activar los pulsadores GPIO 2 y 3 para interrupciones

	mov r1,#0b00000000000000000000000000001100
	str r1,[r0,#GPFEN0]


@ Programo C1 y C3 para dentro de 2 microsegundos
reset1:
ldr r0, = STBASE
ldr r1, [ r0, # STCLO ]
add r1, # 2
str r1, [ r0, # STC1 ]
str r1, [ r0, # STC3 ]

@Habilito C1 para IRQ

ldr r0, =INTBASE
mov r1, #0b0010
str r1, [r0, #INTENIRQ1]

@Habilito C3 para FIQ

mov r1, #0b10000011
str r1, [r0, #INTFIQCON]

@Habilito pulsador para IRQ


@Habilito interrupciones globalmente

mov r0, #0b00010011 @ Modo SVC,FIQ & IRQ activo
msr cpsr_c, r0

bucle : b bucle


reset: 
mov  r4, #0b00000000000000000000000000001000
str   r4, [r1, #GPEDS0]
ldr r2, = cuenta
ldr r4,[r2]
mov r4, #0
str r4,[r2]
ldr r3, = veces
ldr r4,[r3]
mov r4,#0
str r4,[r3]
ldr r2,=velocidad
ldr r4, [r2]
mov r4,#0
str r4, [r2]
ldr r2,=vel
ldr r4, [r2]
mov r4,#0
str r4, [r2]
ldr r2,=puntero
ldr r4,[r2]
mov r4,#0
str r4,[r2]
ldr r2,=song
ldr r4,[r2]
mov r4,#0
str r4,[r2]
b reset1



/* Rutina de tratamiento de interrupci ón */
irq_handler :
push { r0, r1, r2, r3,r4,r5,r6 }
/* Leo origen de la interrupci ón */

ldr r0, = STBASE
ldr r1, = GPBASE
ldr r2, [ r0, # STCS ]
ands r2, # 0b0010
ldr r3,=puntero
ldr r6,=song1
ldr r4,[r3]
ldr r5,[r6,r4,LSL #2]
cmp r3,#10
blt cont
/* Si es C1, ejecuto secuencia de LEDs */
ldr r2, = cuenta
/* guia bits 10987654321098765432109876543210 */
ldr r3, = 0b00001000010000100000111000000000
str r3, [ r1, # GPCLR0 ] @ Apago todos los LEDs
ldr r3, [ r2 ] @ Leo variable cuenta
add r3, # 1 @ Decremento
str r3, [ r2 ] @ Escribo cuenta
ldr r3, [ r2, + r3, LSL #2 ] @ Leo secuencia
str r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
ldr r5, =1000000
ldr r2, =velocidad
ldr r3,[r2]
sub r5,r3
ldr r4,[r1, #GPEDS0]
ands r4, #0b00000000000000000000000000000100
bne pulsado
ldr r4,[r1, #GPEDS0]
ands r4, #0b00000000000000000000000000001000
bne reset
ldr r2, = cuenta
ldr r3, [ r2 ] @ Leo variable cuenta
cmp r3,#7
beq mal
cont:
ldr r0, = STBASE
/* Reseteo estado interrupci ón de C1 */
mov r3, # 0b0010
str r3, [ r0, # STCS ]
/* Programo siguiente interrupci ón en 200ms */
ldr r3, [ r0, # STCLO ]
add r3, r5
str r3, [ r0, # STC1 ]
pop { r0, r1, r2, r3 ,r4,r5,r6}
subs pc, lr, #4

pulsado:
mov  r4, #0b00000000000000000000000000000100
str   r4, [r1, #GPEDS0]
ldr r4,=50000
add r3,r4
str r3,[r2]
ldr r3,=vel
ldr r4,[r3]
ldr r5,=7000
add r4,r5
str r4,[r3]
ldr r2, = cuenta
ldr  r3,[r2]
cmp r3,#7
beq bien
b mal

mal:
ldr r2, = modo
mov r3,#1
str r3,[r2]
ldr r3, = 0b00001000010000100000111000000000
str r3, [ r1, # GPCLR0 ] @ Apago todos los LEDs
ldr r2,=song
ldr r3,[r2]
mov r3,#2
str r3,[r2]
ldr r2,=puntero
ldr r3,[r2]
mov r3,#0
str r3,[r2]
bl binario
/* bl espera
bl hiscore */
res:
ldr r4,[r1, #GPEDS0]
ands r4, #0b00000000000000000000000000001000
bne reset
b res

/* hiscore:
ldr r3, = 0b00001000010000100000111000000000
str r3, [ r1, # GPCLR0 ] @ Apago todos los LEDs
ldr r2, =cuenta
ldr r3, =HISCORE
ldr r4,[r2]
ldr r5,[r3]
cmp r4,r5
strgt r4,[r3]
ldrgt r3, = 0b00001000010000000000000000000000
strgt r3, [ r1, # GPSET0 ] 
ldreq r3, = 0b00000000000000100000100000000000
streq r3, [ r1, # GPSET0 ] 
ldrlt r3, = 0b000000000000000000000011000000000
strlt r3, [ r1, # GPSET0 ] 
bx lr */

/* espera : 
push {r0,r1}
ldr r0, = STBASE
ldr r1, = GPBASE
ldr r2, [ r0, # STCLO ] @ Lee contador en r3
ldr r3, = 2000000
add r2, r3 @ r4= r3+ medio mill ón
ret1 : 
ldr r4,[r1, #GPEDS0]
ands r4, #0b00000000000000000000000000001000
bne reset
ldr r3, [ r0, # STCLO ]
cmp r2, r3 @ Leemos CLO hasta alcanzar
bne ret1 @ el valor de r4
pop {r0,r1}
bx lr */

bien:
mov r3, #0
str r3,[r2]
ldr r2, =veces
ldr r3,[r2]
add r3,#1
str r3,[r2]
b cont

binario:
ldr r2,=veces 
ldr r4,[r2]
ldr r2, = cuenta
mov r5, #1
cmp r4,#32
subgt r4,#32
ldrgt r3, [ r2, r5, LSL #2 ] @ Leo secuencia
strgt r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
subeq r4,#32
ldreq r3, [ r2, r5, LSL #2 ] @ Leo secuencia
streq r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
cmp r4,#16
subgt r4,#16
add r5, #1
ldrgt r3, [ r2, r5, LSL #2 ] @ Leo secuencia
strgt r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
subeq r4,#16
ldreq r3, [ r2, r5, LSL #2 ] @ Leo secuencia
streq r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
cmp r4,#8
subgt r4,#8
add r5, #1
ldrgt r3, [ r2, r5, LSL #2 ] @ Leo secuencia
strgt r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
subeq r4,#8
ldreq r3, [ r2, r5, LSL #2 ] @ Leo secuencia
streq r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
cmp r4,#4
subgt r4,#4
add r5, #1
ldrgt r3, [ r2, r5, LSL #2 ] @ Leo secuencia
strgt r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
subeq r4,#4
ldreq r3, [ r2, r5, LSL #2 ] @ Leo secuencia
streq r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
cmp r4,#2
subgt r4,#2
add r5, #1
ldrgt r3, [ r2, r5, LSL #2 ] @ Leo secuencia
strgt r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
subeq r4,#2
ldreq r3, [ r2, r5, LSL #2 ] @ Leo secuencia
streq r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
cmp r4,#1
subgt r4,#1
add r5, #1
ldrgt r3, [ r2, r5, LSL #2 ] @ Leo secuencia
strgt r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
subeq r4,#1
ldreq r3, [ r2, r5, LSL #2 ] @ Leo secuencia
streq r3, [ r1, # GPSET0 ] @ Escribo secuencia en LEDs
bx lr

modo: .word 0
velocidad: .word 0
veces: .word 0
@ HISCORE: .word 0
cuenta : .word 0 @ Entre 1 y 6, LED a encender
/* guia bits 7654321098765432109876543210 */
secuen :
.word 0b0000000000000000001000000000
.word 0b0000000000000000010000000000
.word 0b0000000000000000100000000000
.word 0b0000000000100000000000000000
.word 0b0000010000000000000000000000
.word 0b1000000000000000000000000000

fiq_handler:
push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11}
ldr r8, =song
ldr r9,[r8]
ldr r5, =time  	@ carga array duracion
@ cmp r9,#1
@ beq song2
cmp r9,#2
beq s3
ldr r0,=song1
ldr r2, =puntero		@ Puntero array duracionFS y notasFS
ldr r3,[r2]
ldr r6, [r5,+r3, LSL #2]
ldr r1,=vel
ldr r4,[r1]
sub r6,r4
ldr 	r7, =STBASE
ldr r8, =next
ldr r10, [r7, #STCLO]
add r11,r10, r6
ldr r9, =modo2
ldr r6,[r9]
cmp r6, #0
beq prim
ldr r9, [r8]
cmp r10,r9
blt norm
add r3, #1  		@ aumentamos el puntuero auxiliar
cmp r3, #NUMNOTAS
moveq r3, #9   		@ Si llega al fin del array lo pone a 9 (verse)
str r3, [r2]
ldr r9, =modo2
ldr r6,[r9]
mov r6, #0
str r6,[r9]
b norm

s3:
ldr r0,=song3
ldr r5, =time3
ldr r2, =puntero		@ Puntero array duracionFS y notasFS
ldr r3,[r2]
ldr r6, [r5,+r3, LSL #2]
ldr 	r7, =STBASE
ldr r8, =next
ldr r10, [r7, #STCLO]
add r11,r10, r6
ldr r9, =modo2
ldr r6,[r9]
cmp r6, #0
beq prim
ldr r9, [r8]
cmp r10,r9
blt norm
add r3, #1  		@ aumentamos el puntuero auxiliar
cmp r3, #NUMNOTAS3
moveq r3, #0   		@ Si llega al fin del array lo pone a 9 (verse)
str r3, [r2]
ldr r9, =modo2
ldr r6,[r9]
mov r6, #0
str r6,[r9]
b norm

prim:
str r11,[r8]
add r6, #1
str r6, [r9]

norm:
ldr r8, =GPBASE
ldr r9, =bitson
ldr r7, =puntero
ldr r6, [r7]
ldr r5, [r0, r6, LSL #2]
ldr r6,=SILEN
cmp r5, r6
beq continuar

ldr r10, [r9]
eors r10, #1 	@ or exclusivo
str r10,[r9]

mov r10, #0b10000 @ GPIO 4 (altavoz)
streq r10, [r8, #GPSET0]
strne r10, [r8, #GPCLR0]

/*  Reseteo  estado  interrupción de C3 */
continuar:

@Reseteo estado interrupcion de C3

		ldr r8, =STBASE
		mov r10, #0b1000
		str r10, [r8, #STCS]

@Programo siguiente interrupcion

		ldr r10, [r8, #STCLO]
		add r10,r5
		str r10, [r8, #STC3]
/* Salgo de la RTI */
pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11}
subs     pc, lr, #4

vel: .word 0
puntero: .word 0
modo2: .word 0
next: .word 0
song: .word 0
bitson: .word 0

random: 
ldr r5, =3
ldr r4,[r0,#STCLO]
mul r3, r4
ldr r4,[r0,#STCLO]
add r3, r4
udiv r4,r3,r5
mls r3,r5,r4,r3
movs r3,r3
rsbmi r3,r3,#0
moveq r3, # 6