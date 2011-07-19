# vim: syntax=sh

# For each index i, _GCC[i] _GMP[i] _MPFR[i] are a matched set; which means
# as shown in the rows immediately below, these are a matched set:
#      _GCC[0] _GMP[0] _MPFR[0]
#      _GCC[1] _GMP[1] _MPFR[1]
# and so on.

# *****************************************************************************
# GMP
# *****************************************************************************

_GMP[0]=""
_GMP[1]="gmp-4.3.2"

_GMP_MD5SUM[0]=""
_GMP_MD5SUM[1]="dd60683d7057917e34630b4a787932e8"

_GMP_URL[0]=""
_GMP_URL[1]="ftp://gcc.gnu.org/pub/gcc/infrastructure"

# *****************************************************************************
# MPFR
# *****************************************************************************

_MPFR[0]=""
_MPFR[1]="mpfr-2.4.2"

_MPFR_MD5SUM[0]=""
_MPFR_MD5SUM[1]="89e59fe665e2b3ad44a6789f40b059a0"

_MPFR_URL[0]=""
_MPFR_URL[1]="ftp://gcc.gnu.org/pub/gcc/infrastructure"

# *****************************************************************************
# GCC
# *****************************************************************************

_GCC[0]="gcc-4.2.4"
_GCC[1]="gcc-4.4.4"

_GCC_MD5SUM[0]="d79f553e7916ea21c556329eacfeaa16"
_GCC_MD5SUM[1]="7ff5ce9e5f0b088ab48720bbd7203530"

_GCC_URL[0]="ftp://ftp.gnu.org/gnu/gcc/${_GCC[0]} http://ftp.gnu.org/gnu/gcc/${_GCC[0]}"
_GCC_URL[1]="ftp://ftp.gnu.org/gnu/gcc/${_GCC[1]} http://ftp.gnu.org/gnu/gcc/${_GCC[1]}"
