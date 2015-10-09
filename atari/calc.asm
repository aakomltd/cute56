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

                rhost	x0

                move    #time,r0
                nop
                move    x0,p:(r0)

                move    #xcount,r5
                clr     a
                nop
                move    a,p:(r5)

                move    #ycount,r6
                move    #0,a
                nop
                move    a,p:(r6)

                clr     a
                clr     b
                nop
                move    a,y0
                move    a,x0


_start_line
                do      #120,_end_screen
                nop

                move    y0,b
                move    #>256,y1
                move    #>$ff00,x0
                nop
                add     y1,b
                nop
                and     x0,b
                nop
                move    b,y0
                nop


                clr     a
                clr     b

                do      #160,_end_line
                nop

                move    #>1,x1
                nop
                add     x1,b
                nop
                move    b,a
                nop
                add     y0,a
                nop


                whost	a
                nop

_end_line
                nop
_end_screen
                nop

                jmp	<start

start2:
                ori     #04,OMR     ;enable data roms

                rhost	x0

                move    #time,r0
                nop
                move    x0,p:(r0)

                move    #xcount,r5
                clr     a
                nop
                move    a,p:(r5)

                move    #ycount,r6
                move    #0,a
                nop
                move    a,p:(r6)


_start_line
                do      #120,_end_screen
                nop


                move    #0,x0
                move    #0,n2

                move    #xcount,r5
                nop
                move    p:(r5),a

                move    #>1,x1
                move    #$3000,x0
                move    #>$ff,y1
                nop
                add     x,a
                nop
                and     y1,a
                nop
                move    a,n3


                move    #ycount,r6
                move    #$3000,y0
                move    #>8,y1
                move    p:(r6),b
                nop
                add     y,b
                nop
                move    b,p:(r6)

                move    #>1<<(8-1),y0
                move    #time,r0
                nop
                move    p:(r0),x0
                move    #>0,a
                nop
                add     x0,a
                nop
                add     b,a
                move    a,y1
                move    #0,x1
                move    #$100,r3
                move    #$ff,m3
                nop
                move    y:(r3+n3),x0
                nop
                mpy     x0,y0,b
                add     y1,b
                nop
                move    b,n2
                nop
                rep     #4
                asr 	b

                do      #160,_end_line
                nop

                move    n2,a

                move    b,x1
                move    #>$ff,y1
                nop
                add     x1,a
                nop
                and     y1,a
                nop
                move    a,n2

                move    #$100,r2
                move    #$ff,m2     ;sine table wraparound

                move    #>1<<(5-1),y0
                move    #>16,y1
                move    #0,x1
                move    y:(r2+n2),x0
                nop
                mpy     x0,y0,a
                add     y1,a
                nop
                whost	a
                rep     #4
                nop

_end_line
                nop
_end_screen

                jmp	<start


time    ds  1
temp    ds  1
sin     ds  1
cos     ds  1
alpha   ds  1
beta    ds  1
gamma   dc  0
xcount  dc  0
ycount  dc  0
sinx    ds  1
siny    ds  1

