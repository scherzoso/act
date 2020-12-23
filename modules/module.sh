#! /usr/bin/env sh
# SPDX-License-Identifier: 0BSD
# -----------------------------------------------------------------------------

##
# module.sh
#
# Usage: . "./modules/module.sh" [<module-name>]
#
# This script is _not_ a module on its own and therefore should not be made
# executable. The purpose of this script is to provide common functions for
# POSIX sh(1)-based modules.
#
# NOTE: The modules included with act(1) are self contained; they do not depend
#       on this script. This is provided as a way to avoid writing redundant
#       code in your own modules.
##

: "${ACT_VERBOSE:="n"}"
: "${ACT_MODULE_NAME:="${1:-"${0##*/}"}"}"

##
# _do_printf <fmt> [<fmt-arg>]...
_do_printf()
{
	_do_printf_fmt="${1}"
	shift

	# shellcheck disable=SC2059
	printf "%s: ${_do_printf_fmt}\\n" "${ACT_MODULE_NAME}" "${@}" >&2
}

##
# checkyn <str-bool>
checkyn()
{
	case "${1}" in
	[Yy1]|[Yy][Ee][Ss])
		return 0
		;;
	[Nn0]|[Nn][Oo])
		return 1
		;;
	*)
		return 2
		;;
	esac
}

##
# msg <fmt> [<fmt-arg>]...
msg()
{
	_do_printf "${@}"
}

##
# vmsg <fmt> [<fmt-arg>]...
vmsg()
{
	if checkyn "${ACT_VERBOSE}"; then
		msg "${@}"
	fi
}

##
# fatal <fmt> [<fmt-arg>]...
fatal()
{
	_fatal_fmt="${1}"
	shift

	_do_printf "fatal: ${_fatal_fmt}" "${@}"
	exit 1
}

##
# module [-v] <module-name> [<module-arg>]...
#
# Execute <module-name> if it exists. With -v, print the path to <module-name>
# but do not execute it.
module()
{
	_module_OPTARG="${OPTARG}"
	_module_OPTIND="${OPTIND}"
	OPTARG=""
	OPTIND=1

	_module_print="n"
	_module_ret=2

	while getopts ":v" opt; do
		case "${opt}" in
		v)
			_module_print="y"
			;;
		*)
			printf "module: invalid option: -%s\\n" "${OPTARG}" >&2
			_module_fail="y"
			;;
		esac
	done
	shift "$((OPTIND - 1))"

	if ! checkyn "${_module_fail}" && [ -x "./modules/${1}" ]; then
		if checkyn "${_module_print}"; then
			printf "%s\\n" "./modules/${1}"
			_module_ret=0
		else
			_module_cmd="./modules/${1}"
			shift

			"${_module_cmd}" "${@}"
			_module_ret="${?}"
		fi
	fi

	OPTARG="${_module_OPTARG}"
	OPTIND="${_module_OPTIND}"
	return "${_module_ret}"
}
