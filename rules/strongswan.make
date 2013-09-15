# -*-makefile-*-
#
# Copyright (C) 2013 by Christoph Fritz <chf.fritz@googlemail.com>
#
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_STRONGSWAN) += strongswan

#
# Paths and names
#
STRONGSWAN_VERSION	:= 5.0.4
STRONGSWAN_MD5		:= 0ab0397b44b197febfd0f89148344035
STRONGSWAN		:= strongswan-$(STRONGSWAN_VERSION)
STRONGSWAN_SUFFIX	:= tar.bz2
STRONGSWAN_URL		:= http://download.strongswan.org/$(STRONGSWAN).$(STRONGSWAN_SUFFIX)
STRONGSWAN_SOURCE	:= $(SRCDIR)/$(STRONGSWAN).$(STRONGSWAN_SUFFIX)
STRONGSWAN_DIR		:= $(BUILDDIR)/$(STRONGSWAN)
STRONGSWAN_LICENSE	:= GPL

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

STRONGSWAN_CONF_TOOL	:= autoconf
STRONGSWAN_CONF_OPT	:= \
	$(CROSS_AUTOCONF_USR) \
	--$(call ptx/endis, PTXCONF_STRONGSWAN_LIBCURL)-curl \
	--disable-unbound \
	--disable-soup \
	--disable-ldap \
	--enable-aes \
	--enable-des \
	--disable-blowfish \
	--disable-md4 \
	--enable-md5 \
	--enable-sha1 \
	--enable-sha2 \
	--enable-fips-prf \
	--enable-gmp \
	--disable-rdrand \
	--enable-random \
	--enable-nonce \
	--enable-x509 \
	--enable-revocation \
	--enable-constraints \
	--enable-pubkey \
	--enable-pkcs1 \
	--enable-pkcs7 \
	--enable-pkcs8 \
	--enable-pgp \
	--enable-dnskey \
	--disable-ipseckey \
	--enable-pem \
	--enable-hmac \
	--enable-cmac \
	--enable-xcbc \
	--$(call ptx/endis, PTXCONF_STRONGSWAN_AFALG)-af-alg \
	--disable-test-vectors \
	--disable-mysql \
	--disable-sqlite \
	--enable-stroke \
	--disable-medsrv \
	--disable-medcli \
	--disable-smp \
	--disable-sql \
	--disable-leak-detective \
	--disable-lock-profiler \
	--disable-unit-tester \
	--disable-load-tester \
	--disable-eap-sim \
	--disable-eap-sim-file \
	--disable-eap-sim-pcsc \
	--disable-eap-aka \
	--disable-eap-aka-3gpp2 \
	--disable-eap-simaka-sql \
	--disable-eap-simaka-pseudonym \
	--disable-eap-simaka-reauth \
	--disable-eap-identity \
	--disable-eap-md5 \
	--disable-eap-gtc \
	--disable-eap-mschapv2 \
	--disable-eap-tls \
	--disable-eap-ttls \
	--disable-eap-peap \
	--disable-eap-tnc \
	--disable-eap-dynamic \
	--disable-eap-radius \
	--enable-xauth-generic \
	--disable-xauth-eap \
	--disable-xauth-pam \
	--disable-xauth-noauth \
	--disable-tnc-ifmap \
	--disable-tnc-pdp \
	--disable-tnc-imc \
	--disable-tnc-imv \
	--disable-tnccs-11 \
	--disable-tnccs-20 \
	--disable-tnccs-dynamic \
	--disable-imc-test \
	--disable-imv-test \
	--disable-imc-scanner \
	--disable-imv-scanner \
	--disable-imc-os \
	--disable-imv-os \
	--disable-imc-attestation \
	--disable-imv-attestation \
	--enable-kernel-netlink \
	--disable-kernel-pfkey \
	--disable-kernel-pfroute \
	--disable-kernel-klips \
	--disable-libipsec \
	--enable-socket-default \
	--disable-socket-dynamic \
	--disable-farp \
	--disable-dumm \
	--disable-fast \
	--disable-manager \
	--disable-mediation \
	--disable-integrity-test \
	--enable-load-warning \
	--enable-ikev1 \
	--enable-ikev2 \
	--enable-charon \
	--enable-tools \
	--enable-scripts \
	--disable-conftest \
	--enable-updown \
	--enable-attr \
	--disable-attr-sql \
	--disable-dhcp \
	--enable-resolve \
	--disable-padlock \
	--disable-openssl \
	--disable-gcrypt \
	--disable-agent \
	--disable-pkcs11 \
	--disable-ctr \
	--disable-ccm \
	--disable-gcm \
	--disable-addrblock \
	--disable-unity \
	--disable-uci \
	--disable-android-dns \
	--disable-android-log \
	--disable-maemo \
	--disable-nm \
	--disable-ha \
	--disable-whitelist \
	--disable-lookip \
	--disable-error-notify \
	--disable-certexpire \
	--disable-systime-fix \
	--disable-led \
	--disable-duplicheck \
	--disable-coupling \
	--disable-radattr \
	--disable-vstr \
	--disable-monolithic \
	--disable-bfd-backtraces \
	--disable-unit-tests \
	--disable-tkm \
	--disable-defaults \
	--enable-dependency-tracking \
	--enable-shared \
	--disable-static \
	--enable-fast-install \
	--enable-libtool-lock \
	--with-ipseclibdir=/usr/lib \
	--with-systemdsystemunitdir=/lib/systemd/system

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

