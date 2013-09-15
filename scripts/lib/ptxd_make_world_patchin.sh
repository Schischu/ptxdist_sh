#!/bin/bash
#
# Copyright (C) 2004-2009 by the ptxdist project
#               2010 by Marc Kleine-Budde <mkl@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# ptxd_make_world_patchin_apply_init -
# initialize variables used to apply the patches
#
# out:
#
# pkg_patch_series	path to series file
# pkg_patch_tool	tool used to apply the patch series
#
ptxd_make_world_patchin_apply_init()
{
    # look for series
    if [ -n "${pkg_patch_series}" ]; then
	# check if specified series file can be found
	pkg_patch_series="${pkg_patch_dir}/${pkg_patch_series}"
	if [ \! -e "${pkg_patch_series}" ]; then
	    echo "error: specified series '${pkg_patch_series}' not found"
	    return 1
	fi
    else
	# is there a "series" file
	pkg_patch_series="${pkg_patch_dir}/series"
	if [ \! -e "${pkg_patch_series}" ]; then
	    unset pkg_patch_series
	fi
    fi

    #series exist create tmp series file

    if [ "x${pkg_patch_platform_dir}" != "x" ]; then
        pkg_patch_platform_series="${pkg_patch_platform_dir}/series"
        #echo "pkg_patch_platform_series: ${pkg_patch_platform_series}" > /dev/stderr

        if [ -e "${pkg_patch_platform_series}" ]; then
            cp ${pkg_patch_series} ${pkg_patch_platform_dir}/.series
            cat ${pkg_patch_platform_series} >> ${pkg_patch_platform_dir}/.series
            pkg_patch_series=${pkg_patch_platform_dir}/.series
        fi
    fi

    # decide which tool to use
    if [ "${PTXCONF_SETUP_PATCHIN_GIT}" ] && which git > /dev/null 2>&1; then
	pkg_patch_tool=git
    elif which quilt > /dev/null 2>&1; then
	pkg_patch_tool=quilt
    else
	pkg_patch_tool=patch
    fi
}
export -f ptxd_make_world_patchin_apply_init


#
# initialize git database in $pkg_patchin_dir and do initial commit
#
ptxd_make_world_patchin_apply_git_init()
{
    local git_dir
    git_dir="$(git rev-parse --git-dir 2> /dev/null)" || true

    # is already git repo?
    if [ "${git_dir}" != ".git" ]; then
	echo "patchin: git: initializing repository"
	git init -q &&
	git add -f . &&
	git commit -q -m "initial commit" --author="ptxdist-${PTXDIST_VERSION_FULL} <ptxdist@pengutronix.de>" &&
	git tag "${pkg_pkg//\~/-}" &&
	git tag base &&
	git config alias.ptx-patches "!${PTXDIST_TOPDIR}/scripts/git-ptx-patches \"\${@}\"" &&
	git config diff.renames false &&
	echo "patchin: git: done"
    fi
}
export -f ptxd_make_world_patchin_apply_git_init


