# libde265

LIBDE265_VERSION := 1.0.2
LIBDE265_URL := https://github.com/strukturag/libde265/releases/download/v$(LIBDE265_VERSION)/libde265-$(LIBDE265_VERSION).tar.gz

PKGS += libde265
ifeq ($(call need_pkg,"libde265 >= 1.0.2"),)
PKGS_FOUND += libde265
endif

$(TARBALLS)/libde265-$(LIBDE265_VERSION).tar.gz:
	$(call download,$(LIBDE265_URL))

.sum-libde265: libde265-$(LIBDE265_VERSION).tar.gz

libde265: libde265-$(LIBDE265_VERSION).tar.gz .sum-libde265
	$(UNPACK)
	$(MOVE)

.libde265: libde265
ifdef HAVE_MACOSX
	cd $< && cp ../../src/libde265/libde265_osx.diff ./libde265_osx.diff && patch -p1 < libde265_osx.diff 
	cd $< && ./autogen.sh
endif
	cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) -O3" CXXFLAGS="$(CXXFLAGS) -O3" ./configure $(HOSTCONF) --disable-dec265 --disable-sherlock265
	cd $< && $(MAKE) install
	touch $@
