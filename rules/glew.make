# -*-makefile-*-
#
# Copyright (C) 2010 by Erwin Rol <erwin@erwinrol.com>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_GLEW) += glew

#
# Paths and names
#
GLEW_VERSION	:= 1.10.0
GLEW_MD5	:= 2f09e5e6cb1b9f3611bcac79bc9c2d5d
GLEW		:= glew-$(GLEW_VERSION)
GLEW_SUFFIX	:= tgz
GLEW_URL	:= $(call ptx/mirror, SF, glew/$(GLEW_VERSION)/$(GLEW).$(GLEW_SUFFIX))
GLEW_SOURCE	:= $(SRCDIR)/$(GLEW).$(GLEW_SUFFIX)
GLEW_DIR	:= $(BUILDDIR)/$(GLEW)
GLEW_LICENSE	:= unknown

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

GLEW_CONF_TOOL	:= NO

#
# The makefile expects ld == gcc, so we set the tools
# seperately and not use the CROSS_TOOLS variable
#
GLEW_MAKE_OPT	:= \
	$(CROSS_ENV_CC) \
	$(CROSS_ENV_AR) \
	LD=$(CROSS_CC) \
	CFLAGS.EXTRA='' \
	LDFLAGS.EXTRA='' \
	LDFLAGS.GL='-lGL -lX11' \
	GLEW_DEST=$(GLEW_PKGDIR)/usr \
	LIBDIR=$(GLEW_PKGDIR)/usr/lib \
	M_ARCH=$(PTXCONF_ARCH_STRING)

GLEW_INSTALL_OPT := \
	$(GLEW_MAKE_OPT) \
	install

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/glew.targetinstall:
	@$(call targetinfo)

	@$(call install_init, glew)
	@$(call install_fixup, glew,PRIORITY,optional)
	@$(call install_fixup, glew,SECTION,base)
	@$(call install_fixup, glew,AUTHOR,"Erwin Rol <erwin@erwinrol.com>")
	@$(call install_fixup, glew,DESCRIPTION,missing)

	@$(call install_lib, glew, 0, 0, 0644, libGLEW)

	@$(call install_finish, glew)

	@$(call touch)

# vim: syntax=make
