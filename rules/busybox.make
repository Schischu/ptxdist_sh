# -*-makefile-*-
#
# Copyright (C) 2003-2009 by Robert Schwebel <r.schwebel@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_BUSYBOX) += busybox

#
# Paths and names
#
BUSYBOX_VERSION	:= 1.21.0
BUSYBOX_MD5	:= d613f2e4b580305c1de8691f7b84285e
BUSYBOX		:= busybox-$(BUSYBOX_VERSION)
BUSYBOX_SUFFIX	:= tar.bz2
BUSYBOX_URL	:= http://www.busybox.net/downloads/$(BUSYBOX).$(BUSYBOX_SUFFIX)
BUSYBOX_SOURCE	:= $(SRCDIR)/$(BUSYBOX).$(BUSYBOX_SUFFIX)
BUSYBOX_DIR	:= $(BUILDDIR)/$(BUSYBOX)
BUSYBOX_KCONFIG	:= $(BUSYBOX_DIR)/Config.in
BUSYBOX_LICENSE	:= GPLv2

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

busybox_import: $(STATEDIR)/busybox.prepare

BUSYBOX_TAGS_OPT := TAGS tags

$(STATEDIR)/busybox.prepare:
	@$(call targetinfo)

	@cd $(BUSYBOX_DIR) && \
		$(BUSYBOX_PATH)  \
		$(MAKE) distclean $(BUSYBOX_MAKE_OPT)
	@grep -e PTXCONF_BUSYBOX_ $(PTXDIST_PTXCONFIG) | \
		sed -e 's/PTXCONF_BUSYBOX_/CONFIG_/g' > $(BUSYBOX_DIR)/.config

	@$(call ptx/oldconfig, BUSYBOX)

	@$(call touch)

BUSYBOX_MAKE_OPT := \
	V=$(PTXDIST_VERBOSE) \
	ARCH=$(PTXCONF_ARCH_STRING) \
	SUBARCH=$(PTXCONF_ARCH_STRING) \
	CROSS_COMPILE=$(COMPILER_PREFIX)

BUSYBOX_MAKE_ENV := \
	$(CROSS_ENV) \
	CFLAGS="-I$(KERNEL_HEADERS_INCLUDE_DIR)" \
	SKIP_STRIP=y

BUSYBOX_INSTALL_ENV := \
	$(BUSYBOX_MAKE_ENV)

BUSYBOX_INSTALL_OPT := \
	$(BUSYBOX_MAKE_OPT) \
	CONFIG_PREFIX=$(BUSYBOX_PKGDIR) \
	install

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/busybox.install:
	@$(call targetinfo)
	@$(call world/install, BUSYBOX)
	@install -D -m644 $(BUSYBOX_DIR)/busybox.links \
		$(BUSYBOX_PKGDIR)/etc/busybox.links
ifdef PTXCONF_BUSYBOX_FEATURE_INDIVIDUAL
	@install -D -m644 $(BUSYBOX_DIR)/0_lib/libbusybox.so.$(BUSYBOX_VERSION) \
		$(BUSYBOX_PKGDIR)/lib/libbusybox.so.$(BUSYBOX_VERSION)
	@mkdir -p $(BUSYBOX_PKGDIR)/usr/lib/busybox
	@cp -r $(BUSYBOX_DIR)/0_lib/* \
		$(BUSYBOX_PKGDIR)/usr/lib/busybox
endif
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/busybox.targetinstall:
	@$(call targetinfo)

	@$(call install_init, busybox)
	@$(call install_fixup, busybox,PRIORITY,optional)
	@$(call install_fixup, busybox,SECTION,base)
	@$(call install_fixup, busybox,AUTHOR,"Robert Schwebel <r.schwebel@pengutronix.de>")
	@$(call install_fixup, busybox,DESCRIPTION,missing)

ifdef PTXCONF_BUSYBOX_FEATURE_INDIVIDUAL
#
# individual busybox applets and shared lib
#
	@$(call install_lib, busybox, 0, 0, 0644, libbusybox)

	@cat $(BUSYBOX_PKGDIR)/etc/busybox.links | while read link; do \
		$(call install_copy, busybox, 0, 0, 755, \
		"$(BUSYBOX_PKGDIR)/usr/lib/busybox/$${link##*/}", "$${link}"); \
	done
else
#
# traditionally busybox with links
#
ifdef PTXCONF_BUSYBOX_FEATURE_SUID
	@$(call install_copy, busybox, 0, 0, 4755, -, /bin/busybox)
ifdef PTXCONF_BUSYBOX_FEATURE_SUID_CONFIG
	@$(call install_alternative, busybox, 0, 0, 0644, /etc/busybox.conf)
endif
else
	@$(call install_copy, busybox, 0, 0, 755, -, /bin/busybox)
