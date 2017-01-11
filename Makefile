# Atari cross- and native-binutils/gcc toolchain build Makefile
# Miro Kropacek aka MiKRO / Mystic Bytes
# miro.kropacek@gmail.com
# version 4.0.0 (2017/0x/0x)

# please note you need the bash shell for correct compilation of mintlib.

####################
# Global definitions
####################

TARGET			:= m68k-atari-mint
LIBC			:= mintlib
LIBM			:= pml

VERSION_BINUTILS	:= 2.26
VERSION_GCC		:= 4.6.4
VERSION_PML		:= 2.03
VERSION_MINTLIB		:= $(shell date +"%Y%m%d")

ifeq (${LIBC}, mintlib)
LIBC_TARGET = mintlib-CVS-${VERSION_MINTLIB}
#else
#ifeq (${LIBC}, libcmini)
#endif
endif

ifeq (${LIBM}, pml)
LIBM_TARGET = pml-${VERSION_PML}
#else
#ifeq (${LIBM}, fdlibm)
#endif
endif

# todo: nejako detekovat zmenu platformy... pri gcc/binutils touch ${TARGET}_source.ok a ak sa nenachadza, tak rm -rf
# detekovat, ci je platforma dobre definovana (na targets?)

# each platform target must provide:
# ${TARGET}-binutils-${VERSION_BINUTILS}-{download_patch, apply_patch}
# ${TARGET}-gcc-${VERSION_GCC}-{download_patch, apply_patch}
# ${TARGET}-{libc, libm}-{download, build}

#################
# m68k-atari-mint
#################

M68K_ATARI_MINT_PATCH_BINUTILS	= 20160320
M68K_ATARI_MINT_PATCH_GCC	= 20130415
M68K_ATARI_MINT_PATCH_PML	= 20110207

M68K_ATARI_MINT_VERSION_MINTBIN	= 20110527

# helper targets

${TARGET}/binutils-${VERSION_BINUTILS}-mint-${M68K_ATARI_MINT_PATCH_BINUTILS}.patch.bz2: ${TARGET}
	cd ${TARGET} && \
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$(notdir $@)

${TARGET}/gcc-${VERSION_GCC}-mint-${M68K_ATARI_MINT_PATCH_GCC}.patch.bz2: ${TARGET}
	cd ${TARGET} && \
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$(notdir $@)

${TARGET}/pml-${VERSION_PML}-mint-${M68K_ATARI_MINT_PATCH_PML}.patch.bz2:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$(notdir $@)

${TARGET}/mintbin-CVS-${VERSION_MINTBIN}.tar.gz: ${TARGET}
	cd ${TARGET} && \
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$(notdir $@)

${TARGET}/mintbin-CVS-${M68K_ATARI_MINT_VERSION_MINTBIN}.depacked: ${TARGET}/mintbin-CVS-${M68K_ATARI_MINT_VERSION_MINTBIN}.tar.gz ${TARGET}/mintbin.patch
	rm -rf $@ ${TARGET}/mintbin-CVS-${M68K_ATARI_MINT_VERSION_MINTBIN}
	cd ${TARGET} && \
	tar xzf mintbin-CVS-${M68K_ATARI_MINT_VERSION_MINTBIN}.tar.gz
	cd ${TARGET}/mintbin-CVS-${M68K_ATARI_MINT_VERSION_MINTBIN} && patch -p1 < ../mintbin.patch
	touch $@

# main targets

m68k-atari-mint-binutils-${VERSION_BINUTILS}-download_patch: ${TARGET}/binutils-${VERSION_BINUTILS}-mint-${M68K_ATARI_MINT_PATCH_BINUTILS}.patch.bz2

m68k-atari-mint-binutils-${VERSION_BINUTILS}-apply_patch: m68k-atari-mint-binutils-${VERSION_BINUTILS}-download_patch binutils-${VERSION_BINUTILS}.depacked
	cd binutils-${VERSION_BINUTILS} && bzcat ../${TARGET}/binutils-${VERSION_BINUTILS}-mint-${M68K_ATARI_MINT_PATCH_BINUTILS}.patch.bz2 | patch -p1

