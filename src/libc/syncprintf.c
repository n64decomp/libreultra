#include <stdarg.h>
#include <rmon.h>
#include <os.h>

s32 osSyncPrintf(s32 arg0, s32 arg1, s32 arg2)
{
    // This function left blank. Ifdeffed out in rom release
    return (1);
}
void rmonPrintf(const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    _Printf(osSyncPrintf, NULL, fmt, args);
    va_end(args);
}
