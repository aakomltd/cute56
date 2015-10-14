rhost		MACRO	dst
		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,dst
		ENDM

whost		MACRO	src
		jclr	#1,X:<<$ffe9,*
		movep	src,X:<<$ffeb
		ENDM

mshr		MACRO	s,m,n,acc
		move	#@pow(2,-n),m
		mpy	s,m,acc
		ENDM

mshl		MACRO	s,m,n,acc
		move	#>@cvi(@pow(2,n-1)),m
		mpy	s,m,acc
		ENDM

		ORG	P:$0000
		jmp	>start

		ORG	P:$0040

start:
                ori     #04,OMR     ;enable data roms

                rhost	a		;a : t		
		move	#>255,x0
		move	a,b
		move	#time,r0
		and	x0,a
		move	a,p:(r0)
		;move	#>3,x0
		;nop
		;and	x0,b
		;rep	#3
		;lsr	a
		;nop
		;move	a,x1

		move	#1,x0
		move    #>$100,r1	;r1 : sin
                move    #>$ff,m1	;m1 : sin wraparound
		move	a,n1		;n1 : t wrapped
		nop
		;move    y:(r1+n1),b
		;nop
		;add	x0,a
		;nop
		;move	a,n1
		;nop
		;move    y:(r1+n1),a
		;nop
		;move	a,x0
		;sub	a,b
		;nop
		;move	b,y0
		;mpy	x1,y0,b
		;nop
		;add	y0,b
		;nop
		;move	b,a



		move	#rowU,r2
		move	#rowV,r3
                move	#duCol,r4
		move	#dvCol,r5
		move    #duRow,r6
		move	#dvRow,r7

		move	#>32,x0	;centre u and v
		nop
		move	x0,p:(r2)	;store centred u
		move	x0,p:(r3)	;store centred v

		move    #>$100,r1	;r1 : sin
                move    #>$ff,m1	;m1 : sin wraparound
		move	a,n1		;n1 : t wrapped
		nop
		move    y:(r1+n1),y0	;sin(t) for duCol (and dvRow)
;		move	#>1<<(3-1),y1	;scale factor
		move	#>6,y1
		nop
		mpy	y1,y0,b		;scale duCol to the range [-128..127]
		move	#>128,x1
		move	b,a
		nop
		add	x1,b
		nop
		move    b,p:(r4)	;store duCol

		neg	a		;dvRow = -duCol
		nop
		add	x1,a
		nop
		rep	#8
		lsl	a
		nop
		move	a,p:(r7)	;store dvRow

		move	#time,r0
		nop
		move	p:(r0),n1	;n1 : t wrapped
		move    #>$140,r1	;r1 : sin
                move    #>$ff,m1	;m1 : sin wraparound
		nop
		move	y:(r1+n1),y0	;y1: cos(t)
		;move	#>1<<(3-1),y1	;scale factor
		move	#>3,y1
		nop
		mpy	y1,y0,b		;scale dvCol=dvRow to the range [-128..127]
		move	#>128,x1
		nop
		add	x1,b
		nop
		move	b,p:(r6)	;store duRow = cos(t)
		nop
		rep	#8
		lsl	b
		move	b,p:(r5)	;store dvCol = cos(t)
		nop

_start_line
                do      #120,_end_screen

		move	p:(r2),a	;a : u = rowU
		move	p:(r3),b	;b : v = rowV

		move	p:(r6),x0	;x0 : duRow
		move	p:(r7),y0	;y0 : dvRow

		do      #160,_end_line

		move	b,r1
		add	a,b
                whost	b
		move	r1,b

		add	x0,a
		add	y0,a

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

