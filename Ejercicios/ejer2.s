.include "inter.inc"
.text
mrs r0,cpsr
mov     r0, #0b11010011   @ Modo SVC, FIQ&IRQ desact
msr spsr_cxsf,r0
add r0,pc,#4
msr ELR_hyp,r0
eret
ldr r0, = GPBASE
mov r1, # 0b00001000000000000000000000000000
str r1, [ r0, # GPFSEL0 ]
mov r1, # 0b00000000000000000000000000000001
str r1,[r0, # GPFSEL1]
mov r1, # 0b00000000000000000000011000000000
str r1, [ r0, # GPSET0 ]
mov r2, # 0b00000000000000000000000000000100
mov r4, # 0b00000000000000000000000000001000
bucle1:
	ldr r3,[r0,#GPLEV0]
	tst r3,r2
	bne bucle2
	mov r1, # 0b00000000000000000000001000000000
	str r1, [r0,#GPCLR0]
b infi
bucle2:
	ldr r3,[r0,#GPLEV0]
	tst r3,r4
	bne bucle1
	mov r1, # 0b00000000000000000000010000000000
	str r1, [r0,#GPCLR0]

infi: b infi
