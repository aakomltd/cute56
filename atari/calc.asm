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


		move	#1,x0
		move    #>$100,r1	;r1 : sin
                move    #>$ff,m1	;m1 : sin wraparound
		move	a,n1		;n1 : t wrapped
		nop

		move	#rowU,r2
		move	#rowV,r3
                move	#duCol,r4
		move	#dvCol,r5
		move    #duRow,r6
		move	#dvRow,r7

		move	#-32,x0	;centre u and v
		move	#-127,x1
		nop
		move	x0,p:(r2)	;store centred u
		move	x1,p:(r3)	;store centred v

		rhost	b
		nop
		move    b,p:(r4)	;store duCol

		neg	b		;dvRow = -duCol
		rep	#8
		asl	b
		nop
		move	b,p:(r7)	;store dvRow


		rhost	b
		nop
		move	b,p:(r6)	;store duRow = cos(t)
		nop
		rep	#8
		asl	b
		move	b,p:(r5)	;store dvCol = cos(t)
		nop

_start_line
                do      #120,_end_screen

		move	p:(r2),a	;a : u = rowU
		move	p:(r3),b	;b : v = rowV
		nop
		add	b,a

		move	p:(r6),x0	;x0 : duRow
		move	p:(r7),y0	;y0 : dvRow
		move	x0,b
		nop
		add	y0,b

		do      #160,_end_line

		jclr	#1,X:<<$ffe9,*
		add	b,a	a,X:<<$ffeb

_end_line
		move	p:(r2),a	;a : u = rowU
		move	p:(r3),b	;b : v = rowV
		move	#>$ff,x1

		move	p:(r4),x0	;x0 : duCol
		move	p:(r5),y0	;y0 : dvCol

		add	x0,a
		add	x0,a
		add	y0,b
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

