#!/usr/bin/gawk -f
#
# Copyright (C) 2006, 2007, 2008 by the PTXdist project
#               2009 by Marc Kleine-Budde <mkl@pengutronix.de>
#               2010 by Michael Olbrich <m.olbrich@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

BEGIN {
	FS = "[[:space:]]*[+]=[[:space:]]*|=";

	MAP_ALL			= ENVIRON["PTX_MAP_ALL"];
	MAP_ALL_MAKE		= ENVIRON["PTX_MAP_ALL_MAKE"];
	MAP_DEPS		= ENVIRON["PTX_MAP_DEPS"];
	DGEN_DEPS_PRE		= ENVIRON["PTX_DGEN_DEPS_PRE"];
	DGEN_DEPS_POST		= ENVIRON["PTX_DGEN_DEPS_POST"];
	DGEN_RULESFILES_MAKE	= ENVIRON["PTX_DGEN_RULESFILES_MAKE"];
	PTXDIST_TEMPDIR		= ENVIRON["PTXDIST_TEMPDIR"];
}

#
# called when a new file is opened
#
FNR == 1 {
	#
	# remember ARGIND of current file
	#
	move_argc = ARGIND;

	#
	# "include" all mafile files which are _not_ pkgs explicidly
	# the make files which are actually pkgs will be "include"d
	# in the END rule
	#
	if (old_filename && old_filename ~ /.+\/rules\/.+\.make/ && !is_pkg)
		print "include "old_filename				> DGEN_RULESFILES_MAKE;

	# remember the current opened file
	old_filename = FILENAME;

	# will be set later, if makefile belongs to a pkg
	is_pkg = "";
}



#
# skip comments and empty lines
#
/^\#|^$/ {
	next;
}



#
# handle "include <MAKEFILE>" lines:
#
# add "<MAKEFILE>" to argv array after the file that includes
# "<MAKEFILE>"
#
$0 ~ /^include[[:space:]]+\/.*\.make$/ {
	move_argc++;

	for (i = ARGC; i > move_argc; i--)
		ARGV[i] = ARGV[i - 1];

	ARGV[i] = gensub(/^include[[:space:]]+/, "", "g");
	ARGC++;

	next;
}


#
# parse "PACKAGES-$(PTXCONF_PKG) += pkg" lines, i.e. rules-files from
# rules/*.make. Setup mapping between upper and lower case pkg names
#
# out:
# PKG_to_pkg		array that maps from upper case to lower case pkg name
# pkg_to_PKG		array that maps from lower case to upper case pkg name
# PKG_to_filename	array that maps from upper case pkg name to filename
#
$1 ~ /^[A-Z_]*PACKAGES-/ {
	this_PKG = gensub(/^[A-Z_]*PACKAGES-\$\(PTXCONF_([^\)]*)\)/, "\\1", "g", $1);
	this_PKG = gensub(/^[A-Z0-9_]*-\$\(PTXCONF_([^\)]*)\)/, "\\1", "g", this_PKG);

	is_pkg = this_pkg = $2;
	if (this_pkg ~ /[A-Z]+/) {
		print \
			"\n" \
			"error: upper case chars in package '" this_pkg "' detected, please fix!\n" \
			"\n\n"
		exit 1
	}

	PKG_to_pkg[this_PKG] = this_pkg;
	pkg_to_PKG[this_pkg] = this_PKG;
	PKG_to_filename[this_PKG] = FILENAME;

	print "PTX_MAP_TO_package_" this_PKG "=\"" this_pkg "\""	> MAP_ALL;
	print "PTX_MAP_TO_package_" this_PKG "="   this_pkg 		> MAP_ALL_MAKE;
	print "PTX_MAP_TO_PACKAGE_" this_pkg "="   this_PKG		> MAP_ALL_MAKE;

	next;
}

