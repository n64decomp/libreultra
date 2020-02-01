#!smake
#
# Makefile for the gu subdirectory
#

include $(ROOT)/usr/include/make/PRdefs


LCOPTS = -mips2 -non_shared -fullwarn -G 0
LCINCS = -I. -I$(ROOT)/usr/include/PR -I$(ROOT)/usr/include

CFILES  = 			\
	align.c			\
	cosf.c			\
	coss.c			\
	frustum.c		\
	guLoadTile_bug.c	\
	loadtextureblockmipmap.c\
	lookat.c		\
	lookathil.c		\
	lookatref.c		\
	mtxcatf.c		\
	mtxcatl.c		\
	mtxutil.c		\
	normalize.c		\
	ortho.c			\
	parse_gbi.c		\
	parse_rdp.c		\
	perspective.c		\
	position.c		\
	poslight.c		\
	poslighthil.c		\
	random.c		\
	rotate.c		\
	rotateRPY.c		\
	scale.c			\
	sinf.c			\
	sins.c			\
	translate.c


ASFILES = 		\
	libm_vals.s	\
	sqrtf.s

include $(COMMONRULES)

default: $(OBJECTS)
