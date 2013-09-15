# -*-makefile-*-
#
# Copyright (C) 2008 by Robert Schwebel
#               2010 by Marc Kleine-Budde <mkl@penutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_UTIL_LINUX_NG) += util-linux-ng

#
# Paths and names
#
UTIL_LINUX_NG_VERSION	:= 2.23.1
UTIL_LINUX_NG_MD5	:= 33ba55ce82f8e3b8d7a38fac0f62779a
UTIL_LINUX_NG		:= util-linux-$(UTIL_LINUX_NG_VERSION)
UTIL_LINUX_NG_SUFFIX	:= tar.xz
UTIL_LINUX_NG_URL	:= $(call ptx/mirror, KERNEL, utils/util-linux/v2.23/$(UTIL_LINUX_NG).$(UTIL_LINUX_NG_SUFFIX))
UTIL_LINUX_NG_SOURCE	:= $(SRCDIR)/$(UTIL_LINUX_NG).$(UTIL_LINUX_NG_SUFFIX)
UTIL_LINUX_NG_DIR	:= $(BUILDDIR)/$(UTIL_LINUX_NG)
UTIL_LINUX_NG_LICENSE	:= GPLv2, GPLv2+, GPLv3+, LGPLv2+, BSD, public_domain

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

UTIL_LINUX_NG_PATH	:= PATH=$(CROSS_PATH)
UTIL_LINUX_NG_ENV 	:= \
	$(CROSS_ENV) \
	$(call ptx/ncurses, PTXCONF_UTIL_LINUX_NG_USES_NCURSES) \
	scanf_cv_type_modifier=as \
	ac_cv_lib_termcap_tgetnum=no \
	ac_cv_path_BLKID=no \
	ac_cv_path_PERL=no \
	ac_cv_path_VOLID=no

#
# autoconf
#
UTIL_LINUX_NG_AUTOCONF := \
	$(CROSS_AUTOCONF_USR) \
	--enable-shared \
	--disable-static \
	--disable-gtk-doc \
	$(GLOBAL_LARGE_FILE_OPTION) \
	--disable-nls \
	--disable-rpath \
	--disable-static-programs \
	--enable-tls \
	--disable-most-builds \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_LIBUUID)-libuuid \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_LIBBLKID)-libblkid \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_LIBMOUNT)-libmount \
	--disable-deprecated-mount \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_MOUNT)-mount \
	--disable-losetup \
	--disable-cytune \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_FSCK)-fsck \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_PARTX_TOOLS)-partx \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_UUIDD)-uuidd \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_MOUNTPOINT)-mountpoint \
	--disable-fallocate \
	--disable-unshare \
	--disable-nsenter \
	--disable-setpriv \
	--disable-eject \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_AGETTY)-agetty \
	--disable-cramfs \
	--disable-bfs \
	--disable-fdformat \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_HWCLOCK)-hwclock \
	--disable-wdctl \
	--disable-switch_root \
	--disable-pivot_root \
	--disable-elvtune \
	--disable-tunelp \
	--disable-kill \
	--disable-last \
	--disable-utmpdump \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_LINE)-line \
	--disable-mesg \
	--disable-raw \
	--disable-rename \
	--disable-reset \
	--disable-vipw \
	--disable-newgrp \
	--disable-chfn-chsh-password \
	--disable-chfn-chsh \
	--disable-chsh-only-listed \
	--disable-login \
	--disable-login-chown-vcs \
	--disable-login-stat-mail \
	--disable-sulogin \
	--disable-su \
	--disable-runuser \
	--disable-ul \
	--disable-more \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_SETTERM)-setterm \
	--disable-pg \
	--$(call ptx/endis, PTXCONF_UTIL_LINUX_NG_SCHEDUTILS)-schedutils \
	--disable-wall \
	--disable-write \
	--disable-socket-activation \
	--disable-bash-completion \
	--disable-pg-bell \
	--disable-use-tty-group \
	--disable-sulogin-emergency-mount \
	--disable-makeinstall-chown \
	--disable-makeinstall-setuid \
	--without-libiconv-prefix \
	--without-libintl-prefix \
	--without-selinux \
	--without-audit \
	--without-udev \
	--$(call ptx/wwo, PTXCONF_UTIL_LINUX_NG_USES_NCURSES)-ncurses \
	--without-slang \
	--without-utempter \
	--without-user

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/util-linux-ng.targetinstall:
	@$(call targetinfo)

	@$(call install_init, util-linux-ng)
	@$(call install_fixup, util-linux-ng,PRIORITY,optional)
	@$(call install_fixup, util-linux-ng,SECTION,base)
	@$(call install_fixup, util-linux-ng,AUTHOR,"Robert Schwebel <r.schwebel@pengutronix.de>")
	@$(call install_fixup, util-linux-ng,DESCRIPTION,missing)