#
# parses "PTX_MAP_[BR]_DEP_PKG=FOO" lines, which are the raw dependencies
# generated from kconfig. these deps usually contain non pkg symbols,
# these are filtered out here.
#
$1 ~ /^PTX_MAP_._DEP/ {
	this_PKG = gensub(/PTX_MAP_._DEP_/, "", "g", $1);
	dep_type = gensub(/PTX_MAP_(.)_DEP_.*/, "\\1", "g", $1);

	# no pkg
	if (!(this_PKG in PKG_to_pkg))
		next;

	this_DEP = $2
	n = split($2, this_DEP_array, ":");

	# no deps
	if (n == 0)
		next;

	this_PKG_DEP = ""
	this_PKG_dep = ""
	for (i = 1; i <= n; i++) {
		this_DEP = this_DEP_array[i];

		if (!(this_DEP in PKG_to_pkg))
			continue

		if (this_DEP ~ /^BASE$/) {
			base_PKG_to_pkg[this_PKG] = PKG_to_pkg[this_PKG];

			if (dep_type == "R")
				PKG_to_R_DEP["BASE"] = PKG_to_B_DEP["BASE"] " " this_PKG;
			else
				PKG_to_B_DEP["BASE"] = PKG_to_B_DEP["BASE"] " " this_PKG;

			continue;
		}

		this_dep = PKG_to_pkg[this_DEP];

		this_PKG_DEP = this_PKG_DEP " " this_DEP;
		this_PKG_dep = this_PKG_dep " " this_dep;
	}

	# no deps to pkgs
	if (this_PKG_DEP == "")
		next;

	if (dep_type == "R")
		PKG_to_R_DEP[this_PKG] = this_PKG_DEP;
	else
		PKG_to_B_DEP[this_PKG] = this_PKG_DEP;
	print "PTX_MAP_" dep_type "_DEP_" this_PKG "=" this_PKG_DEP	> MAP_DEPS;
	print "PTX_MAP_" dep_type "_dep_" this_PKG "=" this_PKG_dep	> MAP_DEPS;
	print "PTX_MAP_" dep_type "_dep_" this_PKG "=" this_PKG_dep	> MAP_ALL_MAKE;

	next;
}


#
# parse the ptx- and platformconfig
# record yes and module packages
#
$1 ~ /^PTXCONF_/ {
	this_PKG = gensub(/^PTXCONF_/, "", "g", $1);

	if ($2 ~ /^[ym]$/ && this_PKG in PKG_to_pkg)
		active_PKG_to_pkg[this_PKG] = PKG_to_pkg[this_PKG];

	do {
		if (this_PKG in PKG_to_pkg) {
			next_PKG_HASHFILE = PTXDIST_TEMPDIR "/pkghash-" this_PKG;
			if (next_PKG_HASHFILE != PKG_HASHFILE) {
				close(PKG_HASHFILE);
				PKG_HASHFILE = next_PKG_HASHFILE;
			}
			print $0 >> PKG_HASHFILE;
			break;
		}
	} while (sub(/_+[^_]+$/, "", this_PKG));

	next;
}

function write_include(this_PKG) {
	#
	# include this rules file
	#
	print "include " PKG_to_filename[this_PKG]			> DGEN_RULESFILES_MAKE;
}

function write_vars_pkg_all(this_PKG, this_pkg, prefix) {
	#
	# post install hooks
	#
	stage = "install";
	print this_PKG "_HOOK_POST_" toupper(stage) \
		" := $(STATEDIR)/" this_pkg "." stage ".post"		> DGEN_DEPS_PRE;

	#
	# archive name for devel packages
	#
	this_devpkg = "$(" this_PKG ")-$(PTXCONF_ARCH_STRING)-$(" this_PKG "_CFGHASH)-dev.tar.gz"

	#
	# define ${PKG}_PKGDIR, ${PKG}_DEVPKG & ${PKG}_SOURCES
	#
	print this_PKG "_PKGDIR = $(PKGDIR)/" prefix "$(" this_PKG ")"	> DGEN_DEPS_PRE;
	print this_PKG "_DEVPKG = " prefix this_devpkg			> DGEN_DEPS_PRE;
	print this_PKG "_SOURCES = $(" this_PKG "_SOURCE)"		> DGEN_DEPS_PRE

	target_PKG = gensub(/^HOST_|^CROSS_/, "", "", this_PKG);
	PREFIX = gensub(/^(HOST_|CROSS_).*/, "\\1", "", this_PKG);

	# define default ${PKG}, ${PKG}_SOURCE, ${PKG}_DIR
	if ((prefix != "") && (target_PKG in PKG_to_pkg)) {
		print this_PKG " = $(" target_PKG ")"			> DGEN_DEPS_PRE;
		print this_PKG "_MD5 = $(" target_PKG "_MD5)"		> DGEN_DEPS_PRE;
		print this_PKG "_SOURCE = $(" target_PKG "_SOURCE)"	> DGEN_DEPS_PRE;
		print this_PKG "_URL = $(" target_PKG "_URL)"		> DGEN_DEPS_PRE;
		print this_PKG "_DIR = $(addprefix $(" PREFIX \
			"BUILDDIR)/,$(" target_PKG "))"			> DGEN_DEPS_PRE;
	}
}

