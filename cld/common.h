#ifndef _CLD_COMMON_H
#define _CLD_COMMON_H

#ifdef __cplusplus
#  define BEGIN_C_DECLS extern "C" {
#  define END_C_DECLS   }
#else /* !__cplusplus */
#  define BEGIN_C_DECLS
#  define END_C_DECLS
#endif /* __cplusplus */

#if HAVE_CONFIG_H
#  include <config.h>
#endif

#include <sys/types.h>
#include <sys/mman.h>

#if STDC_HEADERS
#  include <stdio.h>
#  include <stdlib.h>
#  include <stdarg.h>
#  include <string.h>
#endif

#if HAVE_UNISTD_H
#  include <unistd.h>
#endif

#include <glib.h>

#ifndef EXIT_SUCCESS
#  define EXIT_SUCCESS  0
#  define EXIT_FAILURE  1
#endif

#endif /* !_CLD_COMMON_H */
