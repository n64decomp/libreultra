#include <stdarg.h>
#include <rmon.h>
#include <os.h>

char *osSyncPrintf(char *arg0, const char *arg1, size_t size)
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
