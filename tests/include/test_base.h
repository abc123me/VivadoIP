#ifndef _UTILS_H
#define _UTILS_H

#include "verilated.h"

#include "stdio.h"
#include "stdint.h"

#define FAIL_TEST_WITH_MSG(fmt, ...) {  \
	printf("FAIL - " fmt, __VAQ_ARGS__); \
	FAIL_TEST                            \
}

#define FAIL_TEST err = 1; goto gtfo;
#define CHCK_FAIL_OR_PASS if(err) goto gtfo; else puts("PASS");

#endif