m68k-atari-mint-gcc-${VERSION_GCC}-download_patch: ${TARGET}/gcc-${VERSION_GCC}-mint-${M68K_ATARI_MINT_PATCH_GCC}.patch.bz2

m68k-atari-mint-gcc-${VERSION_GCC}-apply_patch: m68k-atari-mint-gcc-${VERSION_GCC}-download_patch gcc-${VERSION_GCC}.depacked
	cd gcc-${VERSION_GCC} && patch -p1 < ../gcc.patch
	cd gcc-${VERSION_GCC} && bzcat ../${TARGET}/gcc-${VERSION_GCC}-mint-${M68K_ATARI_MINT_PATCH_GCC}.patch.bz2 | patch -p1

DOWNLOADS = binutils-${VERSION_BINUTILS}.tar.bz2 gcc-${VERSION_GCC}.tar.bz2
	\

${TARGET}-DOWNLOADS:
	pml-${VERSION_PML}.tar.bz2 mintbin-CVS-${VERSION_MINTBIN}.tar.gz \
	pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2

################
# User interface
################

.PHONY: help download clean \
	clean-all       clean-all-skip-native       clean-native           all       all-skip-native       all-native \
	clean-m68000    clean-m68000-skip-native    clean-m68000-native    m68000    m68000-skip-native    m68000-native \
	clean-m68020-60 clean-m68020-60-skip-native clean-m68020-60-native m68020-60 m68020-60-skip-native m68020-60-native \
	clean-5475      clean-5475-skip-native      clean-5475-native      5475      5475-skip-native      5475-native

# display help

help: ./build.sh
	@echo "Makefile targets :"
	@echo "    download"
	@echo "    clean (same as clean-all)"
	@echo "    [clean-]all       / [clean-]all[-skip]-native"
	@echo "    [clean-]m68000    / [clean-]m68000[-skip]-native"
	@echo "    [clean-]m68020-60 / [clean-]m68020-60[-skip]-native"
	@echo "    [clean-]5475      / [clean-]5475[-skip]-native"

# "real" targets

all: ./build.sh download
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --all

all-skip-native: ./build.sh download
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --all --skip-native

all-native: ./build.sh download
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --all --native-only

m68000: ./build.sh download
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< m68000

m68000-skip-native: ./build.sh download
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --skip-native m68000

m68000-native: ./build.sh download
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --native-only m68000

m68020-60: ./build.sh download
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< m68020-60

m68020-60-skip-native: ./build.sh download
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --skip-native m68020-60

m68020-60-native: ./build.sh download
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --native-only m68020-60

5475: ./build.sh download
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< 5475

5475-skip-native: ./build.sh download
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --skip-native 5475

5475-native: ./build.sh download
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --native-only 5475

clean: clean-all

clean-all: ./build.sh clean-source
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --clean --all

clean-all-skip-native: ./build.sh clean-source
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --clean --all --skip-native

clean-all-native: ./build.sh clean-source
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --clean --all --native-only

clean-m68000: ./build.sh clean-source
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --clean m68000

clean-m68000-skip-native: ./build.sh clean-source
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --clean --skip-native m68000

clean-m68000-native: ./build.sh clean-source
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --clean --native-only m68000

clean-m68020-60: ./build.sh clean-source
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --clean m68020-60

clean-m68020-60-skip-native: ./build.sh clean-source
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --clean --skip-native m68020-60

clean-m68020-60-native: ./build.sh clean-source
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --clean --native-only m68020-60

clean-5475: ./build.sh clean-source
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --clean 5475

clean-5475-skip-native: ./build.sh clean-source
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --clean --skip-native 5475

clean-5475-native: ./build.sh clean-source
	PLATFORM=$(TARGET) MAKE=$(MAKE) $(SH) $< --clean --native-only 5475

download: $(DOWNLOADS) m68k-atari-mint-binutils-${VERSION_BINUTILS}-download_patch

