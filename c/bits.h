#ifndef BITS_H
#define BITS_H

#define BITMASK(b) (1 << ((b) % CHAR_BIT))

#define BITSLOT(b) ((b) / CHAR_BIT)

#define BITSET(a, b) ((a)[BITSLOT(b)] |= BITMASK(b))

#define BITCLEAR(a, b) ((a)[BITSLOT(b)] &= ~BITMASK(b))

#define BITTEST(a, b) ((a)[BITSLOT(b)] & BITMASK(b))

#define BITNSLOTS(nb) ((nb + CHAR_BIT - 1) / CHAR_BIT)

/* Set all bits in A1 which are also set in A2.  In other words, perform
 *
 *    A1 |= A2.
 *
 * N is the length (in bits) of the array. 
 */
void BITSSET(unsigned char *restrict a1, const unsigned char *restrict a2, size_t n) 
{
	for (size_t i= 0;  i < BITNSLOTS(n);  ++i) {
		a1[i] |= a2[i];
	}
}

/* Count the total number of set bits. 
 */
size_t BITSCOUNT(const unsigned char *restrict a, size_t n)
{
	size_t ret= 0;
	for (size_t i= 0;  i < BITNSLOTS(n);  ++i) {
		/* This method to count bits in a char is from 
		 * http://graphics.stanford.edu/~seander/bithacks.html#CountBitsSet64
		 */
		ret += ((a[i] * 0x200040008001ULL & 0x111111111111111ULL) % 0xf);
	}
	return ret; 
}

#endif /* ! BITS_H */ 
