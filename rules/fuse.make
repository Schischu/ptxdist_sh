# -*-makefile-*-
#
# Copyright (C) 2007 by Luotao Fu <lfu@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_FUSE) += fuse

#
# Paths and names
#
FUSE_VERSION	:= 2.9.3
FUSE_MD5	:= 33cae22ca50311446400daf8a6255c6a
FUSE		:= fuse-$(FUSE_VERSION)
FUSE_SUFFIX	:= tar.gz
FUSE_URL	:= $(call ptx/mirror, SF, fuse/$(FUSE).$(FUSE_SUFFIX))
FUSE_SOURCE	:= $(SRCDIR)/$(FUSE).$(FUSE_SUFFIX)
FUSE_DIR	:= $(BUILDDIR)/$(FUSE)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

FUSE_PATH	:= PATH=$(CROSS_PATH)
FUSE_ENV	:= $(CROSS_ENV)

#
# autoconf
#
# don't use := here
#
FUSE_AUTOCONF = \
	$(CROSS_AUTOCONF_USR) \
	--disable-example \
	--disable-mtab \
	--disable-rpath \
	--without-libiconv-prefix \
	--$(call ptx/endis, PTXCONF_FUSE__LIB)-lib \
	--$(call ptx/endis, PTXCONF_FUSE__UTIL)-util

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/fuse.targetinstall:
	@$(call targetinfo)

	@$(call install_init, fuse)
	@$(call install_fixup, fuse,PRIORITY,optional)
	@$(call install_fixup, fuse,SECTION,base)
	@$(call install_fixup, fuse,AUTHOR,"Robert Schwebel <r.schwebel@pengutronix.de>")
	@$(call install_fixup, fuse,DESCRIPTION,missing)

ifdef PTXCONF_FUSE__LIB
	@$(call install_lib, fuse, 0, 0, 0644, libfuse)
	@$(call install_lib, fuse, 0, 0, 0644, libulockmgr)
endif
ifdef PTXCONF_FUSE__UTIL
	@$(call install_copy, fuse, 0, 0, 0755, -, /usr/bin/fusermount)
	@$(call install_copy, fuse, 0, 0, 0755, -, /usr/bin/ulockmgr_server)
endif
	@$(call install_finish, fuse)

	@$(call touch)

# vim: syntax=make
