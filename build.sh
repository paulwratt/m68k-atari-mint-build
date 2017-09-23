#!/bin/sh

set -e

target=m68k-atari-mintelf

if [ -z "${INSTALL_DIR}" ] ; then
	INSTALL_DIR="$HOME/gnu-tools-elf"
fi

CPU_DIRS="m68000 m68020-60 m5475"	# target directory
CPU_OPTS="m68000 m68020-60 mcpu=5475"	# gcc command line
CPU_CPUS="m68000 m68020-60 5475"		# --with-cpu=
CPU_COUNT=$(echo ${CPU_DIRS} | tr ' ' '\n' | wc -l)

indices=""
indices_all=""
i=1
while [ "$i" -le "${CPU_COUNT}" ] ; do
	indices_all="$indices_all $i"
	i=$((i + 1))
done
skip_native=0
native_only=0
clean=0

# parse command line
for arg in $*
do
	case $arg in
	--skip-native)
	skip_native=1
	;;
	--native-only)
	native_only=1
	;;
	--all)
	indices=$indices_all
	;;
	--clean)
	clean=1
	;;
	*)
	ok=0
	i=1
	while [ "$i" -le "${CPU_COUNT}" ] ; do
		cpu=$(echo $CPU_CPUS | cut -d ' ' -f $i)
		if [ "$arg" = "$cpu" ] ; then
			indices="$indices $i"
			ok=1
		fi
		i=$((i + 1))
	done
	if [ $ok -eq 0 ] ; then
		echo "Error : $arg is not a valid CPU."
		echo "Valid CPU are : ${CPU_CPUS}"
		exit 1
	fi
	;;
	esac
done

if [ -z "$indices" ] ; then
	echo "No CPU to build."
	exit 1
fi

for i in $indices
do
	dir=$(echo $CPU_DIRS | cut -d ' ' -f $i)
	cpu=$(echo $CPU_CPUS | cut -d ' ' -f $i)
	opt=$(echo $CPU_OPTS | cut -d ' ' -f $i)

	simple_cpu=$(echo $cpu | cut -d '-' -f 1)

	if [ $clean -eq 0 ]; then
		multilib_opts="$(echo $CPU_OPTS | sed "s/${opt}//;" | xargs | tr ' ' '/') mshort"
		multilib_dirs="$(echo $CPU_DIRS | sed "s/${dir}//;" | xargs) mshort"
		${MAKE} TARGET=$target gcc-multilib-patch OPTS="$multilib_opts" DIRS="$multilib_dirs" || exit 1

		if [ $native_only -eq 0 ] ; then
			${MAKE} TARGET=$target gcc-gmp-patch CPU='$$1' || exit 1
			${MAKE} TARGET=$target binutils gcc-preliminary mintbin INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1

			# build mintlib and pml for all targets
			for j in $indices_all
			do
				target_dir=$(echo $CPU_DIRS | cut -d ' ' -f $j)
				prefix="$INSTALL_DIR/$dir/$target"
				if [ "$target_dir" = "$dir" ]
				then
					target_dir=""
				fi
				opts=$(echo $CPU_OPTS | cut -d ' ' -f $j)
				${MAKE} TARGET=$target mintlib prefix="$prefix" libdir="$prefix/lib/$target_dir" cflags="-$opts" INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
				${MAKE} TARGET=$target pml OPTS="-$opts" DIR="$target_dir" INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
			done
			${MAKE} TARGET=$target gcc INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
		fi

		if [ $skip_native -eq 0 ] ; then
			${MAKE} TARGET=$target binutils-atari INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" OPT="$opt" || exit 1
			${MAKE} TARGET=$target gcc-gmp-patch  CPU="$simple_cpu" || exit 1
			${MAKE} TARGET=$target gcc-atari      INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" OPT="$opt" || exit 1
		fi
	else
		if [ $native_only -eq 0 ] ; then
			${MAKE} TARGET=$target clean-cross CPU="$cpu" || exit 1
		fi

		if [ $skip_native -eq 0 ] ; then
			${MAKE} TARGET=$target clean-atari CPU="$cpu" || exit 1
		fi
	fi
done

if [ $skip_native -eq 0 ] && [ $clean -eq 0 ] ; then
	# use either 'strip'
	i=$(echo $indices | cut -d " " -f 1)
	dir=$(echo $CPU_DIRS | cut -d " " -f $i)
	${MAKE} TARGET=$target strip-atari INSTALL_DIR="$INSTALL_DIR/$dir"

	for i in $indices
	do
		cpu=$(echo $CPU_CPUS | cut -d ' ' -f $i)
		${MAKE} TARGET=$target pack-atari INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
	done

fi
