# -*-makefile-*-
#
# Copyright (C) 2003-2006 by Robert Schwebel <r.schwebel@pengutronix.de>
#               2009, 2010 by Marc Kleine-Budde <mkl@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_FREETYPE) += freetype

#
# Paths and names
#
FREETYPE_VERSION	:= 2.4.11
FREETYPE_MD5		:= b93435488942486c8d0ca22e8f768034
FREETYPE		:= freetype-$(FREETYPE_VERSION)
FREETYPE_SUFFIX		:= tar.bz2
FREETYPE_SOURCE		:= $(SRCDIR)/$(FREETYPE).$(FREETYPE_SUFFIX)
FREETYPE_DIR		:= $(BUILDDIR)/$(FREETYPE)
FREETYPE_LICENSE	:= BSD,GPLv2+

FREETYPE_URL := \
	http://download.savannah.gnu.org/releases/freetype/$(FREETYPE).$(FREETYPE_SUFFIX) \
	http://download.savannah.gnu.org/releases/freetype/freetype-old/$(FREETYPE).$(FREETYPE_SUFFIX)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

FREETYPE_PATH	:= PATH=$(CROSS_PATH)
FREETYPE_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
FREETYPE_AUTOCONF := $(CROSS_AUTOCONF_USR)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/freetype.targetinstall:
	@$(call targetinfo)

	@$(call install_init, freetype)
	@$(call install_fixup, freetype,PRIORITY,optional)
	@$(call install_fixup, freetype,SECTION,base)
	@$(call install_fixup, freetype,AUTHOR,"Robert Schwebel <r.schwebel@pengutronix.de>")
	@$(call install_fixup, freetype,DESCRIPTION,missing)

	@$(call install_lib, freetype, 0, 0, 0644, libfreetype)

	@$(call install_finish, freetype)

	@$(call touch)

# vim: syntax=make
