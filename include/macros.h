#ifndef _MACROS_H_
#define _MACROS_H_

#define ARRAY_COUNT(arr) (s32)(sizeof(arr) / sizeof(arr[0]))

#define GLUE(a, b) a ## b
#define GLUE2(a, b) GLUE(a, b)

// Reduces big ifdefs that use different values
#ifdef VERSION_JP
#define JP_US_DEF(jp, us)        (jp)
#define JP_US_EU_DEF(jp, us, eu) (jp)
#elif defined(VERSION_US)
#define JP_US_DEF(jp, us)        (us)
#define JP_US_EU_DEF(jp, us, eu) (us)
#elif defined(VERSION_EU)
// TODO: JP_US_DEF() is possibly wrong in this case
#define JP_US_DEF(jp, us)        (us)
#define JP_US_EU_DEF(jp, us, eu) (eu)
#endif

// Avoid compiler warnings for unused variables
#ifdef __GNUC__
#define UNUSED __attribute__((unused))
#else
#define UNUSED
#endif

// Ignore GLOBAL_ASM blocks when syntax-checking with GCC
#ifdef __GNUC__
#define GLOBAL_ASM(...)
#endif

// Static assertions
#ifdef __GNUC__
#define STATIC_ASSERT(cond, msg) _Static_assert(cond, msg)
#else
#define STATIC_ASSERT(cond, msg) typedef char GLUE2(static_assertion_failed, __LINE__)[(cond) ? 1 : -1]
#endif

#endif
