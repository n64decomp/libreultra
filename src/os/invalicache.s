#include "asm_helper.h"
#.set noreorder
.text
LEAF(osInvalICache)
	blez a1, 2f
	nop
	li t3, ICACHE_SIZE
	bgeu a1, t3, 3f
	nop
	move t0, a0
	addu t1, a0, a1
	bgeu t0, t1, 2f
	nop
	andi t2, t0, ICACHE_LINEMASK
	addiu t1, t1, -ICACHE_LINESIZE
	subu t0, t0, t2
1:
	CACHE((C_HINV|CACH_PI), (t0))
    .set noreorder
	bltu t0, t1, 1b
	addiu t0, t0, ICACHE_LINESIZE
    .set reorder
2:
	jr ra
	#nop
3:
	li t0, KUSIZE
	addu t1, t0, t3
	addiu t1, t1, -ICACHE_LINESIZE
4:
	CACHE((C_IINV|CACH_PI), (t0))
    .set noreorder
	bltu t0, t1, 4b
	addiu t0, t0, ICACHE_LINESIZE
    .set reorder

	jr ra
	#nop
END(osInvalICache)
