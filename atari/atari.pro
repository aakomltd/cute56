QT	-= core gui

TARGET	= atari
TEMPLATE= lib

DEFINES	+= HOST

SOURCES	+= \
	atari.c \
	dsp.c

HEADERS += \
	atari.h \
	dsp.h \
    graphics.h \
    atari_internal.h \
    dsp_internal.h