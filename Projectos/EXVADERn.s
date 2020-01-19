.include  "inter.inc"
.include "notas.inc"
.include "all.txt"
.include "song1.txt"
.text

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

/* guia bits    10987654321098765432109876543210*/
mov     r1,  #0b00000000000100000000000000000000
str     r1, [r0, #INTENIRQ2]

@Habilito interrupciones globalmente

mov r0, #0b00010011 @ Modo SVC,FIQ & IRQ activo
msr cpsr_c, r0

bucle : b bucle


@ Rti irq
irq_handler :
		push  {r0,r1,r2,r3,r4,r5,r6,r9}
		ldr r0, =STBASE
		ldr r1, =GPBASE
		ldr r2, =Inicializar


	@Consulto si se ha pulsado el pulsador 1 o el pulsador 2
		
		
		ldr r4,[r1, #GPEDS0]
		ands r4, #0b00000000000000000000000000000100
		bne pulsador1
		

		ldr r4,[r1, #GPEDS0]
		ands r4, #0b00000000000000000000000000001000
		bne pulsador2
		
		

		ldr r3,[r2]  @lee estado
		cmp r3,#1
		beq TodosLosLed @ si ha pulsado pin 2 salta a leds
		cmp r3,#2
		beq Secuencia @ si ha pulsado  pin 3 salta a leds2

pulsador1:

		mov  r2, #0b00000000000000000000000000000100
		str   r2, [r1, #GPEDS0]
		ldr r5,= Inicializar
		ldr r6,[r5]
		mov r6,#1 @coloca un 1 en el bit de estado
		str r6, [r5]
		b TodosLosLed
pulsador2:
		mov  r2, #0b00000000000000000000000000001000
		str   r2, [r1, #GPEDS0]
		ldr r5,= Inicializar
		ldr r6,[r5]
		mov r6,#2 @coloca un 2 en el bit de estado
		str r6, [r5]
		b Secuencia

TodosLosLed:		//Leds en secuencia

		ldr r3, = 0b00001000010000100000111000000000
		str r3, [r1, #GPCLR0] 	@ Apago todos los LEDs

		ldr r4,=Contador
		ldr r3,[r4]				@ Leo variable contador
		adds r3,#1
		cmp r3, #7
		moveq r3, #1
		str r3,[r4]				@ Escribo cuenta
		ldr r3,[r4, r3, LSL #2]	@ Leo secuencia
		str r3,[r1, #GPSET0]		@ Escribo secuencia en LEDs

		b Notas

Secuencia:   @Todos los leds
		ldr r5,= Pausa 		@ Leo el estado de la secuencia leds 2, 1/0
		ldr r6,[r5]
		eors r6,#1 		@ Invierto bit 0, act. flag Z

		ldr r3, =0b00001000010000100000111000000000
		streq r3,[r1, #GPSET0]
		strne r3,[r1, #GPCLR0]

		str r6,[r5] 			@ Escribo variable
		b  Notas
Notas:
		ldr r5, =time  	@ carga array duracion
		ldr r2, =puntero		@ Puntero array duracionFS y notasFS
		ldr r3,[r2]
		add r3, #1  		@ aumentamos el puntuero auxiliar
		cmp r3, #NUMNOTAS
		moveq r3, #0  		@ Si llega al fin del array lo pone a 0
		str r3, [r2]
		ldr r6, [r5,r3, LSL #2]
		b cont
		

@Reseteo estado interrupcion de C1
cont:
		ldr r0, =STBASE
		mov r1, #0b0010
		str r1, [r0, #STCS]

@Programo sig interrupcion

		ldr r1, [r0, #STCLO]
		add r1, r6
		str r1, [r0, #STC1]

fin:
		pop  {r0,r1,r2,r3,r4,r5,r6}
		subs pc, lr, #4

fiq_handler:
	push {r5,r6, r7, r8 , r9 ,r10, r11}
		ldr r8, =GPBASE
		ldr r9, =bitson
		ldr r7, =puntero
		ldr r6, [r7]
		ldr r11, =song1


@ Pongo estado altavoz segun bitson

		ldr r5, [r11, r6, LSL #2]
		ldr r6,=SILEN
		cmp r5, r6
		streq r10, [r8, #GPCLR0]
		beq continuar

		ldr r10, [r9]
		eors r10, #1 	@ or exclusivo
		str r10,[r9]

		mov r10, #0b10000 @ GPIO 4 (altavoz)
		streq r10, [r8, #GPSET0]
		strne r10, [r8, #GPCLR0]

continuar:

@Reseteo estado interrupcion de C3

		ldr r8, =STBASE
		mov r10, #0b1000
		str r10, [r8, #STCS]

@Programo siguiente interrupcion

		ldr r10, [r8, #STCLO]
		add r10,r5
		str r10, [r8, #STC3]

		pop {r5,r6, r7, r8 , r9 ,r10, r11}
		subs pc, lr, #4

bitson :  .word 0
puntero:  .word 0
Contador: .word 0
secuen: 	.word 0b0000000000000000001000000000
		.word 0b0000000000000000010000000000
		.word 0b0000000000000000100000000000
		.word 0b0000000000100000000000000000
		.word 0b0000010000000000000000000000
		.word 0b1000000000000000000000000000
Inicializar: .word 0
Pausa: .word 0


.include "vader.inc"