# Target definitions for every new platform (m68k-linux-gnu for instance)
# right now we don't support building of more than one targets in one go so don't forget 'make clean-source'
# to be sure a fresh copy of binutils and gcc is used (and possibly patched)

.PHONY: binutils-m68k-atari-mint gcc-m68k-atari-mint libc-m68k-atari-mint gmp-m68k-atari-mint mpfr-m68k-atari-mint mpc-m68k-atari-mint

binutils-m68k-atari-mint: binutils-${VERSION_BINUTILS}.ok

gcc-m68k-atari-mint: gcc-${VERSION_GCC}.ok

libc-m68k-atari-mint: pml-${VERSION_PML}.ok mintbin-CVS-${VERSION_MINTBIN}.ok mintlib-CVS-${VERSION_MINTLIB}.ok

##############
# Shared rules
##############

ifndef (${LIBC_TARGET})
	$(error Please add LIBC_TARGET rules for ${LIBC})
endif
ifndef (${LIBM_TARGET})
	$(error Please add LIBM_TARGET rules for ${LIBM})
endif

# Download source archives

binutils-${VERSION_BINUTILS}.tar.bz2:
	$(URLGET) http://ftp.gnu.org/gnu/binutils/$@

gcc-${VERSION_GCC}.tar.bz2:
	$(URLGET) http://ftp.gnu.org/gnu/gcc/gcc-${VERSION_GCC}/$@

pml-${VERSION_PML}.tar.bz2:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$@

# Depack

binutils-${VERSION_BINUTILS}.depacked: binutils-${VERSION_BINUTILS}.tar.bz2
	rm -rf $@ binutils-${VERSION_BINUTILS}
	tar xjf binutils-${VERSION_BINUTILS}.tar.bz2
	touch $@

gcc-${VERSION_GCC}.depacked: gcc-${VERSION_GCC}.tar.bz2
	rm -rf $@ gcc-${VERSION_GCC}
	tar xjf gcc-${VERSION_GCC}.tar.bz2
	touch $@

mintlib-CVS-${VERSION_MINTLIB}.depacked:
	rm -rf $@ ${TARGET}/mintlib-CVS-${VERSION_MINTLIB}
	CVSROOT=:pserver:cvsanon:cvsanon@sparemint.org:/mint cvs checkout -d mintlib-CVS-${VERSION_MINTLIB} mintlib $(OUT)
	touch $@

pml-${VERSION_PML}.depacked: pml-${VERSION_PML}.tar.bz2
	rm -rf $@ pml-${VERSION_PML}
	tar xjf pml-${VERSION_PML}.tar.bz2
	touch $@

# Patch for given platform

binutils-${VERSION_BINUTILS}.patched: binutils-${VERSION_BINUTILS}.depacked ${TARGET}-binutils-${VERSION_BINUTILS}-apply_patch
	touch $@

gcc-${VERSION_GCC}.patched: gcc-${VERSION_GCC}.depacked ${TARGET}-gcc-${VERSION_GCC}-apply_patch
	touch $@

mintlib-CVS-${VERSION_MINTLIB}.patched: mintlib-CVS-${VERSION_MINTLIB}.depacked ${TARGET}-mintlib-CVS-${VERSION_MINTLIB}-apply_patch
	touch $@

pml-${VERSION_PML}.patched: pml-${VERSION_PML}.depacked ${TARGET}-pml-${VERSION_PML}-apply_patch
	touch $@

# Shortcuts (called from build.sh)

binutils: binutils-${VERSION_BINUTILS}-${CPU}-cross

gcc-preliminary: gcc-${VERSION_GCC}-${CPU}-cross-preliminary

libc: ${LIBC_TARGET}.built

libm: ${LIBM_TARGET}.built

gcc: gcc-${VERSION_GCC}-${CPU}-cross-final

misc: ${TARGET}-misc.built

# Build

