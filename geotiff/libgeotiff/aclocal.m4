AC_DEFUN(AC_COMPILER_WFLAGS,
[
	# Remove -g from compile flags, we will add via CFG variable if
	# we need it.
	CXXFLAGS=`echo "$CXXFLAGS " | sed "s/-g //"`
	CFLAGS=`echo "$CFLAGS " | sed "s/-g //"`

	# check for GNU compiler, and use -Wall
	if test "$GCC" = "yes"; then
		C_WFLAGS="-Wall"
		CFLAGS="$CFLAGS -Wall"
		AC_DEFINE(USE_GNUCC)
	fi
	if test "$GXX" = "yes"; then
		CXX_WFLAGS="-Wall"
		CXXFLAGS="$CXXFLAGS -Wall"
		AC_DEFINE(USE_GNUCC)
	fi
	AC_SUBST(CXX_WFLAGS,$CXX_WFLAGS)
	AC_SUBST(C_WFLAGS,$C_WFLAGS)
])

AC_DEFUN(AC_COMPILER_PIC,
[
	echo 'void f(){}' > conftest.c
	if test -z "`${CC-cc} -fPIC -c conftest.c 2>&1`"; then
	  C_PIC=-fPIC
	else
	  C_PIC=
	fi
	if test -z "`${CXX-g++} -fPIC -c conftest.c 2>&1`"; then
	  CXX_PIC=-fPIC
	else
	  CXX_PIC=
	fi
	rm -f conftest*

	AC_SUBST(CXX_PIC,$CXX_PIC)
	AC_SUBST(C_PIC,$C_PIC)
])

dnl
dnl Try to find something to link shared libraries with.  Use "c++ -shared"
dnl in preference to "ld -shared" because it will link in required c++
dnl run time support for us. 
dnl
AC_DEFUN(AC_LD_SHARED,
[
  echo 'void g(); int main(){ g(); return 0; }' > conftest1.c

  echo 'void g(); void g(){}' > conftest2.c
  ${CC} ${C_PIC} -c conftest2.c

  SO_EXT="so"
  export SO_EXT

  LD_SHARED="/bin/true"
  if test "$LD_SHARED" = "/bin/true" \
          -a -z "`ld -shared conftest2.o -o libconftest.so 2>&1`" ; then
    if test -z "`${CC} conftest1.c libconftest.so -o conftest1 2>&1`"; then
      LD_LIBRARY_PATH_OLD="$LD_LIBRARY_PATH"
      LD_LIBRARY_PATH="`pwd`"
      export LD_LIBRARY_PATH
      if test -z "`./conftest1 2>&1`" ; then
        echo "checking for ld -shared ... yes"
        LD_SHARED="ld -shared"
      fi
      LD_LIBRARY_PATH="$LD_LIBRARY_PATH_OLD"
    fi
  fi

  dnl Test special MacOS (Darwin) case. 

  if test ! -z "`uname | grep Darwin`" \
          -a "$LD_SHARED" = "/bin/true" \
          -a -z "`${CC} -dynamiclib conftest2.o -o libconftest.so 2>&1`" ; then
    ${CC} -c conftest1.c
    if test -z "`${CC} conftest1.o libconftest.so -o conftest1 2>&1`"; then
      DYLD_LIBRARY_PATH_OLD="$DYLD_LIBRARY_PATH"
      if test -z "$DYLD_LIBRARY_PATH" ; then
        DYLD_LIBRARY_PATH="`pwd`"
      else
        DYLD_LIBRARY_PATH="`pwd`:$DYLD_LIBRARY_PATH"
      fi
      export DYLD_LIBRARY_PATH
      if test -z "`./conftest1 2>&1`" ; then
        echo "checking for ${CC} -dynamiclib ... yes"
        LD_SHARED="${CC} -dynamiclib"
	SO_EXT=dylib
      fi
      DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH_OLD"
    fi
    rm -f conftest1.o
  fi

  if test "$LD_SHARED" = "/bin/true" ; then
    echo "checking for ld -shared ... no"
  fi
  rm -f conftest* libconftest* 

  AC_SUBST(LD_SHARED,$LD_SHARED)
  AC_SUBST(SO_EXT,$SO_EXT)
])