function write_deps_pkg_all(this_PKG, this_pkg) {
	#
	# .get rule
	#
	print "$(STATEDIR)/" this_pkg ".get: $(" this_PKG "_SOURCES)"	> DGEN_DEPS_POST;
}

function write_deps_pkg_active(this_PKG, this_pkg, prefix) {
	#
	# default deps
	#
	print "$(STATEDIR)/" this_pkg ".extract: "                    "$(STATEDIR)/" this_pkg ".get"		> DGEN_DEPS_POST;
	print "$(STATEDIR)/" this_pkg ".extract.post: "       "$(STATEDIR)/" this_pkg ".extract"	> DGEN_DEPS_POST;
	print "$(STATEDIR)/" this_pkg ".prepare: "            "$(STATEDIR)/" this_pkg ".extract.post"	> DGEN_DEPS_POST;
	print "$(STATEDIR)/" this_pkg ".tags: "                       "$(STATEDIR)/" this_pkg ".prepare"	> DGEN_DEPS_POST;
	print "$(STATEDIR)/" this_pkg ".compile: "                    "$(STATEDIR)/" this_pkg ".prepare"	> DGEN_DEPS_POST;
	print "$(STATEDIR)/" this_pkg ".install: "                    "$(STATEDIR)/" this_pkg ".compile"	> DGEN_DEPS_POST;
	print "$(STATEDIR)/" this_pkg ".install.pack: "               "$(STATEDIR)/" this_pkg ".install"	> DGEN_DEPS_POST;
	print "ifeq ($(strip $(wildcard $(PTXDIST_DEVPKG_PLATFORMDIR)/$(" this_PKG "_DEVPKG))),)"		> DGEN_DEPS_POST;
	print "$(STATEDIR)/" this_pkg ".install.post: "               "$(STATEDIR)/" this_pkg ".install.pack"	> DGEN_DEPS_POST;
	print "else"												> DGEN_DEPS_POST;
	print "$(STATEDIR)/" this_pkg ".install.post: "               "$(STATEDIR)/" this_pkg ".install.unpack"	> DGEN_DEPS_POST;
	print "endif"												> DGEN_DEPS_POST;
	if (prefix == "") {
		print "$(STATEDIR)/" this_pkg ".targetinstall: "      "$(STATEDIR)/" this_pkg ".install.post"	> DGEN_DEPS_POST;
		print "$(STATEDIR)/" this_pkg ".targetinstall.post: " "$(STATEDIR)/" this_pkg ".targetinstall"	> DGEN_DEPS_POST;
	}

	#
	# conditional dependencies
	#
	print "ifneq ($(" this_PKG "),)"						> DGEN_DEPS_POST;
	# on autogen script
	print "ifneq ($(call autogen_dep,$(" this_PKG ")),)"				> DGEN_DEPS_POST;
	print "$(STATEDIR)/" this_pkg ".extract.post: $(STATEDIR)/autogen-tools"	> DGEN_DEPS_POST;
	print "endif"									> DGEN_DEPS_POST;
	# on lndir
	print "ifneq ($(findstring lndir://,$(" this_PKG "_URL)),)"			> DGEN_DEPS_POST;
	print "$(STATEDIR)/" this_pkg ".extract: $(STATEDIR)/host-lndir.install.post"	> DGEN_DEPS_POST;
	print "endif"									> DGEN_DEPS_POST;
	print "endif"									> DGEN_DEPS_POST;

	#
	# add dep to pkgs we depend on
	#
	this_PKG_DEPS = PKG_to_B_DEP[this_PKG];
	n = split(this_PKG_DEPS, this_DEP_array, " ");
	for (i = 1; i <= n; i++) {
		this_dep = PKG_to_pkg[this_DEP_array[i]]

		print "$(STATEDIR)/" this_pkg	".extract.post: "     "$(STATEDIR)/" this_dep ".install.post"	> DGEN_DEPS_POST;
		print "$(STATEDIR)/" this_pkg	".install.unpack: "   "$(STATEDIR)/" this_dep ".install.post"	> DGEN_DEPS_POST;

	}
	this_PKG_DEPS = PKG_to_R_DEP[this_PKG];
	n = split(this_PKG_DEPS, this_DEP_array, " ");
	for (i = 1; i <= n; i++) {
		this_dep = PKG_to_pkg[this_DEP_array[i]]

		#
		# only target packages have targetinstall rules
		#
		if (this_dep ~ /^host-|^cross-/)
			continue;

		print "$(STATEDIR)/" this_pkg ".targetinstall: "      "$(STATEDIR)/" this_dep ".targetinstall"	> DGEN_DEPS_POST;
	}
}

