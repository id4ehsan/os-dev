
///===========================

#define CON_COLOR_BLUE		1
#define CON_COLOR_GREEN		2
#define CON_COLOR_RED		4
#define CON_COLOR_BRIGHT	8
/* цвет фона */
#define CON_BGR_BLUE		0x10
#define CON_BGR_GREEN		0x20
#define CON_BGR_RED		0x40
#define CON_BGR_BRIGHT		0x80

///===========================

union {
struct {
void (__stdcall * con_init)(unsigned w_w, unsigned w_h, unsigned s_w, unsigned s_h, const char* t);
void (__cdecl * printf)(const char* format,...);
void (__stdcall * _exit)(char bCloseWindow);
void (__stdcall * gets)(char* str, int n);
 int (__stdcall * getch)(void);
 int (__stdcall * con_get_font_height)(void);
 int (__stdcall * con_set_cursor_height)(int new_height);
unsigned (__stdcall * con_get_flags)(void);
unsigned (__stdcall * con_set_flags)(unsigned new_flags);
void (__stdcall * con_cls)(void);
};
void* con_functions[10];
} con_import;
#define con_init con_import.con_init
#define printf con_import.printf
#define _exit con_import._exit
#define gets con_import.gets
#define getch con_import.getch
#define con_get_font_height con_import.con_get_font_height
#define con_set_cursor_height con_import.con_set_cursor_height
#define con_get_flags con_import.con_get_flags
#define con_set_flags con_import.con_set_flags
#define con_cls con_import.con_cls

static const char* con_names[10] =
{ "con_init", "con_printf", "con_exit", "con_gets", "con_getch2",
  "con_get_font_height", "con_set_cursor_height", "con_get_flags", "con_set_flags", "con_cls" };

///===========================

void CONSOLE_INIT(char title[])
{
	int i;
kol_struct_import *imp;

imp = kol_cofflib_load("/sys/lib/console.obj");
if (imp == NULL)
	kol_exit();

#if 0
con_init = ( void (__stdcall *)(unsigned, unsigned, unsigned, unsigned, const char*)) 
		kol_cofflib_procload (imp, "con_init");
if (con_init == NULL)
	kol_exit();

printf = ( void (__cdecl *)(const char*,...))
		kol_cofflib_procload (imp, "con_printf");
if (printf == NULL)
	kol_exit();

_exit = ( void ( __stdcall *)(char))
		kol_cofflib_procload (imp, "con_exit");
if (_exit == NULL)
	kol_exit();

gets = ( void (__stdcall *)(char*, int))
		kol_cofflib_procload (imp, "con_gets");
if (gets == NULL)
	kol_exit();

getch = ( int ( __stdcall *)(void))
		kol_cofflib_procload (imp, "con_getch2");
if (getch == NULL)
	kol_exit();

con_get_font_height = ( int (__stdcall*)(void))
		kol_cofflib_procload (imp, "con_get_font_height");
if (con_get_font_height == NULL)
	kol_exit();

con_set_cursor_height = ( int (__stdcall*)(int))
		kol_cofflib_procload (imp, "con_set_cursor_height");
if (con_set_cursor_height == NULL)
	kol_exit();

con_get_flags = ( unsigned (__stdcall*)(void))
		kol_cofflib_procload (imp, "con_get_flags");
if (con_get_flags == NULL)
	kol_exit();

con_set_flags = ( unsigned (__stdcall*)(unsigned))
		kol_cofflib_procload (imp, "con_set_flags");
if (con_set_flags == NULL)
	kol_exit();

con_cls = ( void (__stdcall*)(void))
		kol_cofflib_procload (imp, "con_cls");
if (con_cls == NULL)
	kol_exit();
#else
	for (i=0; i<10; i++)
	{
		if (!(con_import.con_functions[i] = kol_cofflib_procload(imp, con_names[i])))
			kol_exit();
	}
#endif

con_init(-1, -1, -1, -1, title);
}
