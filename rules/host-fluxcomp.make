# -*-makefile-*-
#
# Copyright (C) 2008 by mol@pengutronix.de
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
HOST_PACKAGES-$(PTXCONF_HOST_FLUXCOMP) += host-fluxcomp
#
# Paths and names
#
HOST_FLEX_DIR		= $(HOST_BUILDDIR)/$(FLUXCOMP)
# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/host-fluxcomp.extract:
	@$(call targetinfo)
	@$(call clean, $(HOST_FLUXCOMP_DIR))
	@$(call extract, HOST_FLUXCOMP)

	@$(call patchin, HOST_FLUXCOMP)

	cd $(HOST_FLUXCOMP_DIR) && [ -f configure ] || sh autogen.sh
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#
# autoconf
#
HOST_FLUXCOMP_CONF_TOOL	:= autoconf
HOST_FLUXCOMP_CONF_OPT	= \
	$(HOST_AUTOCONF) \
	$(FLUXCOMP_AUTOCONF_SHARED)

$(STATEDIR)/host-fluxcomp.compile:
	@$(call targetinfo)

	cd $(HOST_FLUXCOMP_DIR) && $(HOST_FLUXCOMP_PATH) $(HOST_FLUXCOMP_CONF_ENV) \
		$(MAKE) $(PARALLELMFLAGS_BROKEN) $(HOST_FLUXCOMP_MAKEVARS) all
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/host-fluxcomp.install:
	@$(call targetinfo)
	@$(call world/install, HOST_FLUXCOMP)
#	# don't install headers, so packages like the kernel don't use it
	@rm -r $(HOST_FLUXCOMP_PKGDIR)/include
	@$(call touch)

# vim: syntax=make
