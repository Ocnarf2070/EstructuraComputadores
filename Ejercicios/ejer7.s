.include "inter.inc"
.include "inicio.txt"
.include "pila.txt"
.text
	ldr   r4, =GPBASE
	mov   r5, #0b00000000000000000001000000000000
	str   r5, [r4, #GPFSEL0] @ Configure GPIO4
	mov   r5, #0b00000000000000000000000000010000
	ldr   r0, =STBASE 	 @ r0 is an input parameter (ST base address)
	mov r2, # 0b00000000000000000000000000000100
	mov r6, # 0b00000000000000000000000000001000
bucle:
	ldr r3,[r4,#GPLEV0]
	tst r3,r2
	beq sonarDo
	ldr r7,[r4,#GPLEV0]
	tst r7,r6
	beq sonarSol
	b bucle
sonarDo:
	ldr   r1, =1908 
	bl    espera		 
	str   r5, [r4, #GPSET0] 
	bl    espera		
	str   r5, [r4, #GPCLR0] 
	b     bucle
sonarSol:
	ldr   r1, =1279 	 
	bl    espera		 
	str   r5, [r4, #GPSET0] 
	bl    espera		
	str   r5, [r4, #GPCLR0] 
	b     bucle
espera:	
	push  {r4, r5}	         @ Save r4 and r5 in the stack
	ldr   r4, [r0, #STCLO]	 @ Load CLO timer
	add   r4, r1		 @ Add waiting time -> this is our ending time
ret1:	
	ldr   r5, [r0, #STCLO]	 @ Enter waiting loop: load current CLO timer
	cmp   r5, r4		 @ Compare current time with ending time
	blo   ret1		 @ If lower, go back to read timer again
	pop   {r4, r5}		 @ Restore r4 and r5
	bx    lr		 @ Return from routine
	


