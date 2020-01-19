.include "inter.inc"
.include "inicio.txt"
.include "pila.txt"
.text
ldr r0, = GPBASE
ldr r1, = 0b00001000000000000000000000000000
str r1, [r0, # GPFSEL0 ]
ldr r1, = 0b00000000001000000000000000001001
str r1, [r0, # GPFSEL1 ]
ldr r1, = 0b00000000001000000000000001000000
str r1, [r0, # GPFSEL2 ]
/* guia bits  10987654321098765432109876543210 */

ldr r2, = STBASE

bucle:
bl espera
str r1, [ r0, # GPCLR0 ]
ldr r1, =   0b00000000000000000000001000000000
str r1, [ r0, # GPSET0 ]
bl espera @ Salta a rutina de espera
str r1, [ r0, # GPCLR0 ]
ldr r1, =   0b00000000000000000000010000000000
str r1, [ r0, # GPSET0 ]
bl espera @ Salta a rutina de espera
str r1, [ r0, # GPCLR0 ]
ldr r1, =   0b00000000000000000000100000000000
str r1, [ r0, # GPSET0 ]
bl espera @ Salta a rutina de espera
str r1, [ r0, # GPCLR0 ]
ldr r1, =   0b00000000000000100000000000000000
str r1, [ r0, # GPSET0 ]
bl espera @ Salta a rutina de espera
str r1, [ r0, # GPCLR0 ]
ldr r1, =   0b00000000010000000000000000000000
str r1, [ r0, # GPSET0 ]
bl espera @ Salta a rutina de espera
str r1, [ r0, # GPCLR0 ]
ldr r1, =   0b00001000000000000000000000000000
str r1, [ r0, # GPSET0 ]
b bucle

espera : 
push {r0,r1}
ldr r3, [ r2, # STCLO ] @ Lee contador en r3
ldr r4, = 500000
add r4, r3 @ r4= r3+ medio mill ón
ret1 : 
ldr r3, [ r2, # STCLO ]
cmp r3, r4 @ Leemos CLO hasta alcanzar
bne ret1 @ el valor de r4
pop {r0,r1}
bx lr

