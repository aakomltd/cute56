rhost		MACRO	dst
		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,dst
		ENDM

whost		MACRO	src
		jclr	#1,X:<<$ffe9,*
		movep	src,X:<<$ffeb
		ENDM

		ORG	P:$0000
		jmp	>start

		ORG	P:$0040

start:
                ori     #04,OMR     ;enable data roms

                rhost	a		;a : t
		;move	#>128,a
		move	#>$ff,x0
		move	#time,r0
		and	x0,a
		move	a,p:(r0)

		move	#rowU,r2
		move	#rowV,r3
                move	#duCol,r4
		move	#dvCol,r5
		move    #duRow,r6
		move	#dvRow,r7

		move	#>1,x0	;centre u and v
		nop
		move	x0,p:(r2)	;store centred u
		move	x0,p:(r3)	;store centred v

		move    #>$100,r1	;r1 : sin
                move    #>$ff,m1	;m1 : sin wraparound
		move	a,n1		;n1 : t wrapped
		nop
		move    y:(r1+n1),y0	;sin(t) for duCol (and dvRow)
		move	#>1<<(8-1),y1	;the factor 256
		nop
		mpy	y1,y0,b		;scale duCol to the range [-128..127]
		move	#>128,x1
		move	b,a
		nop
		add	x1,b

		move    b,p:(r4)	;store duCol
		neg	a		;dvRow = -duCol
		nop
		add	x1,a
		nop
		move	a,p:(r7)	;store dvRow

		move	#time,r0
		nop
		move	p:(r0),n1	;n1 : t wrapped
		move    #>$140,r1	;r1 : sin
                move    #>$ff,m1	;m1 : sin wraparound
		nop
		move	y:(r1+n1),y0	;y1: cos(t)
		move	#>1<<(8-1),y1	;the factor 256
		nop
		mpy	y1,y0,b		;scale dvCol=dvRow to the range [-128..127]
		move	#>128,x1
		nop
		add	x1,b
		nop

		move	b,p:(r5)	;store dvCol = cos(t)
		move	b,p:(r6)	;store duRow = cos(t)
		nop

_start_line
                do      #120,_end_screen

		move	p:(r2),a	;a : u = rowU
		move	p:(r3),b	;b : v = rowV
		nop

		do      #160,_end_line

		move	a,x1
		move	b,y1
		rep	#8
		asl	b
		nop
		add	b,a
		nop
                whost	a
		nop
		move	x1,a
		move	y1,b

		move	p:(r6),x0	;x0 : duRow
		move	p:(r7),y0	;y0 : dvRow
		move	#>$ff,x1
		add	x0,a
		add	y0,b
		and	x1,a
		and	x1,b


_end_line
		move	p:(r2),a	;a : u = rowU
		move	p:(r3),b	;b : v = rowV
		move	#>$ff,x1

		move	p:(r4),x0	;x0 : duCol
		move	p:(r5),y0	;y0 : dvCol

		add	x0,a
		add	y0,b

		move	a,p:(r2)
		move	b,p:(r3)

_end_screen
                nop

                jmp	<start


time    ds  1
sint    ds  1
cost    ds  1

u	ds  1
v	ds  1
rowU	ds  1
rowV	ds  1
duCol	ds  1
dvCol	ds  1
duRow	ds  1
dvRow	ds  1

startU	dc  127
startV	dc  127

