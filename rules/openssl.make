# -*-makefile-*-
#
# Copyright (C) 2002 by Jochen Striepe for Pengutronix e.K., Hildesheim, Germany
#               2003-2008 by Pengutronix e.K., Hildesheim, Germany
#		2009 by Marc Kleine-Budde <mkl@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_OPENSSL) += openssl

#
# Paths and names
#
OPENSSL_VERSION	:= 1.0.0j
OPENSSL_MD5	:= cbe4ac0d8f598680f68a951e04b0996b
OPENSSL		:= openssl-$(OPENSSL_VERSION)
OPENSSL_SUFFIX	:= tar.gz
OPENSSL_URL	:= http://openssl.org/source//$(OPENSSL).$(OPENSSL_SUFFIX)
OPENSSL_SOURCE	:= $(SRCDIR)/$(OPENSSL).$(OPENSSL_SUFFIX)
OPENSSL_DIR	:= $(BUILDDIR)/$(OPENSSL)
OPENSSL_LICENSE	:= openssl

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

OPENSSL_CONF_ENV 	:= $(CROSS_ENV)
OPENSSL_MAKE_PAR := NO

OPENSSL_ARCH-$(PTXCONF_ARCH_X86_I386)	+= debian-i386
OPENSSL_ARCH-$(PTXCONF_ARCH_X86_I486)	+= debian-i386-i486
OPENSSL_ARCH-$(PTXCONF_ARCH_X86_I586)	+= debian-i386-i586
OPENSSL_ARCH-$(PTXCONF_ARCH_X86_I686)	+= debian-i386-i686/cmov
OPENSSL_ARCH-$(PTXCONF_ARCH_X86_P2)	+= debian-i386-i686/cmov
OPENSSL_ARCH-$(PTXCONF_ARCH_X86_P3M)	+= debian-i386-i686/cmov
OPENSSL_ARCH-$(PTXCONF_ARCH_M68K)	+= debian-m68k
OPENSSL_ARCH-$(PTXCONF_ARCH_PPC)	+= debian-powerpc
OPENSSL_ARCH-$(PTXCONF_ARCH_SPARC)	+= debian-sparc

ifdef PTXCONF_ENDIAN_LITTLE
OPENSSL_ARCH-$(PTXCONF_ARCH_ARM)	+= debian-armel
OPENSSL_ARCH-$(PTXCONF_ARCH_MIPS)	+= debian-mipsel
OPENSSL_ARCH-$(PTXCONF_ARCH_SH_SH3)	+= debian-sh3
OPENSSL_ARCH-$(PTXCONF_ARCH_SH_SH4)	+= debian-sh4
else
OPENSSL_ARCH-$(PTXCONF_ARCH_ARM)	+= debian-armeb
OPENSSL_ARCH-$(PTXCONF_ARCH_MIPS)	+= debian-mips
OPENSSL_ARCH-$(PTXCONF_ARCH_SH_SH3)	+= debian-sh3eb
OPENSSL_ARCH-$(PTXCONF_ARCH_SH_SH4)	+= debian-sh4eb
endif

ifdef PTXCONF_OPENSSL
ifndef OPENSSL_ARCH-y
$(error *** Sorry unsupported ARCH in openssl.make)
endif
endif


#
# autoconf
#
OPENSSL_CONF_OPT := \
	--prefix=/usr \
	--openssldir=/usr/lib/ssl \
	--install_prefix=$(OPENSSL_PKGDIR)
OPENSSL_INSTALL_OPT := \
	install_sw

ifdef PTXCONF_OPENSSL_SHARED
OPENSSL_CONF_OPT += shared
else
OPENSSL_CONF_OPT += no-shared
endif

$(STATEDIR)/openssl.prepare:
	@$(call targetinfo)
	cd $(OPENSSL_DIR) && \
		$(OPENSSL_PATH) $(OPENSSL_CONF_ENV) \
		./Configure $(OPENSSL_ARCH-y) $(OPENSSL_CONF_OPT)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/openssl.targetinstall:
	@$(call targetinfo)

	@$(call install_init, openssl)
	@$(call install_fixup, openssl,PRIORITY,optional)
	@$(call install_fixup, openssl,SECTION,base)
	@$(call install_fixup, openssl,AUTHOR,"Marc Kleine-Budde <mkl@pengutronix.de>")
	@$(call install_fixup, openssl,DESCRIPTION,missing)

ifdef PTXCONF_OPENSSL_BIN
	@$(call install_copy, openssl, 0, 0, 0755, -, \
		/usr/bin/openssl)
endif
ifdef PTXCONF_OPENSSL_SHARED
	@$(call install_lib, openssl, 0, 0, 0644, libssl)
	@$(call install_lib, openssl, 0, 0, 0644, libcrypto)
endif
	@$(call install_finish, openssl)

	@$(call touch)

# vim: syntax=make