binutils-${VERSION_BINUTILS}-${CPU}-cross: binutils-${VERSION_BINUTILS}.patched
	mkdir -p $@
	cd $@ && PATH=${INSTALL_DIR}/bin:$$PATH ../binutils-${VERSION_BINUTILS}/configure --target=${TARGET} --prefix=${INSTALL_DIR} --disable-nls --disable-werror
	cd $@ && $(MAKE) -j3 $(OUT)
	cd $@ && $(MAKE) install-strip $(OUT)

gcc-multilib-patch: gcc-${VERSION_GCC}.patched
	sed -e "s:\(MULTILIB_OPTIONS =\).*:\1 ${OPTS}:" -e "s:\(MULTILIB_DIRNAMES =\).*:\1 ${DIRS}:" gcc-${VERSION_GCC}/gcc/config/m68k/t-mint > t-mint.patched
	mv t-mint.patched gcc-${VERSION_GCC}/gcc/config/m68k/t-mint

gcc-${VERSION_GCC}-${CPU}-cross-preliminary: gcc-${VERSION_GCC}.patched
	mkdir -p $@
	ln -sfv . ${INSTALL_DIR}/${TARGET}/usr
	cd $@ && PATH=${INSTALL_DIR}/bin:$$PATH ../gcc-${VERSION_GCC}/configure \
		--prefix=${INSTALL_DIR} \
		--target=${TARGET} \
		--with-sysroot=${INSTALL_DIR}/${TARGET} \
		--disable-nls \
		--disable-shared \
		--without-headers \
		--with-newlib \
		--disable-decimal-float \
		--disable-libgomp \
		--disable-libmudflap \
		--disable-libssp \
		--disable-libatomic \
		--disable-libquadmath \
		--disable-threads \
		--enable-languages=c \
		--disable-multilib \
		--disable-libstdcxx-pch
	cd $@ && $(MAKE) -j3 all-gcc all-target-libgcc $(OUT)
	cd $@ && $(MAKE) install-gcc install-target-libgcc $(OUT)

mintlib: libc-${TARGET}
	cd mintlib-CVS-${VERSION_MINTLIB} && $(MAKE) OUT= clean $(OUT)
	cd mintlib-CVS-${VERSION_MINTLIB} && PATH=${INSTALL_DIR}/bin:$$PATH \
		$(MAKE) SHELL=$(BASH) CROSS=yes WITH_020_LIB=no WITH_V4E_LIB=no CC="${TARGET}-gcc" HOST_CC="$(CC)" OUT= $(OUT)
	cd mintlib-CVS-${VERSION_MINTLIB} && PATH=${INSTALL_DIR}/bin:$$PATH \
		$(MAKE) SHELL=$(BASH) CROSS=yes WITH_020_LIB=no WITH_V4E_LIB=no OUT= install $(OUT)

mintbin: libc-${TARGET}
	cd mintbin-CVS-${VERSION_MINTBIN} && PATH=${INSTALL_DIR}/bin:$$PATH ./configure --target=${TARGET} --prefix=${INSTALL_DIR} --disable-nls
	cd mintbin-CVS-${VERSION_MINTBIN} && $(MAKE) OUT= $(OUT)
	cd mintbin-CVS-${VERSION_MINTBIN} && $(MAKE) OUT= install $(OUT)
	mv -v ${INSTALL_DIR}/${TARGET}/bin/${TARGET}-* ${INSTALL_DIR}/bin

pml: libc-${TARGET}
	cd pml-${VERSION_PML}/pmlsrc && $(MAKE) clean LIB="$(DIR)" $(OUT)
	cd pml-${VERSION_PML}/pmlsrc && PATH=${INSTALL_DIR}/bin:$$PATH \
	$(MAKE) AR="${TARGET}-ar" CC="${TARGET}-gcc" CPU="$(OPTS)" CROSSDIR="${INSTALL_DIR}/${TARGET}" LIB="$(DIR)" $(OUT)
	cd pml-${VERSION_PML}/pmlsrc && PATH=${INSTALL_DIR}/bin:$$PATH \
	$(MAKE) install AR="${TARGET}-ar" CC="${TARGET}-gcc" CPU="$(OPTS)" CROSSDIR="${INSTALL_DIR}/${TARGET}" LIB="$(DIR)" $(OUT)