#
# create a directory containing the patches and the selected series
# file. name that file "series".
#
# decompress "bz2", "gz" and "xz" patches on the fly
#
ptxd_make_world_patchin_apply_git_compat()
{
    mkdir "${pkg_patchin_dir}/.ptxdist/git-patches" || return

    local patch para
    while read patch para; do
	local cat
	local patch_file="${patch##*/}"

	case "${para}" in
	    ""|"#"*) para="-p1" ;;	# no para or comment
	    -p*) ;;
	esac

	case "${patch}" in
	    "#tag:"*)
		local tag="${patch##\#tag:}"
		if [ -f ${pkg_patchin_dir}/.ptxdist/git-patches/series ]; then
		    mv ${pkg_patchin_dir}/.ptxdist/git-patches/series{,.${tag}} &&
		    touch ${pkg_patchin_dir}/.ptxdist/git-patches/series
		else
		    touch ${pkg_patchin_dir}/.ptxdist/git-patches/series.${tag}
		fi
		continue
		;;
	    ""|"#"*) continue ;;	# skip empty lines and comments
	    *.gz)  cat="zcat" ;;
	    *.bz2) cat="bzcat" ;;
	    *.xz)  cat="xzcat" ;;
	    *)
		ln -s "../patches/${patch}" "${pkg_patchin_dir}/.ptxdist/git-patches/${patch_file}" &&
		echo "${patch_file}" "${para}" >> "${pkg_patchin_dir}/.ptxdist/git-patches/series" || return
		continue
		;;
	esac &&

	"${cat}" "${pkg_patchin_dir}/.ptxdist/patches/${patch}" > \
	    "${pkg_patchin_dir}/.ptxdist/git-patches/${patch_file%.*}"
	echo "${patch_file%.*}" "${para}" >> "${pkg_patchin_dir}/.ptxdist/git-patches/series" || return

    done < "${pkg_patchin_dir}/.ptxdist/series"
}
export -f ptxd_make_world_patchin_apply_git_compat


#
# apply patch series with git
#
ptxd_make_world_patchin_apply_git()
{
    #
    # git quiltimport has certain limitations, work around them
    #
    ptxd_make_world_patchin_apply_git_compat || return

    grep "\#tag:" "${pkg_patchin_dir}/.ptxdist/series" | while read tagline; do
	local tag="${tagline##\#tag:}"
	tag=$(echo ${tag}|cut -d' ' -f1)
	if [ -f "${pkg_patchin_dir}/.ptxdist/git-patches/series.${tag}" ]; then
	    mv ${pkg_patchin_dir}/.ptxdist/git-patches/series{,.1} || return
	    mv ${pkg_patchin_dir}/.ptxdist/git-patches/series{.${tag},} || return

	    git quiltimport \
		--patches "${pkg_patchin_dir}/.ptxdist/git-patches" \
		--author "unknown author <unknown.author@example.com>"
	    echo "tagging -> ${tag}"
	    git tag -f ${tag}
	    mv ${pkg_patchin_dir}/.ptxdist/git-patches/series{,.${tag}} || return
	    mv ${pkg_patchin_dir}/.ptxdist/git-patches/series{.1,} || return
	fi
    done

    git quiltimport \
	--patches "${pkg_patchin_dir}/.ptxdist/git-patches" \
	--author "unknown author <unknown.author@example.com>"
}
export -f ptxd_make_world_patchin_apply_git


#
# apply patch series with quilt
#
ptxd_make_world_patchin_apply_quilt()
{
	# Skip empty series
	if [ -n "$(cat ${pkg_patch_series_quilt} |grep -v '^[#$]')" ]; then

    QUILT_SERIES="${pkg_patch_series_quilt}" \
	QUILT_PATCHES="${pkg_patchin_dir}/.ptxdist" \
	quilt push -a || ptxd_bailout "quilt returned error"

	fi
	ln -s "${PTXDIST_TOPDIR}/scripts/quilt-export.sh" ".ptxdist/quilt-export.sh"
}
export -f ptxd_make_world_patchin_apply_quilt


#
# apply patch series with patch
#
ptxd_make_world_patchin_apply_patch()
{
    local patch para junk

    while read patch para junk; do
	local cat

	case "${patch}" in
	    ""|"#"*) continue ;;	# skip empty lines and comments
	    *.gz)    cat=zcat ;;
	    *.bz2)   cat=bzcat ;;
	    *.xz)    cat=xzcat ;;
	    *)       cat=cat ;;
	esac

	case "${para}" in
	    ""|"#"*) para="-p1" ;;	# no para or comment
	    -p*) ;;
	esac

	echo "applying '${patch}'"
	patch_abs="${pkg_patchin_dir}/.ptxdist/patches/${patch}"
	if [ \! -f "${patch_abs}" ]; then
	   patch_abs="${pkg_patchin_dir}/.ptxdist/patches_platform/${patch}"
	fi &&
	"${cat}" "${patch_abs}" | patch "${para}" -N -d "${pkg_patchin_dir}" &&
	check_pipe_status || return

    done < "${pkg_patchin_dir}/.ptxdist/series" &&
    unset patch para junk
}
export -f ptxd_make_world_patchin_apply_patch


