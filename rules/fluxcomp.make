# -*-makefile-*-
#
# Copyright (C) 2009 by Marc Kleine-Budde <mkl@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_FLUXCOMP) += fluxcomp

#
# Paths and names
#
FLUXCOMP_VERSION	:= f4ebde5d16ea1cba3e16e1ec3a1cf51a40c77eea
FLUXCOMP		:= fluxcomp-$(FLUXCOMP_VERSION)
FLUXCOMP_URL	:= git://git.directfb.org/git/directfb/core/flux
FLUXCOMP_BRANCH := master
FLUXCOMP_GIT_HEAD := $(FLUXCOMP_VERSION)
FLUXCOMP_SOURCE	:= $(SRCDIR)/flux.git
FLUXCOMP_DIR	:= $(BUILDDIR)/$(FLUXCOMP)
FLUXCOMP_LICENSE	:= unknown

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/fluxcomp.extract:
	@$(call targetinfo)
	@$(call clean, $(FLUXCOMP_DIR))
	@$(call extract, FLUXCOMP)

	@$(call patchin, FLUXCOMP)

	cd $(FLUXCOMP_DIR) && [ -f configure ] || sh autogen.sh
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

FLUXCOMP_PATH	:= PATH=$(CROSS_PATH)
FLUXCOMP_ENV 	:= $(CROSS_ENV)

#
# autoconf
#
FLUXCOMP_AUTOCONF := $(CROSS_AUTOCONF_USR)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/fluxcomp.targetinstall:
	@$(call targetinfo)

	@$(call install_init,  fluxcomp)
	@$(call install_fixup, fluxcomp,PRIORITY,optional)
	@$(call install_fixup, fluxcomp,SECTION,base)
	@$(call install_fixup, fluxcomp,AUTHOR,"Marc Kleine-Budde <mkl@pengutronix.de>")
	@$(call install_fixup, fluxcomp,DESCRIPTION,missing)

#
# HACK:
#
# we need a ipkg, because some packages may depend on us, e.g.:
# "at"
#
# because we don't provide any shared libraries,
# we just put an existing dir into the package
#
#	@$(call install_copy, fluxcomp, 0, 0, 0755, /usr/sbin)

#	@$(call install_finish, fluxcomp)

	@$(call touch)

# vim: syntax=make
