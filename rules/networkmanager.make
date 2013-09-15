# -*-makefile-*-
#
# Copyright (C) 2009 by Robert Schwebel <r.schwebel@pengutronix.de>
#           (C) 2012 by Jan Luebbe <j.luebbe@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_NETWORKMANAGER) += networkmanager

#
# Paths and names
#
NETWORKMANAGER_VERSION	:= 0.9.8.0
NETWORKMANAGER_MD5	:= 38d28f6bd9220d85dfff47210706195c
NETWORKMANAGER		:= NetworkManager-$(NETWORKMANAGER_VERSION)
NETWORKMANAGER_SUFFIX	:= tar.xz
NETWORKMANAGER_URL	:= http://ftp.gnome.org/pub/GNOME/sources/NetworkManager/0.9/$(NETWORKMANAGER).$(NETWORKMANAGER_SUFFIX)
NETWORKMANAGER_SOURCE	:= $(SRCDIR)/$(NETWORKMANAGER).$(NETWORKMANAGER_SUFFIX)
NETWORKMANAGER_DIR	:= $(BUILDDIR)/$(NETWORKMANAGER)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#
# autoconf
#
NETWORKMANAGER_CONF_TOOL := autoconf
NETWORKMANAGER_CONF_OPT := \
	$(CROSS_AUTOCONF_USR) \
	--disable-static \
	--enable-shared \
	--disable-nls \
	--disable-rpath \
	--disable-ifcfg-rh \
	--disable-ifcfg-suse \
	--enable-ifupdown \
	--disable-ifnet \
	--disable-qt \
	--disable-wimax \
	--disable-polkit \
	--disable-modify-system \
	--disable-ppp \
	--disable-concheck \
	--enable-more-warnings \
	--disable-vala \
	--disable-tests \
	--disable-doc \
	--disable-gtk-doc \
	--with-systemdsystemunitdir=/lib/systemd/system \
	--with-session-tracking=none \
	--with-crypto=gnutls \
	--without-modem-manager-1 \
	--with-dhclient=/sbin/dhclient \
	--without-dhcpcd \
	--without-resolvconf \
	--without-netconfig \
	--with-iptables=/usr/sbin/iptables


# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/networkmanager.install:
	@$(call targetinfo)
	@$(call world/install, NETWORKMANAGER)

ifdef PTXCONF_NETWORKMANAGER_EXAMPLES
	@cd $(NETWORKMANAGER_DIR)/examples/C/glib/ \
		&& for FILE in `find -name "*-glib" -printf '%f\n'`; do \
		install -D -m 755 "$${FILE}" "$(NETWORKMANAGER_PKGDIR)/usr/bin/nm-$${FILE}"; \
	done
	@cd $(NETWORKMANAGER_DIR)/examples/python/ \
		&& for FILE in `find -name "*.py" -printf '%f\n'`; do \
		install -D -m 755 "$${FILE}" "$(NETWORKMANAGER_PKGDIR)/usr/bin/nm-$${FILE}"; \
	done
	@cd $(NETWORKMANAGER_DIR)/examples/shell/ \
		&& for FILE in `find -name "*.sh" -printf '%f\n'`; do \
		install -D -m 755 "$${FILE}" "$(NETWORKMANAGER_PKGDIR)/usr/bin/nm-$${FILE}"; \
	done
endif

	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/networkmanager.targetinstall:
	@$(call targetinfo)

	@$(call install_init, networkmanager)
	@$(call install_fixup, networkmanager,PRIORITY,optional)
	@$(call install_fixup, networkmanager,SECTION,base)
	@$(call install_fixup, networkmanager,AUTHOR,"Jan Luebbe <j.luebbe@pengutronix.de>")
	@$(call install_fixup, networkmanager,DESCRIPTION,missing)

	@$(call install_alternative, networkmanager, 0, 0, 0644, /etc/NetworkManager/NetworkManager.conf)
	@$(call install_copy, networkmanager, 0, 0, 0755, /etc/NetworkManager/dispatcher.d/)
	@$(call install_copy, networkmanager, 0, 0, 0755, /etc/NetworkManager/system-connections/)

