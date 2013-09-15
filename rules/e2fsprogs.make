# -*-makefile-*-
#
# Copyright (C) 2002-2008 by Pengutronix e.K., Hildesheim, Germany
#               2009 by Marc Kleine-Budde <mkl@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_E2FSPROGS) += e2fsprogs

#
# Paths and names
#
E2FSPROGS_VERSION	:= 1.42.7
E2FSPROGS_MD5		:= a1ec22ef003688dae9f76c74881b22b9
E2FSPROGS		:= e2fsprogs-$(E2FSPROGS_VERSION)
E2FSPROGS_SUFFIX	:= tar.gz
E2FSPROGS_URL		:= $(call ptx/mirror, SF, e2fsprogs/$(E2FSPROGS).$(E2FSPROGS_SUFFIX))
E2FSPROGS_SOURCE	:= $(SRCDIR)/$(E2FSPROGS).$(E2FSPROGS_SUFFIX)
E2FSPROGS_DIR		:= $(BUILDDIR)/$(E2FSPROGS)
E2FSPROGS_LICENSE	:= GPLv2+, LGPLv2+, BSD, MIT

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#
# autoconf
#
E2FSPROGS_CONF_TOOL	:= autoconf
E2FSPROGS_CONF_OPT	:= \
	$(CROSS_AUTOCONF_USR) \
	--disable-symlink-install \
	--disable-symlink-build \
	--disable-verbose-makecmds \
	--$(call ptx/endis,PTXCONF_E2FSPROGS_COMPRESSION)-compression \
	--enable-htree \
	--enable-elf-shlibs \
	--disable-bsd-shlibs \
	--disable-profile \
	--disable-checker \
	--disable-jbd-debug \
	--disable-blkid-debug \
	--disable-testio-debug \
	--disable-libuuid \
	--disable-libblkid \
	--disable-quota \
	--disable-debugfs \
	--$(call ptx/endis,PTXCONF_E2FSPROGS_IMAGER)-imager \
	--$(call ptx/endis,PTXCONF_E2FSPROGS_RESIZER)-resizer \
	--disable-defrag \
	--$(call ptx/endis,PTXCONF_E2FSPROGS_INSTALL_E2FSCK)-fsck \
	--disable-e2initrd-helper \
	--disable-tls \
	--disable-uuidd \
	--disable-nls \
	--disable-rpath \
	--without-diet-libc

E2FSPROGS_INSTALL_OPT := install

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/e2fsprogs.targetinstall:
	@$(call targetinfo)

	@$(call install_init, e2fsprogs)
	@$(call install_fixup, e2fsprogs,PRIORITY,optional)
	@$(call install_fixup, e2fsprogs,SECTION,base)
	@$(call install_fixup, e2fsprogs,AUTHOR,"Robert Schwebel <r.schwebel@pengutronix.de>")
	@$(call install_fixup, e2fsprogs,DESCRIPTION,missing)

#	#
#	# libraries
#	#

ifdef PTXCONF_E2FSPROGS_LIBCOM_ERR
	@$(call install_lib, e2fsprogs, 0, 0, 0644, libcom_err)
endif
ifdef PTXCONF_E2FSPROGS_LIBE2P
	@$(call install_lib, e2fsprogs, 0, 0, 0644, libe2p)
endif
ifdef PTXCONF_E2FSPROGS_LIBEXT2FS
	@$(call install_lib, e2fsprogs, 0, 0, 0644, libext2fs)
endif
ifdef PTXCONF_E2FSPROGS_LIBSS
	@$(call install_lib, e2fsprogs, 0, 0, 0644, libss)
endif

#	#
#	# binaries in /usr/bin
#	#
ifdef PTXCONF_E2FSPROGS_INSTALL_CHATTR
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/bin/chattr)
endif
ifdef PTXCONF_E2FSPROGS_INSTALL_LSATTR
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/bin/lsattr)
endif


#	#
#	# binaries in /usr/sbin
#	#
ifdef PTXCONF_E2FSPROGS_INSTALL_BADBLOCKS
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/sbin/badblocks)
endif

ifdef PTXCONF_E2FSPROGS_INSTALL_DUMPE2FS
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/sbin/dumpe2fs)
endif


ifdef PTXCONF_E2FSPROGS_INSTALL_E2FSCK
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/sbin/e2fsck)
	@$(call install_link, e2fsprogs, e2fsck, /usr/sbin/fsck.auto)
endif
ifdef PTXCONF_E2FSPROGS_INSTALL_FSCK_EXT2
	@$(call install_link, e2fsprogs, e2fsck, /usr/sbin/fsck.ext2)
endif
ifdef PTXCONF_E2FSPROGS_INSTALL_FSCK_EXT3
	@$(call install_link, e2fsprogs, e2fsck, /usr/sbin/fsck.ext3)
endif
ifdef PTXCONF_E2FSPROGS_INSTALL_FSCK_EXT4
	@$(call install_link, e2fsprogs, e2fsck, /usr/sbin/fsck.ext4)
endif
ifdef PTXCONF_E2FSPROGS_INSTALL_FSCK_EXT4DEV
	@$(call install_link, e2fsprogs, e2fsck, /usr/sbin/fsck.ext4dev)
endif


ifdef PTXCONF_E2FSPROGS_INSTALL_E2IMAGE
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/sbin/e2image)
endif

ifdef PTXCONF_E2FSPROGS_INSTALL_E2LABEL
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/sbin/e2label)
endif

ifdef PTXCONF_E2FSPROGS_INSTALL_E2UNDO
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/sbin/e2undo)
endif

ifdef PTXCONF_E2FSPROGS_INSTALL_FILEFRAG
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/sbin/filefrag)
endif

ifdef PTXCONF_E2FSPROGS_INSTALL_LOGSAVE
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/sbin/logsave)
endif


ifdef PTXCONF_E2FSPROGS_INSTALL_MKE2FS
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/sbin/mke2fs)
endif
ifdef PTXCONF_E2FSPROGS_INSTALL_MKFS_EXT2
	@$(call install_link, e2fsprogs, mke2fs, /usr/sbin/mkfs.ext2)
endif
ifdef PTXCONF_E2FSPROGS_INSTALL_MKFS_EXT3
	@$(call install_link, e2fsprogs, mke2fs, /usr/sbin/mkfs.ext3)
endif
ifdef PTXCONF_E2FSPROGS_INSTALL_MKFS_EXT4
	@$(call install_link, e2fsprogs, mke2fs, /usr/sbin/mkfs.ext4)
endif
ifdef PTXCONF_E2FSPROGS_INSTALL_MKFS_EXT4DEV
	@$(call install_link, e2fsprogs, mke2fs, /usr/sbin/mkfs.ext4dev)
endif


ifdef PTXCONF_E2FSPROGS_INSTALL_MKLOSTANDFOUND
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/sbin/mklost+found)
endif

ifdef PTXCONF_E2FSPROGS_INSTALL_RESIZE2FS
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/sbin/resize2fs)
endif

ifdef PTXCONF_E2FSPROGS_INSTALL_TUNE2FS
	@$(call install_copy, e2fsprogs, 0, 0, 0755, -, /usr/sbin/tune2fs)
endif

	@$(call install_alternative, e2fsprogs, 0, 0, 0644, /etc/mke2fs.conf, n)

	@$(call install_finish, e2fsprogs)

	@$(call touch)

# vim: syntax=make
