
#include "kolibri.h"
#include "string.h"


extern char KOL_PATH[256];
extern char KOL_PARAM[256];
extern char KOL_DIR[256];


 __declspec(noreturn) void __cdecl kol_exit()
{
	__asm {
		mov	eax, -1
		int	40h
	}
}


void __cdecl kol_sleep(unsigned d)
{
	__asm {
		mov	ebx, d
		mov	eax, 5
		int	40h
	}
}


void __cdecl kol_wnd_define(unsigned x, unsigned y, unsigned w, unsigned h, unsigned c)
{
	register int _ebx = x * 65536 + w;
	register int _ecx = y * 65536 + h;
	__asm {
		mov	ebx, _ebx
		mov	ecx, _ecx
		mov	edx, c
		xor	eax, eax
		mov	esi, 0xFFFFFF
		int	40h
	}
}


void __cdecl kol_wnd_move(unsigned x, unsigned y)
{
	__asm {
		mov	ebx, x
		mov	ecx, y
		mov	eax, 67
		mov	edx, -1
		mov	esi, -1
		int	40h
	}
}


void __cdecl kol_event_mask(unsigned e)
{
	__asm {
		mov	ebx, e
		mov	eax, 40
		int	40h
	}
}


unsigned __cdecl kol_event_wait()
{
	__asm {
		mov	eax, 10
		int	40h
	}
}


unsigned __cdecl kol_event_wait_time(unsigned time)
{
	__asm {
		mov	ebx, time
		mov	eax, 23
		int	40h
	}
}


unsigned __cdecl kol_event_check()
{
	__asm {
		mov	eax, 11
		int	40h
	}
}


void __cdecl kol_paint_start()
{
	__asm {
		mov	eax, 12
		mov	ebx, 1
		int	40h
	}
}


void __cdecl kol_paint_end()
{
	__asm {
		mov	eax, 12
		mov	ebx, 2
		int	40h
	}
}


void __cdecl kol_paint_pixel(unsigned x, unsigned y, unsigned c)
{
	__asm {
		mov	edx, c
		mov	ecx, y
		mov	ebx, x
		mov	eax, 1
		int	40h
	}
}


void __cdecl kol_paint_bar(unsigned x, unsigned y, unsigned w, unsigned h, unsigned c)
{
	register int _ebx = x * 65536 + w;
	register int _ecx = y * 65536 + h;
	__asm {
		mov	ebx, _ebx
		mov	ecx, _ecx
		mov	edx, c
		mov	eax, 13
		int	40h
	}
}


void __cdecl kol_paint_line(unsigned x1, unsigned y1, unsigned x2, unsigned y2, unsigned c)
{
	register unsigned _ebx = x1 * 65536 + x2;
	register unsigned _ecx = y1 * 65536 + y2;
	__asm {
		mov	ebx, _ebx
		mov	ecx, _ecx
		mov	edx, c
		mov	eax, 38
		int	40h
	}
}


void __cdecl kol_paint_string(unsigned x, unsigned y, char *s, unsigned c)
{
	__asm {
		mov	ebx, x
		shl	ebx, 16
		add	ebx, y
		mov	ecx, c
		mov	edx, s
		mov	eax, 4
		int	40h
	}
}


void __cdecl kol_paint_image(unsigned x, unsigned y, unsigned w, unsigned h, char *d)
{
	register unsigned _ecx = w * 65536 + h;
	register unsigned _edx = x * 65536 + y;
	__asm {
		mov	ecx, _ecx
		mov	edx, _edx
		mov	ebx, d
		mov	eax, 7
		int	40h
	}
}


void __cdecl kol_paint_image_pal(unsigned x, unsigned y, unsigned w, unsigned h, char *d, unsigned *palette)
{
	register unsigned _ecx = w * 65536 + h;
	register unsigned _edx = x * 65536 + y;
	__asm {
		mov	ecx, _ecx
		mov	edx, _edx
		mov	ebx, d
		mov	edi, palette
		xor	ebp, ebp
		push	8
		pop	esi
		mov	eax, 65
		int	40h
	}
}


unsigned __cdecl kol_key_get()
{
	__asm {
		mov	eax, 2
		int	40h
	}
}


unsigned __cdecl kol_key_control()
{
	__asm {
		mov	eax, 66
		mov	ebx, 3
		int	40h
	}
}


void __cdecl kol_key_lang_set(unsigned lang)
{
	__asm {
		mov	edx, lang
		mov	eax, 21
		mov	ebx, 2
		mov	ecx, 9
		int	40h
	}
}


unsigned __cdecl kol_key_lang_get()
{
	__asm {
		mov	eax, 26
		mov	ebx, 2
		mov	ecx, 9
		int	40h
	}
}


void __cdecl kol_key_mode_set(unsigned mode)
{
	__asm {
		mov	ecx, mode
		mov	eax, 66
		mov	ebx, 1
		int	40h
	}
}


unsigned __cdecl kol_key_mode_get()
{
	__asm {
		mov	eax, 66
		mov	ebx, 2
		int	40h
	}
}


unsigned __cdecl kol_btn_get()
{
	__asm {
		mov	eax, 17
		int	40h
	}
}


void __cdecl kol_btn_define(unsigned x, unsigned y, unsigned w, unsigned h, unsigned d, unsigned c)
{
	register unsigned _ebx = x * 65536 + w;
	register unsigned _ecx = y * 65536 + h;
	__asm {
		mov	edx, d
		mov	ebx, _ebx
		mov	ecx, _ecx
		mov	esi, c
		mov	eax, 8
		int	40h
	}
}


