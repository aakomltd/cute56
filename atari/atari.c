#include "atari_internal.h"

#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>
#ifndef HOST
#include <mint/osbind.h>
#include <mint/falcon.h>

#include "screen-asm.h"
#include "timerd-asm.h"
#include "timervbl-asm.h"
#endif

#include "dsp_internal.h"
#include "graphics.h"

static volatile int isVblSet;

static Bitmap screen = { 320, 240, 16, BitmapTypeHighColor, NULL, { 0 } };
static HighColor col = 0x0000;

int load_bmp_texture(void* destination, const char* filename, int no_bytes, int offset, int copies);

#ifdef HOST
int32_t	Main( const DspWrapperInfo* pDspWrapperInfo )
{
    int* texture = malloc(131072*2);
    if(	load_bmp_texture(texture, "bluz3.bmp", 131072, 70,1) == 0 )
    {
        return EXIT_FAILURE;
    }

	setDspWrapper( pDspWrapperInfo );
#else
int main( int argc, char* argv[] )
{
	if( loadDspBinary( "calc.p56" ) == 0 )
	{
		return EXIT_FAILURE;
	}




	int32_t oldSSP = Super( 0L );

	asm_screen_save();

	// do this before we kill VBL
	(void)VsetMode( BPS16 | COL40 | VGA | VERTFLAG );

	asm_timerd_init();
	asm_timervbl_init();
#endif
	size_t screenSize = ( screen.width * screen.height * screen.depth / 8 ) + 15;

#ifdef HOST
	screen.pixels.pHc = (HighColor*)malloc( screenSize );
#else
	screen.pixels.pHc = (HighColor*)Mxalloc( screenSize, MX_STRAM );
#endif
	if( screen.pixels.pHc == NULL )
	{
#ifndef HOST
		asm_timervbl_deinit();
		asm_timerd_deinit();
		asm_screen_restore();
		Super( oldSSP );
#endif
		return EXIT_FAILURE;
	}

	// align on 16 bytes, beware you can't use (M)free anymore
	intptr_t ptr = (intptr_t)screen.pixels.pHc;
	ptr = ( ptr + 15 ) & ~15;
    screen.pixels.pHc = (HighColor*)ptr;

#ifndef HOST
	asm_screen_setvram( screen.pixels.pHc );
#endif

	/*
	 * Main demo loop. This is where you want to place your code.
	 */
    uint16_t t = 0;

    for( ; ; )
    {

		if( isVblSet )
		{
			// race condition as hell for HOST
			isVblSet = 0;

			// wait for vbl
            col = 0;

            t+= 1;
            dspSendUnsignedWord( t );
            HighColor* p = screen.pixels.pHc;
            HighColor* p2 = p+320;
            uint16_t* tx = (uint16_t*)texture;

            for(size_t i = 0; i < 240; i+=2)
            {
                for( size_t i = 0; i < 320; i+=2 )
                {
                    col = dspReceiveWord();
                    HighColor pixel = tx[col];

                    *p++ = pixel;
                    *p++ = pixel;
                    *p2++ = pixel;
                    *p2++ = pixel;

                }
                p += 320;
                p2 += 320;

            }


		}

#ifndef HOST
		if( *(volatile uint8_t*)0xfffffc02 == 0x39 )
		{
			break;
		}
#endif
	}

#ifndef HOST
	asm_timervbl_deinit();
	asm_timerd_deinit();
	asm_screen_restore();
	Super( oldSSP );
#endif

	return EXIT_SUCCESS;
}

void SysExit( int32_t code )
{
	exit( code );
}

void TimerDCallback( void )
{
}

void TimerVblCallback( void )
{
	isVblSet = 1;
}

Bitmap* ScreenGetPhysical( void )
{
	return &screen;
}

int load_bmp_texture(void* destination, const char* filename, int no_bytes, int offset, int copies)
{

    char* dest = (char*)destination;
    FILE *file = fopen(filename, "rb");
    if(file == NULL)
        return 0;

    fseek(file, offset, SEEK_SET);
    fread(dest, 1, no_bytes, file);
    fclose(file);

    for(int i = 0; i<no_bytes; i+=2)
    {
        char c1 = dest[i];
        char c2 = dest[i+1];
#ifdef HOST
        dest[i] = c1;
        dest[i+1] = c2;
#else
        dest[i] = c2;
        dest[i+1] = c1;
#endif
        for(int c = 1; c < copies; c++)
        {
#ifdef HOST
        dest[i+offset] = c1;
        dest[i+1+offset] = c2;
#else
        dest[i+offset] = c2;
        dest[i+1+offset] = c1;
#endif
        }
    }

    return 1;
}
