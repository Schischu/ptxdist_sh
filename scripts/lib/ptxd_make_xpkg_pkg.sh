#!/bin/bash
#
# Copyright (C) 2010 by Michael Olbrich <m.olbrich@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

ptxd_exist() {
    for file in "${@}"; do
	if [ ! -e "${file}" ]; then
	    echo -e "\nError: file not found: ${file}\n"
	    return 1
	fi
    done
}
export -f ptxd_exist

ptxd_install_error() {
	echo Error: "$@"
	exit 1
}
export -f ptxd_install_error

#
# ptxd_install_getent_id
#
# convert usr or grp into numeric value
#
# $1: "usr", "grp"
#
ptxd_install_getent_id() {
    local key="${1}"
    local db id

    case "${key}" in
	usr)
	    id="user id"
	    db="/etc/passwd"
	    ;;
	grp)
	    id="group id"
	    db="/etc/group"
	    ;;
    esac

    eval ${key}_name='\(${!key}\)'

    if ! ptxd_get_alternative "projectroot" "${db}"; then
	ptxd_bailout "

  Unable to find '${db}'.

"
    fi

    local line
    if ! line="$(grep -e "^${!key}" "${ptxd_reply}")"; then
	ptxd_bailout "

${id} '${!key}' not found in '$(ptxd_print_path ${ptxd_reply})' for:
  '${dst:-${dir}}'

"
    fi
    local orig_IFS="${IFS}"
    local IFS=":"
    set -- $line
    IFS="${orig_IFS}"
    eval ${key}="${3}"
}
export -f ptxd_install_getent_id

#
# ptxd_install_resolve_usr_grp
#
# convert usr/grp that contain names into numeric values
#
ptxd_install_resolve_usr_grp() {
    if ! [ 0 -le $usr ] 2>/dev/null; then
	ptxd_install_getent_id usr || return
    else
	unset usr_name
    fi
    if ! [ 0 -le $grp ] 2>/dev/null; then
	ptxd_install_getent_id grp || return
    else
	unset grp_name
    fi
}
export -f ptxd_install_resolve_usr_grp