void __cdecl kol_btn_type(unsigned t)
{
	__asm {
		mov	ecx, t
		mov	eax, 48
		mov	ebx, 1
		int	40h
	}	
}


void __cdecl kol_wnd_caption(char *s)
{
	__asm {
		mov	ecx, s
		mov	eax, 71
		mov	ebx, 1
		int	40h
	}
}


unsigned __cdecl kol_mouse_pos()
{
	__asm {
		mov	eax, 37
		xor	ebx, ebx
		int	40h
	}
}


unsigned __cdecl kol_mouse_posw()
{
	__asm {
		mov	eax, 37
		mov	ebx, 1
		int	40h
	}
}


unsigned __cdecl kol_mouse_btn()
{
	__asm {
		mov	eax, 37
		mov	ebx, 2
		int	40h
	}
}


void __cdecl kol_board_putc(char c)
{
	__asm {
		mov	cl, c
		mov	eax, 63
		mov	ebx, 1
		int	40h
	}
}


void __cdecl kol_board_puts(char *s)
{
unsigned i;
i = 0;
while (*(s+i))
	{
		kol_board_putc(s[i]);
		i++;
	}
}


void __cdecl kol_board_puti(int n)
{
char c;
int i = 0;
do 
	{
	c = n % 10 + '0';
	kol_board_putc(c);
	i++;
	}
	while ((n /= 10) > 0);
}


int __cdecl kol_file_70(kol_struct70 *k)
{
	__asm {
		mov	ebx, k
		mov	eax, 70
		int	40h
	}
}


kol_struct_import* __fastcall kol_cofflib_load(char *name)
{
	__asm {
		/*mov	ecx, name*/
		mov	eax, 68
		mov	ebx, 19
		int	40h
	}
}


void* __cdecl kol_cofflib_procload (kol_struct_import *imp, char *name)
{
int i;
for (i=0;;i++)
	if ( NULL == ((imp+i) -> name))
		break;
	else
		if ( 0 == strcmp(name, (imp+i)->name) )
			return (imp+i)->data;
return NULL;
}


unsigned __cdecl kol_cofflib_procnum (kol_struct_import *imp)
{
unsigned i, n;

for (i=n=0;;i++)
	if ( NULL == ((imp+i) -> name))
		break;
	else
		n++;

return n;
}


void __cdecl kol_cofflib_procname (kol_struct_import *imp, char *name, unsigned n)
{
unsigned i;
*name = 0;

for (i=0;;i++)
	if ( NULL == ((imp+i) -> name))
		break;
	else
		if ( i == n )
			{
			strcpy(name, ((imp+i)->name));
			break;
			}

}


unsigned __cdecl kol_system_cpufreq()
{
	__asm {
		mov	eax, 18
		mov	ebx, 5
		int	40h
	}
}


unsigned __fastcall kol_system_mem()
{
	__asm {
		mov	eax, 18
		mov	ebx, 17
		int	40h
	}
}


unsigned __fastcall kol_system_memfree()
{
	__asm {
		mov	eax, 18
		mov	ebx, 16
		int	40h
	}
}


unsigned __fastcall kol_system_time_get()
{
	__asm {
		mov	eax, 3
		int	40h
	}
}


unsigned __fastcall kol_system_date_get()
{
	__asm {
		mov	eax, 29
		int	40h
	}
}


unsigned __fastcall kol_system_end(unsigned param)
{
	__asm {
		//mov	ecx, param
		mov	eax, 18
		mov	ebx, 9
		int	40h
	}
}


void __cdecl kol_path_file2dir(char *dir, char *fname)
{
unsigned i;
strcpy (dir, fname);
for ( i = strlen(dir);; --i)
	if ( '/' == dir[i])
		{
		dir[i] = '\0';
		return;
		}
}


void __cdecl kol_path_full(char *full, char *fname)
{
char temp[256];

switch (*fname)
{

case '/':
	strncpy(temp, fname+1, 2);
	temp[2]=0;
	if ( (!strcmp("rd", temp)) || (!strcmp("hd", temp)) || (!strcmp("cd", temp)) )
		strcpy (full, fname);
	break;

case '.':
	break;

default:
	break;

};

}



void __cdecl kol_screen_wait_rr()
{
	__asm {
		mov	eax, 18
		mov	ebx, 14
		int	40h
	}
}



void __cdecl kol_screen_get_size(unsigned *w, unsigned *h)
{
register unsigned _size;
	__asm {
		mov	eax, 14
		int	40h
		mov	_size, eax
	}
*w = _size / 65536;
*h = _size % 65536;
}



unsigned __cdecl kol_skin_height()
{
	__asm {
		mov	eax, 48
		mov	ebx, 4
		int	40h
	}
}


unsigned __cdecl kol_thread_start(unsigned start, unsigned stack)
{
	__asm {
		mov	ecx, start
		mov	edx, stack
		mov	eax, 51
		mov	ebx, 1
		int	40h
	}
}


unsigned __cdecl kol_time_tick()
{
	__asm {
		mov	eax, 26
		mov	ebx, 9
		int	40h
	}
}


unsigned __cdecl kol_sound_speaker(char data[])
{
	__asm {
		mov	esi, data
		mov	eax, 55
		mov	ebx, 55
		int	40h
	}
}


unsigned __fastcall kol_process_info(unsigned slot, char buf1k[])
{
	__asm {
		mov	ebx, edx//buf1k
		//mov	ecx, slot
		mov	eax, 9
		int	40h
	}
}


int __fastcall kol_process_kill_pid(unsigned process)
{
	__asm {
		//mov	ecx, process
		mov	eax, 18
		mov	ebx, 18
		int	40h
	}
}
