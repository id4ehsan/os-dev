#ifndef _COMMON_H
#define _COMMON_H

typedef unsigned char byte;
typedef unsigned short word;
typedef unsigned __int64 uint64;
typedef byte bool;
#define true 1
#define false 0

extern unsigned pack_length;
extern unsigned pack_pos;
extern const byte* curin;
extern byte* curout;

#endif