#
# generic apply patch series function
#
ptxd_make_world_patchin_apply()
{
    local \
	pkg_patch_series \
	pkg_patch_tool

    ptxd_make_world_patchin_apply_init || return
    if [ -z "${pkg_patch_dir}" ]; then
	return
    fi &&

    if [ "${pkg_patch_tool}" = "git" ]; then
	ptxd_make_world_patchin_apply_git_init || return
    fi &&

    #
    # the primary reference is the ".ptxdist" folder in the pkg_patchin_dir:
    # these files might be existent:
    #
    # patches	link, pointing to the dir containing the pkg's patches
    # series	usually link, pointing to the used series file
    #		if no series file is supplied and the folder
    #		containing the patches is not writable, this will be a
    #		file
    #
    if [ -e "${pkg_patchin_dir}/.ptxdist" ]; then
	ptxd_bailout "pkg_patchin_dir '${pkg_patchin_dir}' already contains a '.ptxdist' folder"
    fi &&
    mkdir "${pkg_patchin_dir}/.ptxdist" &&

    #
    # create a ".ptxdist/patches" link pointing to the directory
    # containing the patches
    #
    ln -s "${pkg_patch_dir}" "${pkg_patchin_dir}/.ptxdist/patches" &&

    if [ "x${pkg_patch_platform_dir}" != "x" ]; then
        if [ -d "${pkg_patch_platform_dir}" ]; then
            ln -s "${pkg_patch_platform_dir}" "${pkg_patchin_dir}/.ptxdist/patches_platform"
        fi
    fi &&

    # link series file - if not available create it
    if [ -z "${pkg_patch_series}" ]; then

	ptxd_pedantic "series file for '$(ptxd_print_path "${pkg_patch_dir}")' is missing"

	# if writable, create series file next to the patches
	if [ -w "${pkg_patch_dir}/" ]; then
	    pkg_patch_series="${pkg_patch_dir}/series" &&
	    ln -s "${pkg_patch_series}" "${pkg_patchin_dir}/.ptxdist/series"
	else
	    pkg_patch_series="${pkg_patchin_dir}/.ptxdist/series"
	fi &&

	#
	# look for patches (and archives) and put into series file
	# (the "sed" removes "./" from find's output)
	#
	pushd "${pkg_patch_dir}/" >/dev/null &&
	find \
	    -name "*.diff" -o \
	    -name "*.patch" -o \
	    -name "*.xz" -o \
	    -name "*.bz2" -o \
	    -name "*.gz" | \
	    sed -e "s:^[.]/::" | sort > \
	    "${pkg_patch_series}" &&
	popd > /dev/null

	# no patches found
	if [ \! -s "${pkg_patch_series}" ]; then
	    rm -f \
		"${pkg_patchin_dir}/.ptxdist/series" \
		"${pkg_patch_series}" &&
	    unset pkg_patch_series
	fi
    else
	ln -s "${pkg_patch_series}" "${pkg_patchin_dir}/.ptxdist/series"

	# create new series file for quilt
	if [ -w "${pkg_patch_dir}/" ]; then
		pkg_patch_series_quilt="${pkg_patch_dir}/series.quilt" &&
		ln -s "${pkg_patch_series_quilt}" "${pkg_patchin_dir}/.ptxdist/series.quilt"
	else
		pkg_patch_series_quilt="${pkg_patchin_dir}/.ptxdist/series.quilt"
	fi
	cat /dev/null > "${pkg_patch_series_quilt}"

	#
	# check for non existing patches
	#
	# Some tools like "git" skip non existing patches without an
	# error. In ptxdist we consider this a fatal error.
	#
	local patch prefixed para junk
	while read patch tmp; do
	    case "${patch}" in
		"")
			echo "" >> "${pkg_patch_series_quilt}"
			continue ;;	# skip empty lines and comments
		"#"*)
				echo "${patch} ${tmp}" >> "${pkg_patch_series_quilt}"
			continue ;;	# skip empty lines and comments
		*) ;;
	    esac

	    case "${para}" in
		""|"#"*) ;;		# no para or comment
		-p*) ;;
		*) ptxd_bailout "invalid parameter to patch '${patch}' in series file '${pkg_patch_series}'"
	    esac

 	    prefixed="patches/${patch}"
	    if [ \! -f "${pkg_patchin_dir}/.ptxdist/patches/${patch}" ]; then
 	        prefixed="patches_platform/${patch}"
	        if [ \! -f "${pkg_patchin_dir}/.ptxdist/patches_platform/${patch}" ]; then
	            ptxd_bailout "cannot find patch: '${patch}' specified in series file '${pkg_patch_series}'"
	        fi
	    fi
	    echo "${prefixed}" >> "${pkg_patch_series_quilt}"

	done < "${pkg_patchin_dir}/.ptxdist/series" &&
	unset patch prefixed para junk
    fi || return

    #
    # setup convenience links
    #
    # series
    if [ -e "${pkg_patchin_dir}/.ptxdist/series" ]; then
	if [ -e "${pkg_patchin_dir}/series" ]; then
	    ptxd_bailout "there's a 'series' file in the pkg_patchin_dir"
	fi
	ln -sf ".ptxdist/series" "${pkg_patchin_dir}/series"
    fi &&

    # patches
    if [ \! -e "${pkg_patchin_dir}/patches" ]; then
	ln -sf ".ptxdist/patches" "${pkg_patchin_dir}/patches"
    fi || return
    if [ \! -e "${pkg_patchin_dir}/patches_platform" ]; then
	ln -sf ".ptxdist/patches_platform" "${pkg_patchin_dir}/patches_platform"
    fi || return

    echo
    echo "pkg_patch_dir:          '$(ptxd_print_path "${pkg_patch_dir:-<none>}")'"
    echo "pkg_patch_platform_dir: '$(ptxd_print_path "${pkg_patch_platform_dir:-<none>}")'"
    echo "pkg_patch_series:       '$(ptxd_print_path "${pkg_patch_series:-<none>}")'"
    echo

    # apply patches if series file is available
    if [ -n "${pkg_patch_series}" ]; then
	echo    "patchin: ${pkg_patch_tool}: apply '$(ptxd_print_path ${pkg_patch_series})'"
	"ptxd_make_world_patchin_apply_${pkg_patch_tool}" || return
	echo -e "patchin: ${pkg_patch_tool}: done\n"
    fi
}
export -f ptxd_make_world_patchin_apply


