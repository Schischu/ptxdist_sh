# -*-makefile-*-
#
# Copyright (C) 2007 by Sascha Hauer
#           (C) 2010 by Carsten Schlote
#           (C) 2010 by Michael Olbrich <m.olbrich@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_DTC) += dtc

DTC_VERSION := 1.0.0

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ptx/dtb = $(notdir $(basename $(strip $(1)))).dtb

%.dtb:
	@$(call targetinfo)
	@echo CPP `ptxd_print_path "$<.tmp"`
	@cpp \
		-Wp,-MD,$(STATEDIR)/dtc.dtc.deps \
		-Wp,-MT,$<.tmp \
		-nostdinc \
		-P \
		-I$(dir $<) \
		-I$(KERNEL_DIR)/arch/$(GENERIC_KERNEL_ARCH)/boot/dts \
		-I$(KERNEL_DIR)/arch/$(GENERIC_KERNEL_ARCH)/boot/dts/include \
		-undef -D__DTS__ -x assembler-with-cpp \
		-o $<.tmp \
		$<
	@echo DTC `ptxd_print_path "$@"`
	@if $(PTXCONF_SYSROOT_HOST)/bin/dtc -h 2>&1 | grep -q "^[[:space:]]-i$$"; then \
		dtc_include="-i $(dir $<) -i $(KERNEL_DIR)/arch/$(GENERIC_KERNEL_ARCH)/boot/dts"; \
	fi; \
	$(PTXCONF_SYSROOT_HOST)/bin/dtc \
		$(call remove_quotes,$(PTXCONF_DTC_EXTRA_ARGS)) \
		$$dtc_include \
		-d $(PTXDIST_TEMPDIR)/dtc.dtc.deps \
		-I dts -O dtb -b 0 \
		-o "$@" "$<.tmp"
	@awk '{ \
			printf "%s", $$1 ;  \
			for (i = 2; i <= NF; i++) { \
				printf " $$(wildcard %s)", $$i; \
			}; \
			print "" \
		}' $(PTXDIST_TEMPDIR)/dtc.dtc.deps >> $(STATEDIR)/dtc.dtc.deps
	@$(call finish)

DTC_DTB = $(foreach dts, $(call remove_quotes,$(PTXCONF_DTC_OFTREE_DTS)), $(IMAGEDIR)/$(call ptx/dtb, $(dts)))

# make sure "ptxdist targetinstall kernel" generates a new device trees
$(STATEDIR)/kernel.targetinstall.post: $(DTC_DTB)

$(STATEDIR)/dtc.targetinstall: $(DTC_DTB)
	@$(call targetinfo)

ifdef PTXCONF_DTC_INSTALL_OFTREE
	@$(call install_init,  dtc)
	@$(call install_fixup, dtc, PRIORITY,optional)
	@$(call install_fixup, dtc, SECTION,base)
	@$(call install_fixup, dtc, AUTHOR,"Carsten Schlote <c.schlote@konzeptpark.de>")
	@$(call install_fixup, dtc, DESCRIPTION, "oftree description for machine $(PTXCONF_PROJECT_VERSION)")

	@$(call install_copy, dtc, 0, 0, 0755, /boot);
	@$(foreach dtb, $(DTC_DTB), \
		$(call install_copy, dtc, 0, 0, 0644, \
		"$(dtb)", "/boot/$(notdir $(dtb))");)

	@$(call install_finish, dtc)
endif
	@$(call touch)

# vim: syntax=make
