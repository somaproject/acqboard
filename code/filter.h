#ifndef FILTER_H
#define FILTER_H
#include "fixed.h"

#include <vector>

typedef std::vector<Fixed> signal;
 

signal overf(signal x, int max);
signal convrnd(signal x, int bits); 

signal rmac(const signal & x, const signal& h, int precision);
#endif // FILTER_H
