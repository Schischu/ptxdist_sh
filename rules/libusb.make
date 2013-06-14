# -*-makefile-*-
#
# Copyright (C) 2009 by Juergen Beisert
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_LIBUSB) += libusb

#
# Paths and names
#
LIBUSB_VERSION	:= 1.0.9
LIBUSB_MD5	:= 7f5a02375ad960d4e33a6dae7d63cfcb
LIBUSB		:= libusb-$(LIBUSB_VERSION)
LIBUSB_SUFFIX	:= tar.bz2
LIBUSB_URL	:= $(call ptx/mirror, SF, libusb/$(LIBUSB_VERSION)/$(LIBUSB).$(LIBUSB_SUFFIX))
LIBUSB_SOURCE	:= $(SRCDIR)/$(LIBUSB).$(LIBUSB_SUFFIX)
LIBUSB_DIR	:= $(BUILDDIR)/$(LIBUSB)
LIBUSB_LICENSE	:= LGPLv2.1

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

LIBUSB_PATH	:= PATH=$(CROSS_PATH)
LIBUSB_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
LIBUSB_AUTOCONF := \
	$(CROSS_AUTOCONF_USR) \
	--disable-log \
	--disable-debug-log \
	--disable-examples-build \
	--enable-static \
	--enable-shared \
	--$(call ptx/endis, PTXCONF_LIBUSB_DISABLE_LOG)-log

ifdef PTXCONF_LIBUSB_DEBUG_LOG
LIBUSB_AUTOCONF += --enable-debug-log
endif

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/libusb.targetinstall:
	@$(call targetinfo)

	@$(call install_init, libusb)
	@$(call install_fixup, libusb,PRIORITY,optional)
	@$(call install_fixup, libusb,SECTION,base)
	@$(call install_fixup, libusb,AUTHOR,"Juergen Beisert <juergen@kreuzholzen.de>")
	@$(call install_fixup, libusb,DESCRIPTION,missing)

	@$(call install_lib, libusb, 0, 0, 0644, libusb-1.0)

	@$(call install_finish, libusb)

	@$(call touch)

# vim: syntax=make