#
# add deps to virtual pkgs
#
function write_deps_pkg_active_virtual(this_PKG, this_pkg, prefix) {
	if (this_pkg ~ /^host-pkg-config$/)
		return;
	if (this_pkg ~ /^host-chrpath$/)
		return;

	if (prefix != "")
		virtual = "virtual-host-tools";
	else {
		if (this_PKG in base_PKG_to_pkg || this_pkg ~ /^base$/)
			virtual = "virtual-cross-tools";
		else
			virtual = "base";
	}
	print "$(STATEDIR)/" this_pkg ".extract.post: "               "$(STATEDIR)/" virtual  ".install"	> DGEN_DEPS_POST;
	print "$(STATEDIR)/" this_pkg ".install.unpack: "             "$(STATEDIR)/" virtual  ".install"	> DGEN_DEPS_POST;
}

function write_deps_pkg_active_image(this_PKG, this_pkg, prefix) {
	print "$(" this_PKG "_IMAGE): " \
		"$(addprefix $(STATEDIR)/,$(addsuffix .targetinstall.post,$(" this_PKG "_PKGS)))"		> DGEN_DEPS_POST;
	print "$(" this_PKG "_IMAGE): "                               "$(" this_PKG "_FILES)"			> DGEN_DEPS_POST;
	print "$(STATEDIR)/" this_pkg ".install.post: "               "$(" this_PKG "_IMAGE)"			> DGEN_DEPS_POST;
	print "images: "                                              "$(" this_PKG "_IMAGE)"			> DGEN_DEPS_POST;
	#
	# add dep to pkgs we depend on
	#
	this_PKG_DEPS = PKG_to_B_DEP[this_PKG];
	n = split(this_PKG_DEPS, this_DEP_array, " ");
	for (i = 1; i <= n; i++) {
		this_dep = PKG_to_pkg[this_DEP_array[i]]
		if (this_pkg_prefix == "")
			print "$(" this_PKG "_IMAGE): "         "$(STATEDIR)/" this_dep ".targetinstall.post"	> DGEN_DEPS_POST;
		else
			print "$(" this_PKG "_IMAGE): "               "$(STATEDIR)/" this_dep ".install.post"	> DGEN_DEPS_POST;
	}
	#
	# images don't depend on world, so this is needed to extract the packages
	#
	print "ifneq ($(strip $(" this_PKG "_PKGS)),)"									> DGEN_DEPS_POST
	print "$(" this_PKG "_IMAGE):" " \
		$(STATEDIR)/host-$(call remove_quotes,$(PTXCONF_HOST_PACKAGE_MANAGEMENT)).install.post"		> DGEN_DEPS_POST
	print "endif"												> DGEN_DEPS_POST
}

END {
	# for all pkgs
	for (this_PKG in PKG_to_pkg) {
		this_pkg = PKG_to_pkg[this_PKG];
		this_pkg_prefix = gensub(/^(host-|cross-|image-|).*/, "\\1", "", this_pkg)

		write_include(this_PKG)
		if (this_pkg_prefix != "image-") {
			write_deps_pkg_all(this_PKG, this_pkg)
			write_vars_pkg_all(this_PKG, this_pkg, this_pkg_prefix)
		}
	}

	# for active pkgs
	for (this_PKG in active_PKG_to_pkg) {
		this_pkg = PKG_to_pkg[this_PKG];
		this_pkg_prefix = gensub(/^(host-|cross-|image-|).*/, "\\1", "", this_pkg)

		if (this_pkg_prefix != "image-") {
			write_deps_pkg_active(this_PKG, this_pkg, this_pkg_prefix)
			write_deps_pkg_active_virtual(this_PKG, this_pkg, this_pkg_prefix)
		}
		else
			write_deps_pkg_active_image(this_PKG, this_pkg, this_pkg_prefix)
	}

	close(PKG_HASHFILE);
	MD5SUM_CMD = "md5sum " PTXDIST_TEMPDIR "/pkghash-*";
	while (MD5SUM_CMD | getline) {
		split($0, line, "[ -]")
		print line[length(line)] "_CFGHASH = " line[1]			> DGEN_DEPS_PRE;
	}

	close(MD5SUM_CMD)
	close(MAP_ALL);
	close(MAP_ALL_MAKE);
	close(MAP_DEPS);
	close(DGEN_DEPS_PRE);
	close(DGEN_DEPS_POST);
	close(DGEN_RULESFILES_MAKE);
}