ifdef PTXCONF_UTIL_LINUX_NG_COLUMN
	@$(call install_copy, util-linux-ng, root, root, 0755, -, /usr/bin/column)
endif
ifdef PTXCONF_UTIL_LINUX_NG_LINE
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/bin/line)
endif
ifdef PTXCONF_UTIL_LINUX_NG_MOUNTPOINT
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /bin/mountpoint)
endif
ifdef PTXCONF_UTIL_LINUX_NG_ADDPART
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/sbin/addpart)
endif
ifdef PTXCONF_UTIL_LINUX_NG_DELPART
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/sbin/delpart)
endif
ifdef PTXCONF_UTIL_LINUX_NG_PARTX
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/sbin/partx)
endif
ifdef PTXCONF_UTIL_LINUX_NG_AGETTY
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /sbin/agetty)
endif
ifdef PTXCONF_UTIL_LINUX_NG_MKSWAP
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /sbin/mkswap)
endif
ifdef PTXCONF_UTIL_LINUX_NG_SWAPON
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /sbin/swapon)
	@$(call install_link, util-linux-ng, swapon, /sbin/swapoff)
endif
ifdef PTXCONF_UTIL_LINUX_NG_MOUNT
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /bin/mount)
endif
ifdef PTXCONF_UTIL_LINUX_NG_UMOUNT
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /bin/umount)
endif
ifdef PTXCONF_UTIL_LINUX_NG_FSCK
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /sbin/fsck)
endif
ifdef PTXCONF_UTIL_LINUX_NG_IPCS
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/bin/ipcs)
endif
ifdef PTXCONF_UTIL_LINUX_NG_IPCRM
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/bin/ipcrm)
endif
ifdef PTXCONF_UTIL_LINUX_NG_READPROFILE
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/sbin/readprofile)
endif
ifdef PTXCONF_UTIL_LINUX_NG_FDISK
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /sbin/fdisk)
endif
ifdef PTXCONF_UTIL_LINUX_NG_SFDISK
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /sbin/sfdisk)
endif
ifdef PTXCONF_UTIL_LINUX_NG_CFDISK
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /sbin/cfdisk)
endif
ifdef PTXCONF_UTIL_LINUX_NG_SETTERM
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/bin/setterm)
endif
ifdef PTXCONF_UTIL_LINUX_NG_CHRT
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/bin/chrt)
endif
ifdef PTXCONF_UTIL_LINUX_NG_HWCLOCK
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /sbin/hwclock)
endif
ifdef PTXCONF_UTIL_LINUX_NG_IONICE
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/bin/ionice)
endif
ifdef PTXCONF_UTIL_LINUX_NG_TASKSET
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/bin/taskset)
endif
ifdef PTXCONF_UTIL_LINUX_NG_MCOOKIE
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/bin/mcookie)
endif
ifdef PTXCONF_UTIL_LINUX_NG_LDATTACH
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/sbin/ldattach)
endif
ifdef PTXCONF_UTIL_LINUX_NG_LIBBLKID
	@$(call install_lib, util-linux-ng, 0, 0, 0644, libblkid)
endif
ifdef PTXCONF_UTIL_LINUX_NG_BLKID
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /sbin/blkid)
endif
ifdef PTXCONF_UTIL_LINUX_NG_LIBUUID
	@$(call install_lib, util-linux-ng, 0, 0, 0644, libuuid)
endif
ifdef PTXCONF_UTIL_LINUX_NG_LIBMOUNT
	@$(call install_lib, util-linux-ng, 0, 0, 0644, libmount)
endif
ifdef PTXCONF_UTIL_LINUX_NG_UUIDD
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/sbin/uuidd)
endif
ifdef PTXCONF_UTIL_LINUX_NG_UUIDGEN
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /usr/bin/uuidgen)
endif
ifdef PTXCONF_UTIL_LINUX_NG_FINDFS
	@$(call install_copy, util-linux-ng, 0, 0, 0755, -, /sbin/findfs)
endif

	@$(call install_finish, util-linux-ng)

	@$(call touch)

# vim: syntax=make