ptxd_install_setup() {
    case "${dst}" in
	/*|"") ;;
	*) ptxd_bailout "'dst' must be an absolute path!" ;;
    esac

    # all dirs
    dirs=("${ptx_nfsroot}" "${ptx_nfsroot_dbg}" "${pkg_xpkg_tmp}")

    # nfs root dirs
    # no setuid/setguid bit here
    ndirs=("${ptx_nfsroot}" "${ptx_nfsroot_dbg}")

    # package dirs
    # this goes into the ipkg, thus full file modes here
    pdirs=("${pkg_xpkg_tmp}")

    # strip dirs
    sdirs=("${ptx_nfsroot}" "${pkg_xpkg_tmp}")

    mod_nfs="$(printf "0%o" $(( 0${mod} & ~06000 )))" &&
    mod_rw="$(printf "0%o" $(( 0${mod} | 0200 )))" &&

    #
    # mangle user/group
    #
    ptxd_install_resolve_usr_grp
}
export -f ptxd_install_setup

ptxd_install_setup_src() {
    ptxd_install_setup || return

    if [ "${src}" = "-" -a -n "${dst}" ]; then
	src="${pkg_pkg_dir}${dst}"
    fi

    local -a list

    if [ "${cmd}" = "alternative" -o "${cmd}" = "config" ]; then
	#
	# if pkg_dir is empty we'll have some some empty entries in
	# the array, but that's no problem for the "-e" below.
	#
	list=( \
	    "${PTXDIST_WORKSPACE}/projectroot${PTXDIST_PLATFORMSUFFIX}${src}" \
	    "${PTXDIST_WORKSPACE}/projectroot${src}${PTXDIST_PLATFORMSUFFIX}" \
	    "${PTXDIST_PLATFORMCONFIGDIR}/projectroot${src}${PTXDIST_PLATFORMSUFFIX}" \
	    "${PTXDIST_WORKSPACE}/projectroot${src}" \
	    "${PTXDIST_PLATFORMCONFIGDIR}/projectroot${src}" \
	    "${PTXDIST_TOPDIR}/generic${src}" \
	    "${pkg_pkg_dir:+${pkg_pkg_dir}${src}}" \
	    "${pkg_dir:+${pkg_dir}${src}}" \
	    )
    else
	list=( \
	    "${src}${PTXDIST_PLATFORMSUFFIX}" \
	    "${src}" \
	    )
    fi
    # Since the dependency to the source files is dynamic we store
    # the dependency information in a dependency file that can be
    # included in the make files itself.
    # We depend on the first available file, which is the one that will
    # be used. If one with a higher priority is created, the dependency
    # will cause the package to be recreated.
    local deprule=""
    for src in "${list[@]}"; do
	# don't provide dependencies for files in PTXDIST_PLATFORMDIR.
	if [ "${src}" == "${src#${PTXDIST_PLATFORMDIR}}" -a -n "${src}" ]; then
		deprule="${deprule} ${src}"
	fi
    done
    if [ -n "${deprule}" ]; then
	deprule="${ptx_state_dir}/${pkg_stamp}: \$(firstword \$(wildcard ${deprule}))"
	# Make the deps rule robust for varying installation paths, and
	# make the deps rules file more readable.
	deprule=${deprule//${PTXDIST_TOPDIR}/\$(PTXDIST_TOPDIR)}
	deprule=${deprule//${PTXDIST_WORKSPACE}/\$(PTXDIST_WORKSPACE)}
	echo "${deprule}" >> ${pkg_xpkg_install_deps}
    fi
    if ptxd_get_path "${list[@]}"; then
	src="${ptxd_reply}"
	return
    fi

    echo -e "\nNo suitable file '${dst}' could be found in any of these locations:"
    local orig_IFS="${IFS}"
    local IFS="
"
    echo -e "${list[*]}\n"
    IFS="${orig_IFS}"
}
export -f ptxd_install_setup_src

ptxd_install_dir() {
    local dir="$1"
    local usr="$2"
    local grp="$3"
    local mod="$4"
    local -a dirs ndirs pdirs sdirs
    local mod_nfs mod_rw

    ptxd_install_setup &&
    echo "\
install directory:
  dir=${dir}
  owner=${usr} ${usr_name}
  group=${grp} ${grp_name}
  permissions=${mod}
" &&

    install -m "${mod_nfs}" -d "${ndirs[@]/%/${dir}}" &&
    install -m "${mod}" -o "${usr}" -g "${grp}" -d "${pdirs[@]/%/${dir}}" &&

    echo "f:${dir}:${usr}:${grp}:${mod}" >> "${pkg_xpkg_perms}" ||
    ptxd_install_error "install_dir failed!"
}
export -f ptxd_install_dir


#
# $@: files to strip
#
# $strip: k for kernel modules
#         y for normal executables and libraries
#
#
ptxd_install_file_strip() {
    local -a strip_cmd

    case "${strip:-y}" in
	k) strip_cmd=( "${CROSS_STRIP}" --strip-debug ) ;;
	y) strip_cmd=( "${CROSS_STRIP}" -R .note -R .comment -R .GCC.command.line ) ;;
    esac

    #
    # create hardlink so that inode stays the same during strip
    # (fixes 64 bit fakeroot <-> 32 bit strip issue)
    #
    local tmp="strip"
    local file
    for file in "${@}"; do
	ln -f "${file}" "${file}.${tmp}" || return
    done &&

    "${strip_cmd[@]}" "${@}" &&
    rm -f "${@/%/.${tmp}}"
}
export -f ptxd_install_file_strip


ptxd_install_file_impl() {
    local src="$1"
    local dst="$2"
    local usr="$3"
    local grp="$4"
    local mod="$5"
    local strip="$6"
    local -a dirs ndirs pdirs sdirs
    local mod_nfs mod_rw

    ptxd_install_setup_src &&
    echo "\
install ${cmd}:
  src=$(ptxd_print_path "${src}")
  dst=${dst}
  owner=${usr} ${usr_name}
  group=${grp} ${grp_name}
  permissions=${mod}
" &&

    ptxd_exist "${src}" &&
    rm -f "${dirs[@]/%/${dst}}" &&

    # check if src is a link
    if [ -L "${src}" ]; then
	ptxd_pedantic "file '$(ptxd_print_path "${src}")' is a link" &&
	src="$(readlink -f "${src}")" &&
	echo "using '$(ptxd_print_path "${src}")' instead"
    fi &&

    # just install with r/w permissions for now
    for d in "${dirs[@]/%/${dst}}"; do
	install -m "${mod_rw}" -D "${src}" "${d}" || return
    done &&

    case "${strip}" in
	0|n|no|N|NO) ;;
	y|k|"")
	    if readelf -h "${src}" > /dev/null 2>&1; then
		ptxd_install_file_strip "${sdirs[@]/%/${dst}}"
	    fi
	    ;;
	*)
	    if [ "${strip:0:1}" = "/" ] && \
		[ "${cmd}" = "alternative" -o "${cmd}" = "config" ]; then
		ptxd_bailout "
the 6th parameter of 'install_${cmd}' is strip, not the destination.
Usually, just remove the 6th parameter and everything works fine.
"
	    fi
	    ptxd_bailout "${FUNCNAME}: invalid value for strip ('${strip}')"
	    ;;
    esac &&

    # now change to requested permissions
    chmod "${mod_nfs}" "${ndirs[@]/%/${dst}}" &&
    chmod "${mod}"     "${pdirs[@]/%/${dst}}" &&

    # now change to requested user and group
    chown "${usr}:${grp}" "${pdirs[@]/%/${dst}}" &&

    echo "f:${dst}:${usr}:${grp}:${mod}" >> "${pkg_xpkg_perms}"
}
export -f ptxd_install_file_impl

ptxd_install_ln() {
    local src="$1"
    local dst="$2"
    local usr="${3:-0}"
    local grp="${4:-0}"
    local -a dirs ndirs pdirs sdirs
    local mod_nfs mod_rw rel

    ptxd_install_setup &&
    echo "\
install link:
  src=${src}
  dst=${dst}
" &&

    case "${src}" in
	/*)
	    if [ "${PTXCONF_SETUP_NFS_REL_SYMLINK}" = "y" ]; then
		rel="$(dirname "${dst}" | sed -e 's,/[^/]*,/..,g' -e 's,^/,,')"
	    fi
	    ;;
	*)  ;;
    esac &&

    rm -f "${dirs[@]/%/${dst}}" &&
    install -d "${dirs[@]/%/$(dirname "${dst}")}" &&
    for d in "${ndirs[@]/%/${dst}}"; do
	ln -s "${rel}${src}" "${d}" || return
    done &&
    for d in "${pdirs[@]/%/${dst}}"; do
	ln -s "${src}" "${d}" || return
    done &&

    chown --no-dereference "${usr}:${grp}" "${dirs[@]/%/${dst}}"
}
export -f ptxd_install_ln

ptxd_install_mknod() {
    local dst="$1"
    local usr="$2"
    local grp="$3"
    local mod="$4"
    local type="$5"
    local major="$6"
    local minor="$7"
    local -a dirs ndirs pdirs sdirs
    local mod_nfs mod_rw

    ptxd_install_setup &&
    echo "\
install device node:
  owner=${usr}
  group=${grp}
  permissions=${mod}
  type=${type}
  major=${major}
  minor=${minor}
  name=${dst}
" &&

    rm -f "${pdirs[@]/%/${dst}}" &&
    install -d "${dirs[@]/%/$(dirname "${dst}")}" &&
    for d in "${pdirs[@]/%/${dst}}"; do
	mknod -m "${mod}" "${d}" "${type}" ${major} ${minor} || return
    done &&
    chown "${usr}:${grp}" "${pdirs[@]/%/${dst}}" &&

    echo "n:${dst}:${usr}:${grp}:${mod}:${type}:${major}:${minor}" >> "${pkg_xpkg_perms}"
}
export -f ptxd_install_mknod

ptxd_install_alternative() {
    local cmd="alternative"
    local src="${1}"
    local dst="${2}"
    shift 2
    ptxd_install_file_impl "${src}" "${dst:-${src}}" "${@}" ||
    ptxd_install_error "install_alternative failed!"
}
export -f ptxd_install_alternative

ptxd_install_config() {
    local cmd="config"
    local src="${1}"
    local dst="${2}"
    shift 2
    ptxd_install_file_impl "${src}" "${dst:-${src}}" "${@}" &&
    # this is a config file add it to conffiles so it's handled correctly
    echo "${dst:-${src}}" >> "${pkg_xpkg_conffiles}" &&
    chown 0:0 "${pkg_xpkg_conffiles}" ||
    ptxd_install_error "install_config failed!"
}
export -f ptxd_install_config

ptxd_install_file() {
    local cmd="file"
    ptxd_install_file_impl "$@" ||
    ptxd_install_error "install_file failed!"
}
export -f ptxd_install_file

ptxd_install_link() {
    ptxd_install_ln "$@" ||
    ptxd_install_error "install_link failed!"
}
export -f ptxd_install_link

ptxd_install_node() {
    ptxd_install_mknod "$@" ||
    ptxd_install_error "install_node failed!"
}
export -f ptxd_install_node

ptxd_install_replace() {
    local dst="$1"
    local placeholder="$2"
    local value="$3"
    local -a dirs ndirs pdirs sdirs
    local mod_nfs mod_rw

    ptxd_install_setup &&
    echo "\
install replace:
  file=${dst}
  '${placeholder}' -> '${value}'
" &&

    ptxd_exist "${dirs[@]/%/${dst}}" &&
    sed -i -e "s,${placeholder},${value},g" "${dirs[@]/%/${dst}}" ||

    ptxd_install_error "install_replace failed!"
}
export -f ptxd_install_replace

ptxd_install_script_replace() {
    local dst="$1"
    local placeholder="$2"
    local value="$3"

    echo "\
install script replace:
  script=${dst}
  '${placeholder}' -> '${value}'
" &&

    ptxd_exist "${pkg_xpkg_control_dir}/${dst}" &&
    sed -i -e "s,${placeholder},${value},g" "${pkg_xpkg_control_dir}/${dst}" ||

    ptxd_install_error "install_script_replace failed!"
}
export -f ptxd_install_script_replace

ptxd_install_replace_figlet() {
    local dst="$1"
    local placeholder="$2"
    local value="$3"
    local -a dirs ndirs pdirs sdirs
    local mod_nfs mod_rw

    ptxd_install_setup &&
    echo "\
install replace figlet:
  file=${dst}
  '${placeholder}' -> '\`figlet ${value}\`'
" &&

    ptxd_exist "${dirs[@]/%/${dst}}" &&
    figlet="$(figlet -d "${PTXDIST_SYSROOT_HOST}/share/figlet" -- "${value}" | \
	awk '{ gsub("\\\\", "`"); if ($0 !~ "^ *$") printf("%s\\n", $0) }')" && #`
    sed -i -e "s#${placeholder}#${figlet}#g" "${dirs[@]/%/${dst}}" ||

    ptxd_install_error "install_replace failed!"
}
export -f ptxd_install_replace_figlet

ptxd_install_generic() {
    local file="$1"
    local dst="$2"
    local usr="$3"
    local grp="$4"
    local strip="$5"

    local -a stat
    stat=( $(stat -c "%u %g %a 0x%t 0x%T" "${file}") ) &&
    local usr="${usr:-${stat[0]}}" &&
    local grp="${grp:-${stat[1]}}" &&
    local mod="${stat[2]}" &&
    local major="${stat[3]}" &&
    local minor="${stat[4]}" &&
    local type="$(stat -c "%F" "${file}")" &&

    case "${type}" in
        "directory")
	    ptxd_install_dir "${dst}" "${usr}" "${grp}" "${mod}"
	    ;;
        "character special file")
	    ptxd_install_mknod "${dst}" "${usr}" "${grp}" "${mod}" c "${major}" "${minor}"
	    ;;
        "block special file")
	    ptxd_install_mknod "${dst}" "${usr}" "${grp}" "${mod}" b "${major}" "${minor}"
	    ;;
        "symbolic link")
	    local src="$(readlink "${file}")" &&
	    ptxd_install_ln "${src}" "${dst}" "${usr}" "${grp}"
	    ;;
        "regular file"|"regular empty file")
	    ptxd_install_file "${file}" "${dst}" "${usr}" "${grp}" "${mod}" "${strip}"
	    ;;
        *)
	    echo "Error: File type '${type}' unkown!"
	    return 1
	    ;;
    esac
}
export -f ptxd_install_generic

ptxd_install_find() {
    local src="${1%/}"
    local dst="${2%/}"
    local usr="${3#-}"
    local grp="${4#-}"
    local strip="${5}"

    ptxd_install_setup_src &&
    test -d "${src}" &&

    find "${src}" -path "*/.svn" -prune -o -path "*/.git" -prune -o \
		-path "*/.pc" -prune -o -path "*/CVS" -prune -o \
		! -path "${src}" -print | while read file; do
	local dst_file="${dst}${file#${src}}"
	ptxd_install_generic "${file}" "${dst_file}" "${usr}" "${grp}" "${strip}" || return
    done
}
export -f ptxd_install_find

