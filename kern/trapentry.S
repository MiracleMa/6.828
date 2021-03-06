/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

TRAPHANDLER_NOEC(divide_error, T_DIVIDE)	
TRAPHANDLER_NOEC(debug_error, T_DEBUG)
TRAPHANDLER_NOEC(non_maskable_interrupt, T_NMI)
TRAPHANDLER_NOEC(break_point, T_BRKPT)
TRAPHANDLER_NOEC(over_flow, T_OFLOW)
TRAPHANDLER_NOEC(bound_range_exceeded, T_BOUND)
TRAPHANDLER_NOEC(invalid_opcode, T_ILLOP)
TRAPHANDLER_NOEC(device_not_available, T_DEVICE)
TRAPHANDLER(double_fault, T_DBLFLT)
TRAPHANDLER(invalid_tss, T_TSS)
TRAPHANDLER(segment_not_present, T_SEGNP)
TRAPHANDLER(stack_fault, T_STACK)
TRAPHANDLER(general_protection, T_GPFLT)
TRAPHANDLER(page_fault, T_PGFLT)
TRAPHANDLER_NOEC(x87_fpu_floating_point_error, T_FPERR)
TRAPHANDLER_NOEC(alignment_check, T_ALIGN)
TRAPHANDLER_NOEC(machine_check, T_MCHK)
TRAPHANDLER_NOEC(simd_floating_point_exception, T_SIMDERR)
TRAPHANDLER_NOEC(sys_call, T_SYSCALL)

TRAPHANDLER_NOEC(vector0, IRQ_OFFSET+0)
TRAPHANDLER_NOEC(vector1, IRQ_OFFSET+1)
TRAPHANDLER_NOEC(vector2, IRQ_OFFSET+2)
TRAPHANDLER_NOEC(vector3, IRQ_OFFSET+3)
TRAPHANDLER_NOEC(vector4, IRQ_OFFSET+4)
TRAPHANDLER_NOEC(vector5, IRQ_OFFSET+5)
TRAPHANDLER_NOEC(vector6, IRQ_OFFSET+6)
TRAPHANDLER_NOEC(vector7, IRQ_OFFSET+7)
TRAPHANDLER_NOEC(vector8, IRQ_OFFSET+8)
TRAPHANDLER_NOEC(vector9, IRQ_OFFSET+9)
TRAPHANDLER_NOEC(vector10, IRQ_OFFSET+10)
TRAPHANDLER_NOEC(vector11, IRQ_OFFSET+11)
TRAPHANDLER_NOEC(vector12, IRQ_OFFSET+12)
TRAPHANDLER_NOEC(vector13, IRQ_OFFSET+13)
TRAPHANDLER_NOEC(vector14, IRQ_OFFSET+14)
TRAPHANDLER_NOEC(vector15, IRQ_OFFSET+15)


/*
 * Lab 3: Your code here for _alltraps
 */
.global _alltraps
_alltraps:
	pushl %ds
	pushl %es
	pushal

	movw  $GD_KD, %ax
	movw  %ax, %ds
	movw  %ax, %es

	pushl %esp
	# pushl $0
	# popfl
	call trap
	addl $4, %esp

	popal
	popl %es
	popl %ds
	addl $8, %esp
	iret