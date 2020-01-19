.include "inter.inc"
.text
mrs r0,cpsr
mov     r0, #0b11010011   @ Modo SVC, FIQ&IRQ desact
msr spsr_cxsf,r0
add r0,pc,#4
msr ELR_hyp,r0
eret
mov     r0, #0b11010001   @ Mode FIQ, FIQ&IRQ disable
msr     cpsr_c, r0
mov     sp, #0x4000
mov     r0, #0b11010010   @ Mode IRQ, FIQ&IRQ disable
msr     cpsr_c, r0
mov     sp, #0x8000
mov     r0, #0b11010011   @ Mode SVC, FIQ&IRQ disable
msr     cpsr_c, r0
mov     sp, #0x8000000
ldr r0, = GPBASE
/* guia bits xx999888777666555444333222111000 */
mov r1, # 0b00001000000000000000000000000000
str r1, [ r0, # GPFSEL0 ] @ Configura GPIO 9
/* guia bits 10987654321098765432109876543210 */
mov r1, # 0b00000000000000000000001000000000
ldr r2, = STBASE
bucle : bl espera @ Salta a rutina de espera
str r1, [ r0, # GPSET0 ]
bl espera @ Salta a rutina de espera
str r1, [ r0, # GPCLR0 ]
bl espera2 @ Salta a rutina de espera
str r1, [ r0, # GPSET0 ]
bl espera2 @ Salta a rutina de espera
str r1, [ r0, # GPCLR0 ]
bl espera2 @ Salta a rutina de espera
str r1, [ r0, # GPSET0 ]
bl espera3 @ Salta a rutina de espera
str r1, [ r0, # GPCLR0 ]
b bucle
/* rutina que espera un segundo */
espera : 
push {r0,r1}
ldr r3, [ r2, # STCLO ] @ Lee contador en r3
ldr r4, = 1000000
add r4, r3 @ r4= r3+ medio mill ón
ret : ldr r3, [ r2, # STCLO ]
cmp r3, r4 @ Leemos CLO hasta alcanzar
bne ret @ el valor de r4
pop {r0,r1}
bx lr
espera2 : 
push {r0,r1}
ldr r3, [ r2, # STCLO ] @ Lee contador en r3
ldr r4, = 500000
add r4, r3 @ r4= r3+ medio mill ón
b ret
espera3 : 
push {r0,r1}
ldr r3, [ r2, # STCLO ] @ Lee contador en r3
ldr r4, = 20000
add r4, r3 @ r4= r3+ medio mill ón
b ret