#
#
#
ptxd_make_world_patchin_fixup()
{
    local file

    echo "patchin: fixup:"
    find "${pkg_patchin_dir}/" -name "configure" -a -type f -a \! -path "*/.pc/*" | while read file; do
	ptxd_print_path "${file}"
	#
	# the first fixes a problem with libtool on blackfin:
	# - on blackfin they've got symbols with more "_" prefixes than on other platforms
	# - teach libtool to cope with it
	#
	# the second one supresses the adding of "rpath"
	#
	sed -i \
	    -e "s=sed -e \"s/\\\\(\.\*\\\\)/\\\\1;/\"=sed -e \"s/\\\\(.*\\\\)/'\"\$ac_symprfx\"'\\\\1;/\"=" \
	    \
	    -e "s:^\(hardcode_into_libs\)=.*:\1=\"no\":" \
	    -e "s:^\(hardcode_libdir_flag_spec\)=.*:\1=\"\":" \
	    -e "s:^\(hardcode_libdir_flag_spec_ld\)=.*:\1=\"\":" \
	    "${file}" || return
    done &&

    find "${pkg_patchin_dir}/" -name "ltmain.sh" -a -type f -a \! -path "*/.pc/*" | while read file; do
	ptxd_print_path "${file}"
	#
	# this sed turns of the relinking during "make install" (it
	# might pick up libs from the host or break otherwise, we
	# don't need it on linux anyway)
	#
 	sed -i \
 	    -e "s:\(need_relink\)=yes:\1=\"no\":" \
 	    "${file}" || return
    done &&

    echo -e "patchin: fixup: done\n"
}
export -f ptxd_make_world_patchin_fixup

