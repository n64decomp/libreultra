# Assembly Macros

.set NULL, 0
.set FALSE, 0
.set TRUE, 1

.set K0BASE, 0x80000000
.set K1BASE, 0xA0000000
.set K2BASE, 0xC0000000

.macro glabel label
    .global \label
    \label:
.endm
