
#define NULL ((void*)0)

void*  memset(void *mem, int c, unsigned size);
void* memcpy(void *dst, const void *src, unsigned size);

char* __cdecl strcat(char strDest[], char strSource[]);
int __cdecl strcmp(const char* string1, const char* string2);
char* __cdecl strcpy(char strDest[], const char strSource[]);
char* __cdecl strncpy(char *strDest, const char *strSource, unsigned n);
int __cdecl strlen(const char* string);
char * __cdecl strchr(const char* string, int c);
