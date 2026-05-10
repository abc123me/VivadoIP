#ifndef _TFT_ILI9341_UTIL_H
#define _TFT_ILI9341_UTIL_H

#define DATA_STR(val) (val & 0xFF), (val & 0x100 ? " w/ DC" : "w/o DC")

#define SAFE_WHILE(CMP, TIMES, CODE)                                \
	cnt = 0;                                                        \
	while(CMP) {                                                    \
		if(cnt++ > TIMES)                                           \
			FAIL_MSG("Infinite loop detected on line %d", __LINE__) \
		CODE                                                        \
	}

#endif
