# -*-makefile-*-
#
# Copyright (C) 2004 by Ladislav Michl
#               2009 by Juergen Beisert <j.beisert@pengtronix.de>
#               2009 by Erwin Rol <erwin@erwinrol.com>
#               2010, 2012 by Marc Kleine-Budde <mkl@pengutronix.de>
#               2011 by Markus Rathgeb <rathgeb.markus@googlemail.com>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_SQLITE) += sqlite

#
# Paths and names
#
SQLITE_VERSION	:= 3071502
SQLITE_MD5	:= bcb0ab0b5b30116b2531cfeef3c861b4
SQLITE		:= sqlite-autoconf-$(SQLITE_VERSION)
SQLITE_SUFFIX	:= tar.gz
SQLITE_URL	:= http://www.sqlite.org/$(SQLITE).$(SQLITE_SUFFIX)
SQLITE_SOURCE	:= $(SRCDIR)/$(SQLITE).$(SQLITE_SUFFIX)
SQLITE_DIR	:= $(BUILDDIR)/$(SQLITE)
SQLITE_LICENSE	:= public_domain

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

SQLITE_CONF_ENV := \
	CPPFLAGS=" \
	-DSQLITE_ENABLE_COLUMN_METADATA \
	-DSQLITE_ENABLE_FTS3 \
	-DSQLITE_ENABLE_RTREE=1 \
	-DSQLITE_ENABLE_UNLOCK_NOTIFY \
	-DSQLITE_ENABLE_UPDATE_DELETE_LIMIT=1\
	-DSQLITE_OMIT_LOOKASIDE=1 \
	-DSQLITE_SECURE_DELETE \
	-DSQLITE_SOUNDEX=1 \
	" \
	LD="sh4-linux-ld"

SQLITE_AUTOCONF	:= \
	$(CROSS_AUTOCONF_USR) \
	$(GLOBAL_LARGE_FILE_OPTION) \
	--disable-static \
	--enable-shared

ifdef PTXCONF_SQLITE_THREADSAFE
SQLITE_AUTOCONF += --enable-threadsafe
else
SQLITE_AUTOCONF += --disable-threadsafe
endif

ifdef PTXCONF_SQLITE_LOAD_EXTENTION
SQLITE_AUTOCONF += --enable-dynamic-extensions
else
SQLITE_AUTOCONF += --disable-dynamic-extensions
endif

ifdef PTXCONF_SQLITE_READLINE
SQLITE_AUTOCONF += --enable-readline
else
SQLITE_AUTOCONF += --disable-readline
endif

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/sqlite.targetinstall:
	@$(call targetinfo)

	@$(call install_init, sqlite)
	@$(call install_fixup, sqlite,PRIORITY,optional)
	@$(call install_fixup, sqlite,SECTION,base)
	@$(call install_fixup, sqlite,AUTHOR,"Ladislav Michl <ladis@linux-mips.org>")
	@$(call install_fixup, sqlite,DESCRIPTION,missing)

	@$(call install_lib, sqlite, 0, 0, 0644, libsqlite3)

ifdef PTXCONF_SQLITE_TOOL
	@$(call install_copy, sqlite, 0, 0, 0755, -, /usr/bin/sqlite3)
endif

	@$(call install_finish, sqlite)

	@$(call touch)

# vim: syntax=make