STRONGSWAN_PLUGINS := \
	libstrongswan-aes.so \
	libstrongswan-attr.so \
	libstrongswan-cmac.so \
	libstrongswan-constraints.so \
	libstrongswan-des.so \
	libstrongswan-dnskey.so \
	libstrongswan-fips-prf.so \
	libstrongswan-gmp.so \
	libstrongswan-hmac.so \
	libstrongswan-kernel-netlink.so \
	libstrongswan-md5.so \
	libstrongswan-nonce.so \
	libstrongswan-pem.so \
	libstrongswan-pgp.so \
	libstrongswan-pkcs1.so \
	libstrongswan-pkcs7.so \
	libstrongswan-pkcs8.so \
	libstrongswan-pubkey.so \
	libstrongswan-random.so \
	libstrongswan-resolve.so \
	libstrongswan-revocation.so \
	libstrongswan-sha1.so \
	libstrongswan-sha2.so \
	libstrongswan-socket-default.so \
	libstrongswan-stroke.so \
	libstrongswan-updown.so \
	libstrongswan-x509.so \
	libstrongswan-xauth-generic.so \
	libstrongswan-xcbc.so

ifdef PTXCONF_STRONGSWAN_LIBCUR
	STRONGSWAN_PLUGINS += libstrongswan-curl.so
endif
ifdef PTXCONF_STRONGSWAN_AFALG
	STRONGSWAN_PLUGINS += libstrongswan-af-alg.so
endif

$(STATEDIR)/strongswan.targetinstall:
	@$(call targetinfo)

	@$(call install_init, strongswan)
	@$(call install_fixup, strongswan,PRIORITY,optional)
	@$(call install_fixup, strongswan,SECTION,base)
	@$(call install_fixup, strongswan,AUTHOR,"Christoph Fritz <chf.fritz@googlemail.com>")
	@$(call install_fixup, strongswan,DESCRIPTION,missing)

	@$(call install_alternative, strongswan, 0, 0, 0644, /etc/strongswan.conf)

	@$(call install_copy, strongswan, 0, 0, 0755, -, /usr/sbin/ipsec)

	@$(call install_tree, strongswan, 0, 0, -, /usr/libexec/ipsec)

	@$(call install_lib, strongswan, 0, 0, 0644, libcharon)
	@$(call install_lib, strongswan, 0, 0, 0644, libhydra)
	@$(call install_lib, strongswan, 0, 0, 0644, libstrongswan)

	@$(foreach plugin, $(STRONGSWAN_PLUGINS), \
		$(call install_copy, strongswan, 0, 0, 0644, -, \
			/usr/lib/plugins/$(plugin));)

ifdef PTXCONF_STRONGSWAN_SYSTEMD_UNIT
	@$(call install_alternative, strongswan, 0, 0, 0644, \
		/lib/systemd/system/strongswan.service)
	@$(call install_link, strongswan, ../strongswan.service, \
		/lib/systemd/system/multi-user.target.wants/strongswan.service)
endif

	@$(call install_copy, strongswan, 0, 0, 0644, /etc/ipsec.d/aacerts)
	@$(call install_copy, strongswan, 0, 0, 0644, /etc/ipsec.d/acerts)
	@$(call install_copy, strongswan, 0, 0, 0644, /etc/ipsec.d/cacerts)
	@$(call install_copy, strongswan, 0, 0, 0644, /etc/ipsec.d/certs)
	@$(call install_copy, strongswan, 0, 0, 0644, /etc/ipsec.d/crls)
	@$(call install_copy, strongswan, 0, 0, 0644, /etc/ipsec.d/ocspcerts)
	@$(call install_copy, strongswan, 0, 0, 0600, /etc/ipsec.d/private)
	@$(call install_copy, strongswan, 0, 0, 0644, /etc/ipsec.d/reqs)

	@$(call install_finish, strongswan)

	@$(call touch)

# vim: syntax=make
