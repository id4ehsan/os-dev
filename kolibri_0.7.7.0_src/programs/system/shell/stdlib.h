
#define RAND_MAX 0x7FFFU

#define isspace(c) ((c)==' ')
#define abs(i) (((i)<0)?(-(i)):(i))

#define random(num) ((rand()*(num))/((RAND_MAX+1)))

void* __fastcall malloc(unsigned size);
void  __fastcall free(void *pointer);
void* __fastcall realloc(void* pointer, unsigned size);

void srand (unsigned seed);
int rand (void);
