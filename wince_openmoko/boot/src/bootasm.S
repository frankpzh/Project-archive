.globl start
start:
	mov sp, #0x1000
	bl init
	bl main
	mov pc, r0

	// set mode to supervisor
	mrs r0, cpsr
	bic r0, r0, #0x1f
	orr r0, r0, #0xd3
	msr cpsr, r0

	// disable watchdog
	ldr r0, =0x53000000
	mov r1, #0x0
	str r1, [r0]

# define INTMSK		0x4A000008	/* Interupt-Controller base addresses */
# define INTSUBMSK	0x4A00001C
# define INTSUBMSK_val 	0x0000ffff

	mov	r1, #0xffffffff
	ldr	r0, =INTMSK
	str	r1, [r0]

	ldr	r1, =INTSUBMSK_val
	ldr	r0, =INTSUBMSK
	str	r1, [r0]
