# -*-makefile-*-
#
# Copyright (C) 2011 by Juergen Beisert <jbe@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_EVTEST) += evtest

#
# Paths and names
#
EVTEST_VERSION	:= 1.25
EVTEST_MD5	:= 770d6af03affe976bdbe3ad1a922c973
EVTEST		:= evtest-$(EVTEST_VERSION)
EVTEST_SUFFIX	:= tar.bz2
EVTEST_URL	:= http://enialis.net/~jrd/salix/evtest/1.25-i486-1cp/$(EVTEST).$(EVTEST_SUFFIX)
EVTEST_SOURCE	:= $(SRCDIR)/$(EVTEST).$(EVTEST_SUFFIX)
EVTEST_DIR	:= $(BUILDDIR)/$(EVTEST)
EVTEST_LICENSE	:= GPLv2

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

EVTEST_CONF_ENV := $(CROSS_ENV)

# disable pkg-config so that libxml2 is never found
ifndef PTXCONF_EVTEST_CAPTURE
EVTEST_CONF_ENV += PKG_CONFIG=false
endif

#
# autoconf
#
EVTEST_CONF_TOOL	:= autoconf

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/evtest.targetinstall:
	@$(call targetinfo)

	@$(call install_init, evtest)
	@$(call install_fixup, evtest,PRIORITY,optional)
	@$(call install_fixup, evtest,SECTION,base)
	@$(call install_fixup, evtest,AUTHOR,"Juergen Beisert <jbe@pengutronix.de>")
	@$(call install_fixup, evtest,DESCRIPTION,missing)

ifdef PTXCONF_EVTEST_EVTEST
	@$(call install_copy, evtest, 0, 0, 0755, -, /usr/bin/evtest)
endif

ifdef PTXCONF_EVTEST_CAPTURE
	@$(call install_copy, evtest, 0, 0, 0755, -, /usr/bin/evtest-capture)
	@$(call install_copy, evtest, 0, 0, 0755, -, \
		/usr/share/evtest/evtest-create-device.xsl)
endif

	@$(call install_finish, evtest)

	@$(call touch)

# vim: syntax=make