#
#
#
ptxd_make_world_autogen() {
    # look for autogen.sh
    local pkg_patch_autogen="${pkg_patch_dir}/autogen.sh"
    if [ ! -x "${pkg_patch_autogen}" ]; then
	unset pkg_patch_autogen
    fi

    echo "pkg_patch_autogen: '$(ptxd_print_path "${pkg_patch_autogen:-<none>}")'"
    echo

    # run autogen.sh if available
    if [ -n "${pkg_patch_autogen}" ]; then
	"${pkg_patch_autogen}" || return
	echo -e "patchin: autogen: done\n"
    fi
}
export -f ptxd_make_world_autogen


#
# ptxd_make_world_patchin_init -
# initialize variables used to apply the patches
#
# out:
#
# pkg_patchin_dir	where to apply the patches
# pkg_patch_dir		path to dir that contains the patches
#			empty if no patches should be applied
#
ptxd_make_world_patchin_init()
{
    ptxd_make_world_init || return

    if [ -z "${pkg_url}" -a -z "${pkg_src}" ]; then
	# no <PKG>_URL and no <PKG>_SOURCE -> assume the package has nothing to patchin.
	return
    fi

    if [ -n "${pkg_deprecated_patchin_series}" ]; then
	ptxd_bailout "a 3rd parameter to patchin ('${pkg_deprecated_patchin_series}') is obsolete, please define <PKG>_SERIES instead"
    fi

    pkg_patchin_dir=${pkg_deprecated_patchin_dir:-${pkg_dir}}

    #
    # FIXME: do we still need this check?
    #
    case "${pkg_url}" in
	file://)
	    local dir="${pkg_url#file://}"
	    if [ -d "${dir}" -a "${pkg_label}" != "kernel" ]; then
		echo "local directory instead of tar file, skipping patch"
	    fi
	    ;;
    esac

    #
    # find patch_dir
    # for compatibility, look first in 'generic', then in standard
    # location
    #
    if ! ptxd_in_path PTXDIST_PATH_PATCHES ${pkg_pkg}/generic &&
		! ptxd_in_path PTXDIST_PATH_PATCHES ${pkg_pkg} ; then
	return
    fi
    pkg_patch_dir="${ptxd_reply}"

    if [ -e "${PTXDIST_PLATFORMCONFIG}" ]; then
        pkg_patch_platform_dir=`readlink -e ${PTXDIST_PLATFORMCONFIG}`
        pkg_patch_platform_dir="`dirname ${pkg_patch_platform_dir}`/patches/${pkg_pkg}"
    else
        pkg_patch_platform_dir=""
    fi
}
export -f ptxd_make_world_patchin_init

ptxd_make_world_patchin()
{
    ptxd_make_world_patchin_init || return

    if [ -n "${pkg_patch_dir}" ]; then (
	cd "${pkg_patchin_dir}" &&
	ptxd_make_world_patchin_apply
     ) else
	echo -e "patchin: no patches found"
    fi
}
export -f ptxd_make_world_patchin

ptxd_make_world_patchin_post() {
    ptxd_make_world_patchin_init || return

    if [ -n "${pkg_patchin_dir}" ]; then (
	cd "${pkg_patchin_dir}" &&
	if [ -n "${pkg_patch_dir}" ]; then
	    ptxd_make_world_autogen
	fi &&

	if [ "${pkg_type}" = "target" ]; then
	    ptxd_make_world_patchin_fixup
	fi
    ) fi
}
export -f ptxd_make_world_patchin_post
