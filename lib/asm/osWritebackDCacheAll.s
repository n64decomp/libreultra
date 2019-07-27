
.set noat      # allow manual use of $at
.set noreorder # don't insert nops after branches
.set gp=64

.include "macros.inc"


.section .text, "ax" 


glabel osWritebackDCacheAll
/* 0DD010 80322010 3C088000 */  li    $t0, K0BASE
/* 0DD014 80322014 240A2000 */  li    $t2, 8192
/* 0DD018 80322018 010A4821 */  addu  $t1, $t0, $t2
/* 0DD01C 8032201C 2529FFF0 */  addiu $t1, $t1, -0x10
.L80322020:
/* 0DD020 80322020 BD010000 */  cache 1, ($t0)
/* 0DD024 80322024 0109082B */  sltu  $at, $t0, $t1
/* 0DD028 80322028 1420FFFD */  bnez  $at, .L80322020
/* 0DD02C 8032202C 25080010 */   addiu $t0, $t0, 0x10
/* 0DD030 80322030 03E00008 */  jr    $ra
/* 0DD034 80322034 00000000 */   nop   

/* 0DD038 80322038 00000000 */  nop   
/* 0DD03C 8032203C 00000000 */  nop   
