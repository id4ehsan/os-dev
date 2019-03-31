
unsigned int seed_o = 0x45168297;


void srand (unsigned seed)
{
seed_o = seed;
}


int rand (void)
{
seed_o = seed_o * 0x15a4e35 + 1;
return(seed_o >> 16);
}


void* __fastcall malloc(unsigned s)
{
	__asm {
		mov	eax, 68
		mov	ebx, 12
		int	40h
	}
}


void __fastcall free(void *p)
{
	__asm {
		mov	eax, 68
		mov	ebx, 13
		int	40h
	}
}


void* __fastcall realloc(void *p, unsigned s)
{
	__asm {
		mov	eax, 68
		mov	ebx, 20
		int	40h
	}
}
