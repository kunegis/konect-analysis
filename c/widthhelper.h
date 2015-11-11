#ifndef WIDTHHELPER_H
#define WIDTHHELPER_H

#define CLASS_UNSIGNED  0
#define CLASS_SIGNED    1
#define CLASS_FLOAT     2

#define CONCATx2(x, y) x ## y
#define CONCATx3(x, y, z) x ## y ## z
#define CONCAT2(x, y) CONCATx2(x, y)
#define CONCAT3(x, y, z) CONCATx3(x, y, z)

#endif /* ! WIDTHHELPER */
