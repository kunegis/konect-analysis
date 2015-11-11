#ifndef MURMUR3_H
#define MURMUR3_H

/*
 * Taken from a third party, but I don't know which. 
 */ 

#include <stdint.h>

#define FORCE_INLINE __attribute__((always_inline))

uint32_t rotl32 ( uint32_t x, int8_t r )
{
    return (x << r) | (x >> (32 - r));
}

#define ROTL32(x,y) rotl32(x,y)

#define BIG_CONSTANT(x) (x##LLU)

#if defined(__BYTE_ORDER__) && defined(__ORDER_LITTLE_ENDIAN__)
# if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#   define BYTESWAP(x) (x)
# endif

#elif defined(__i386)  || defined(__x86_64) \
||  defined(__alpha) || defined(__vax)

# define BYTESWAP(x) (x)

#elif defined(__GNUC__) || defined(__clang__)
#ifdef __has_builtin
#if __has_builtin(__builtin_bswap32)
#define BYTESWAP(x) __builtin_bswap32(x)
#endif
#endif
#endif 
#ifndef BYTESWAP
# define BYTESWAP(x)   ((((x)&0xFF)<<24) \
|(((x)>>24)&0xFF) \
|(((x)&0x0000FF00)<<8)    \
|(((x)&0x00FF0000)>>8)    )
#endif

#define getblock(p, i) BYTESWAP(p[i])

uint32_t fmix32( uint32_t h )
{
    h ^= h >> 16;
    h *= 0x85ebca6b;
    h ^= h >> 13;
    h *= 0xc2b2ae35;
    h ^= h >> 16;
    
    return h;
}

#ifdef __cplusplus
extern "C"
#else
extern
#endif
void MurmurHash3_x86_32( const void * key, int len, uint32_t seed, void * out )
{
    const uint8_t * data = (const uint8_t*)key;
    const int nblocks = len / 4;
    int i;
    
    uint32_t h1 = seed;
    
    uint32_t c1 = 0xcc9e2d51;
    uint32_t c2 = 0x1b873593;

    
    const uint32_t * blocks = (const uint32_t *)(data + nblocks*4);
    
    for(i = -nblocks; i; i++)
    {
        uint32_t k1 = getblock(blocks,i);
        
        k1 *= c1;
        k1 = ROTL32(k1,15);
        k1 *= c2;
        
        h1 ^= k1;
        h1 = ROTL32(h1,13);
        h1 = h1*5+0xe6546b64;
    }
    

    {
        const uint8_t * tail = (const uint8_t*)(data + nblocks*4);
        
        uint32_t k1 = 0;
        
        switch(len & 3)
        {
            case 3: k1 ^= tail[2] << 16;
            case 2: k1 ^= tail[1] << 8;
            case 1: k1 ^= tail[0];
                k1 *= c1; k1 = ROTL32(k1,15); k1 *= c2; h1 ^= k1;
        };
    }

    
    h1 ^= len;
    
    h1 = fmix32(h1);
    
    *(uint32_t*)out = h1;
}

#endif /* ! MURMUR3_H */