gcc-${VERSION_GCC}-${CPU}-cross-final: ${INSTALL_DIR}/${TARGET}/lib/libc.a ${INSTALL_DIR}/${TARGET}/lib/libm.a
	mkdir -p $@
	cd $@ && PATH=${INSTALL_DIR}/bin:$$PATH ../gcc-${VERSION_GCC}/configure \
		--prefix=${INSTALL_DIR} \
		--target=${TARGET} \
		--with-sysroot=${INSTALL_DIR}/${TARGET} \
		--disable-nls \
		--enable-languages=c,c++ \
		--enable-c99 \
		--enable-long-long \
		--disable-libstdcxx-pch \
		CFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" CXXFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" --with-cpu=${CPU}
	cd $@ && $(MAKE) -j3 $(OUT)
	cd $@ && $(MAKE) install-strip $(OUT)

##############
# Native build
##############

binutils-${VERSION_BINUTILS}-${CPU}-atari: binutils-${TARGET}
	mkdir -p $@
	cd $@ && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../binutils-${VERSION_BINUTILS}/configure --target=${TARGET} --host=${TARGET} --disable-nls --prefix=/usr CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	$(MAKE) $(OUT) && \
	$(MAKE) install DESTDIR=${PWD}/binary-package/${CPU}/binutils-${VERSION_BINUTILS}	# make install-strip doesn't work properly

binutils-atari: binutils-${VERSION_BINUTILS}-${CPU}-atari

gcc-${VERSION_GCC}-${CPU}-atari: gcc-${TARGET}
	mkdir -p $@
	cd $@ && PATH=${INSTALL_DIR}/bin:$$PATH ../gcc-${VERSION_GCC}/configure \
		--prefix=/usr \
		--host=${TARGET} \
		--target=${TARGET} \
		--disable-nls \
		--enable-languages="c,c++" \
		--enable-c99 \
		--enable-long-long \
		--disable-libstdcxx-pch \
		CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" --with-cpu=${CPU}
	cd $@ && $(MAKE) -j3 $(OUT)
	cd $@ && $(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC} $(OUT)

gcc-atari: gcc-${VERSION_GCC}-${CPU}-atari

# Cleaning

clean-source:
	rm -rf binutils-${VERSION_BINUTILS}
	rm -rf gcc-${VERSION_GCC}
	for dir in $$(ls | grep mintlib-CVS-????????); \
	do \
		rm -rf $$dir; \
	done
	rm -rf pml-${VERSION_PML}
	rm -rf mintbin-CVS-${VERSION_MINTBIN}
	rm -f *.ok
	rm -f *~

clean-cross:
	rm -rf binutils-${VERSION_BINUTILS}-${CPU}-cross
	rm -rf gcc-${VERSION_GCC}-${CPU}-cross-preliminary
	rm -rf gcc-${VERSION_GCC}-${CPU}-cross-final

pack-atari:
	for dir in binutils-${VERSION_BINUTILS} gcc-${VERSION_GCC}; \
	do \
		cd ${PWD}/binary-package/${CPU}/$$dir && tar cjf ../$$dir-${CPU}mint.tar.bz2 usr && cd ..; \
	done

strip-atari:
	find ${PWD}/binary-package -type f -perm -a=x -exec ${TARGET}-strip -s {} \;
	find ${PWD}/binary-package -type f -name '*.a' -exec ${TARGET}-strip -S -X -w -N '.L[0-9]*' {} \;

clean-atari:
	rm -rf binutils-${VERSION_BINUTILS}-${CPU}-atari
	rm -rf gcc-${VERSION_GCC}-${CPU}-atari
	rm -rf binary-package

# setup

SH	= $(shell which sh)
BASH	= $(shell which bash)
URLGET	= $(shell which wget || echo "`which curl` -O")

# set to something like "> /dev/null" or ">> /tmp/mint-build.log"
# to redirect compilation standard output
OUT =