#	# unmanage NFS root devices
	@$(call install_alternative, networkmanager, 0, 0, 0755, /lib/init/nm-unmanage.sh)

	@$(call install_copy, networkmanager, 0, 0, 0755, /var/lib/NetworkManager)

ifdef PTXCONF_INITMETHOD_BBINIT
ifdef PTXCONF_NETWORKMANAGER_STARTSCRIPT
	@$(call install_alternative, networkmanager, 0, 0, 0755, /etc/init.d/NetworkManager)

ifneq ($(call remove_quotes, $(PTXCONF_NETWORKMANAGER_BBINIT_LINK)),)
	@$(call install_link, networkmanager, \
		../init.d/NetworkManager, \
		/etc/rc.d/$(PTXCONF_NETWORKMANAGER_BBINIT_LINK))
endif
endif
endif
ifdef PTXCONF_NETWORKMANAGER_SYSTEMD_UNIT
	@$(call install_alternative, networkmanager, 0, 0, 0644, \
		/lib/systemd/system/NetworkManager.service)
	@$(call install_link, networkmanager, ../NetworkManager.service, \
		/lib/systemd/system/multi-user.target.wants/NetworkManager.service)
	@$(call install_alternative, networkmanager, 0, 0, 0644, \
		/lib/systemd/system/NetworkManager-unmanage.service)
	@$(call install_link, networkmanager, ../NetworkManager-unmanage.service, \
		/lib/systemd/system/NetworkManager.service.wants/NetworkManager-unmanage.service)
	@$(call install_alternative, networkmanager, 0, 0, 0644, \
		/lib/systemd/system/NetworkManager-wait-online.service)
endif

	@$(call install_copy, networkmanager, 0, 0, 0755, -, /usr/sbin/NetworkManager)
	@$(call install_copy, networkmanager, 0, 0, 0755, -, /usr/bin/nm-online)
	@$(call install_copy, networkmanager, 0, 0, 0755, -, /usr/bin/nm-tool)
	@$(call install_copy, networkmanager, 0, 0, 0755, -, /usr/bin/nmcli)

	@$(call install_tree, networkmanager, 0, 0, -, /usr/libexec/)

	@$(call install_lib, networkmanager, 0, 0, 0644, NetworkManager/libnm-settings-plugin-ifupdown)
	@$(call install_lib, networkmanager, 0, 0, 0644, libnm-util)
	@$(call install_lib, networkmanager, 0, 0, 0644, libnm-glib)

	@$(call install_tree, networkmanager, 0, 0, -, /etc/dbus-1/system.d/)
	@$(call install_tree, networkmanager, 0, 0, -, /usr/share/dbus-1/system-services/)

ifdef PTXCONF_NETWORKMANAGER_EXAMPLES
	@cd $(NETWORKMANAGER_PKGDIR)/usr/bin/ \
		&& for FILE in `find -name "*-glib" -printf '%f\n'`; do \
		$(call install_copy, networkmanager, 0, 0, 0755, -, /usr/bin/$${FILE}); \
	done
	@cd $(NETWORKMANAGER_PKGDIR)/usr/bin/ \
		&& for FILE in `find -name "*.py" -printf '%f\n'`; do \
		$(call install_copy, networkmanager, 0, 0, 0755, -, /usr/bin/$${FILE}); \
	done
	@cd $(NETWORKMANAGER_PKGDIR)/usr/bin/ \
		&& for FILE in `find -name "*.sh" -printf '%f\n'`; do \
		$(call install_copy, networkmanager, 0, 0, 0755, -, /usr/bin/$${FILE}); \
	done
endif

	@$(call install_finish, networkmanager)

	@$(call touch)

# vim: syntax=make