ptxd_install_tree() {
    local cmd="file"
    local src="${1}"
    local dst="${2}"
    shift 2
    ptxd_install_find "${src}" "${dst}" "$@" ||
    ptxd_install_error "install_tree failed!"
}
export -f ptxd_install_tree

ptxd_install_alternative_tree() {
    local cmd="alternative"
    local src="${1}"
    local dst="${2}"
    shift 2
    ptxd_install_find "${src}" "${dst:-${src}}" "$@" ||
    ptxd_install_error "install_alternative_tree failed!"
}
export -f ptxd_install_alternative_tree

ptxd_install_archive() {
    local archive="$1"
    shift

    local dir="$(mktemp -d "${PTXDIST_TEMPDIR}/install_archive.XXXXXX")" &&

    ptxd_make_extract_archive "${archive}" "${dir}" &&
    ptxd_install_find "${dir}" "$@" &&

    rm -rf "${dir}" ||

    ptxd_install_error "install_archive failed!"
}
export -f ptxd_install_archive

#
# $1: path to spec file
#
# From linux/Documentation/filesystems/ramfs-rootfs-initramfs.txt:
#
#   file  <name> <location> <mode> <uid> <gid> [<hard links>]
#   dir   <name> <mode> <uid> <gid>
#   nod   <name> <mode> <uid> <gid> <dev_type> <maj> <min>
#   slink <name> <target> <mode> <uid> <gid>
#   pipe  <name> <mode> <uid> <gid>
#   sock  <name> <mode> <uid> <gid>
#
ptxd_install_spec() {
    local specfile="${1}"
    local type args
    local orig_IFS="${IFS}"

    ptxd_exist "${specfile}"

    while read type args; do
	set -- ${args}
	case "${type}" in
	    "file")
		local name="$1"
		local location="$2"
		local mode="$3"
		local uid="$4"
		local gid="$5"

		case "${location}" in
		    /*)
			ptxd_install_file "${location}" "${name}" "${uid}" "${gid}" "${mode}"
			;;
		    *)
			ptxd_install_alternative "/${location}" "${name}" "${uid}" "${gid}" "${mode}"
			;;
		esac
		;;

	    "dir")
		local name="$1"
		local mode="$2"
		local uid="$3"
		local gid="$4"

		ptxd_install_dir "${name}" "${uid}" "${gid}" "${mode}"
		;;

	    "nod")
		local name="$1"
		local mode="$2"
		local uid="$3"
		local gid="$4"
		local dev_type="$5"
		local maj="$6"
		local min="$7"

		ptxd_install_node "${name}" "${uid}" "${gid}" "${mode}" "${dev_type}" "${maj}" "${min}"
		;;

	    "slink")
		local name="$1"
		local target="$2"
		local mode="$3"
		local uid="$4"
		local gid="$5"

		ptxd_install_link "${name}" "${target}" "${uid}" "${gid}"
		;;

	    "pipe"|"sock")
		ptxd_install_error "${type} not supported: ${type} ${args}"
		;;

	    \#*|"")
		;;
	    *)
		ptxd_install_error "Unknown type ${type}"
		;;
	esac
    done < "${specfile}"
}
export -f ptxd_install_spec

ptxd_install_package() {
    local lib_dir=$(ptxd_get_lib_dir)

    for dir in "${pkg_pkg_dir}/"{,usr/}{bin,sbin,libexec}; do
	find "${dir}" \( -type f -o -type l \) \
		    -perm /111 2>/dev/null | while read file; do
	    ptxd_install_generic - "${file#${pkg_pkg_dir}}" ||
	    ptxd_install_error "install_package failed!"
	done
    done

    for dir in "${pkg_pkg_dir}/"{,usr/}${lib_dir}; do
	find "${dir}" \( -type f -o -type l \) \
		    -a -name "*.so*" 2>/dev/null | while read file; do
	    ptxd_install_generic - "${file#${pkg_pkg_dir}}" ||
	    ptxd_install_error "install_package failed!"
	done
    done
}
export -f ptxd_install_package

ptxd_install_shared() {
    local src="$1"
    local dst="$2"
    local usr="$3"
    local grp="$4"
    local mod="$5"
    local filename="$(basename "${src}")"

    ptxd_install_file "${src}" "${dst}/${filename}" "${usr}" "${grp}" "${mod}" &&

    find -H "$(dirname "${src}")" -maxdepth 1 -type l | while read file; do
	if [ "$(basename "$(readlink -f "${file}")")" = "${filename}" ]; then
	    local link="${dst}/$(basename "${file}")"
	    ptxd_install_ln "${filename}" "${link}" "${usr}" "${grp}" || return
	fi
    done
}
export -f ptxd_install_shared

ptxd_install_lib() {
    local lib_dir=$(ptxd_get_lib_dir)
    local lib="$1"
    shift

    local file="$(for dir in "${pkg_pkg_dir}/"{,usr/}${lib_dir}; do
	    find "${dir}" -type f -path "${dir}/${lib}.so*"; done 2>/dev/null)"

    if [ ! -f "${file}" ]; then
	ptxd_install_error "ptxd_lib_install: cannot find library '${lib}'!"
    fi

    local dst="$(dirname "${file#${pkg_pkg_dir}}")" &&
    ptxd_install_shared "${file}" "${dst}" "${@}" ||
    ptxd_install_error "ptxd_install_lib failed!"
}
export -f ptxd_install_lib

ptxd_install_run() {
    local script="${pkg_xpkg_control_dir}/${1}"

    if [ -e "${script}" ]; then
	echo "\
executing '${pkg_label}.${1}'
"
	DESTDIR="${ptx_nfsroot}" /bin/sh "${script}" &&
	DESTDIR="${ptx_nfsroot_dbg}" /bin/sh "${script}"
    fi ||
    ptxd_install_error "running '${1}' script failed!"
}
export -f ptxd_install_run

ptxd_make_xpkg_pkg() {
    local pkg_xpkg_tmp="$1"
    local pkg_xpkg_cmds="$2"
    local pkg_xpkg_perms="$3"

    . "${pkg_xpkg_cmds}"
}
export -f ptxd_make_xpkg_pkg
