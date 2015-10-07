#!/bin/bash

set -e
set -x

[ -n "$1" ] && name="$1" && rm -f ./.configure
[ -z "${name}" ] && [ -f ./.configure ] && name=$(cat ./.configure | head -n 1)
[ -z "${name}" ] && echo "Enter plugin details: " && read -p "Name: " name

name=$(echo ${name} | sed 's/^ *//g' | sed 's/ *$//g')

if [ -z "${name}" ]; then
    echo "Empty name entered, exiting ..."
    exit 1
fi

[ ! -f ./.configure ] && echo "${name}" > ./.configure && exit 0

name_lowercase=$(echo ${name} | tr '[:upper:]' '[:lower:]' | tr -d ' ')

name_camelcase=$(echo ${name} | sed 's/[^ ]\+/\u&/g' | tr -d ' ')

echo "Updating configuration ..."

function copy_sed() {
	local INFILE="$1"
	local OUTFILE="$2"
	cat ${INFILE} | \
		sed -e "s/@@LOWERCASE_NAME@@/${name_lowercase}/g" | \
		sed -e "s/@@UPPERCASE_NAME@@/${name_camelcase}/g" | \
		sed -e "s/@@USER_NAME@@/${USER_NAME}/g" | \
		sed -e "s/@@USER_MAIL@@/${USER_MAIL}/g" | \
		sed -e "s/@@DATE_STAMP@@/${DATE_STAMP}/g" > ${OUTFILE}
}

ROOT=.
FILES=./.files
USER_NAME="Simon Baur"
USER_MAIL="sbausis@gmx.net"
DATE_STAMP=$(date "+%a, %d %b %Y %H:%M:%S %z")

rm -Rf ${ROOT}/debian ${ROOT}/usr ${ROOT}/var

# debian
mkdir -p ${ROOT}/debian
copy_sed ${FILES}/debian/changelog ${ROOT}/debian/changelog
copy_sed ${FILES}/debian/compat ${ROOT}/debian/compat
copy_sed ${FILES}/debian/control ${ROOT}/debian/control
copy_sed ${FILES}/debian/copyright ${ROOT}/debian/copyright
copy_sed ${FILES}/debian/install ${ROOT}/debian/install
copy_sed ${FILES}/debian/postinst ${ROOT}/debian/postinst
copy_sed ${FILES}/debian/postrm ${ROOT}/debian/postrm
copy_sed ${FILES}/debian/rules ${ROOT}/debian/rules
copy_sed ${FILES}/debian/triggers ${ROOT}/debian/triggers

mkdir -p ${ROOT}/debian/source
copy_sed ${FILES}/debian/source/format ${ROOT}/debian/source/format

# usr
mkdir -p ${ROOT}/usr/share/openmediavault/engined/module
copy_sed ${FILES}/usr/share/openmediavault/engined/module/skeleton.inc ${ROOT}/usr/share/openmediavault/engined/module/${name_lowercase}.inc

mkdir -p ${ROOT}/usr/share/openmediavault/engined/rpc
copy_sed ${FILES}/usr/share/openmediavault/engined/rpc/skeleton.inc ${ROOT}/usr/share/openmediavault/engined/rpc/${name_lowercase}.inc

mkdir -p ${ROOT}/usr/share/openmediavault/mkconf
copy_sed ${FILES}/usr/share/openmediavault/mkconf/skeleton ${ROOT}/usr/share/openmediavault/mkconf/${name_lowercase}
chmod +x ${ROOT}/usr/share/openmediavault/mkconf/${name_lowercase}

# var
mkdir -p ${ROOT}/var/www/openmediavault/images
cp -f ${FILES}/var/www/openmediavault/images/skeleton.png ${ROOT}/var/www/openmediavault/images/${name_lowercase}.png
cp -f ${FILES}/var/www/openmediavault/images/skeleton.svg ${ROOT}/var/www/openmediavault/images/${name_lowercase}.svg

SERVICEFOLDER=${ROOT}/var/www/openmediavault/js/omv/module/admin/service/${name_lowercase}
mkdir -p ${SERVICEFOLDER}
copy_sed ${FILES}/var/www/openmediavault/js/omv/module/admin/service/skeleton/Skeleton.js ${SERVICEFOLDER}/${name_camelcase}.js
copy_sed ${FILES}/var/www/openmediavault/js/omv/module/admin/service/skeleton/Settings.js ${SERVICEFOLDER}/Settings.js
copy_sed ${FILES}/var/www/openmediavault/js/omv/module/admin/service/skeleton/Entries.js ${SERVICEFOLDER}/Entries.js


echo "Done!"

exit 0