endif
	@cat $(BUSYBOX_PKGDIR)/etc/busybox.links | while read link; do	\
		case "$${link}" in					\
		(/*/*/*) to="../../bin/busybox" ;;			\
		(/bin/*) to="busybox" ;;				\
		(/*/*)	 to="../bin/busybox" ;;				\
		(/*)     to="bin/busybox" ;;				\
		esac;							\
		$(call install_link, busybox, "$${to}", "$${link}");	\
	done
endif

ifdef PTXCONF_BUSYBOX_FTPD_INETD
	@$(call install_alternative, busybox, 0, 0, 0644, /etc/inetd.conf.d/ftpd)
endif

ifdef PTXCONF_BUSYBOX_TELNETD_INETD
	@$(call install_alternative, busybox, 0, 0, 0644, /etc/inetd.conf.d/telnetd)
endif

#	#
#	# bb init: start scripts
#	#

ifdef PTXCONF_INITMETHOD_BBINIT
ifdef PTXCONF_BUSYBOX_INETD_STARTSCRIPT
	@$(call install_alternative, busybox, 0, 0, 0755, /etc/init.d/inetd)

ifneq ($(call remove_quotes, $(PTXCONF_BUSYBOX_INETD_BBINIT_LINK)),)
	@$(call install_link, busybox, \
		../init.d/inetd, \
		/etc/rc.d/$(PTXCONF_BUSYBOX_INETD_BBINIT_LINK))
endif
endif

ifdef PTXCONF_BUSYBOX_TELNETD_STARTSCRIPT
	@$(call install_alternative, busybox, 0, 0, 0755, /etc/init.d/telnetd)

ifneq ($(call remove_quotes,$(PTXCONF_BUSYBOX_TELNETD_BBINIT_LINK)),)
	@$(call install_link, busybox, \
		../init.d/telnetd, \
		/etc/rc.d/$(PTXCONF_BUSYBOX_TELNETD_BBINIT_LINK))
endif
endif

ifdef PTXCONF_BUSYBOX_SYSLOGD_STARTSCRIPT
	@$(call install_alternative, busybox, 0, 0, 0755, /etc/init.d/syslogd)

ifneq ($(call remove_quotes, $(PTXCONF_BUSYBOX_SYSLOGD_BBINIT_LINK)),)
	@$(call install_link, busybox, \
		../init.d/syslogd, \
		/etc/rc.d/$(PTXCONF_BUSYBOX_SYSLOGD_BBINIT_LINK))
endif
endif

ifdef PTXCONF_BUSYBOX_CROND_STARTSCRIPT
	@$(call install_alternative, busybox, 0, 0, 0755, /etc/init.d/crond)

ifneq ($(call remove_quotes, $(PTXCONF_BUSYBOX_CROND_BBINIT_LINK)),)
	@$(call install_link, busybox, \
		../init.d/crond, \
		/etc/rc.d/$(PTXCONF_BUSYBOX_CROND_BBINIT_LINK))
endif
endif

ifdef PTXCONF_BUSYBOX_HWCLOCK_STARTSCRIPT
	@$(call install_alternative, busybox, 0, 0, 0755, /etc/init.d/hwclock)

ifneq ($(call remove_quotes, $(PTXCONF_BUSYBOX_HWCLOCK_BBINIT_LINK)),)
	@$(call install_link, busybox, \
		../init.d/hwclock, \
		/etc/rc.d/$(PTXCONF_BUSYBOX_HWCLOCK_BBINIT_LINK))
endif
endif

ifdef PTXCONF_BUSYBOX_BB_SYSCTL_STARTSCRIPT
	@$(call install_alternative, busybox, 0, 0, 0755, /etc/init.d/sysctl)

ifneq ($(call remove_quotes,$(PTXCONF_BUSYBOX_BB_SYSCTL_BBINIT_LINK)),)
	@$(call install_link, busybox, \
		../init.d/sysctl, \
		/etc/rc.d/$(PTXCONF_BUSYBOX_BB_SYSCTL_BBINIT_LINK))
endif
endif

endif # PTXCONF_INITMETHOD_BBINIT

ifdef PTXCONF_BUSYBOX_TELNETD_SYSTEMD_UNIT
	@$(call install_alternative, busybox, 0, 0, 0644, \
		/lib/systemd/system/telnetd.socket)
	@$(call install_alternative, busybox, 0, 0, 0644, \
		/lib/systemd/system/telnetd@.service)
	@$(call install_link, busybox, ../telnetd.socket, \
		/lib/systemd/system/sockets.target.wants/telnetd.socket)
endif

#	#
#	# config files
#	#

ifdef PTXCONF_BUSYBOX_FEATURE_MDEV_CONF
	@$(call install_alternative, busybox, 0, 0, 0644, /etc/mdev.conf)
endif

ifdef PTXCONF_BUSYBOX_UDHCPC
	@$(call install_alternative, busybox, 0, 0, 0754, /etc/udhcpc.script)
	@$(call install_link, busybox, ../../../etc/udhcpc.script, /usr/share/udhcpc/default.script)
endif

ifdef PTXCONF_BUSYBOX_CROND
	@$(call install_copy, busybox, 0, 0, 0755, /etc/cron)
	@$(call install_copy, busybox, 0, 0, 0755, /var/spool/cron/crontabs/)
endif

ifdef PTXCONF_BUSYBOX_BB_SYSCTL
	@$(call install_alternative, busybox, 0, 0, 0644, /etc/sysctl.conf)
endif

	@$(call install_finish, busybox)

	@$(call touch)

# vim: syntax=make
