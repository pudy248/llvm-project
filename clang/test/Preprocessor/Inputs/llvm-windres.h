#ifndef RC_INVOKED
#  error RC_INVOKED not defined
#endif
#ifndef __CYGWIN__
#  ifndef _WIN32
#    error _WIN32 not defined
#  endif
#  ifndef __MINGW32__
#    error __MINGW32__ not defined
#  endif
#endif
#define MY_ID 42
