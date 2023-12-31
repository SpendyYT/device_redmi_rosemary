#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE="rosemary"
VENDOR="redmi"

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

function blob_fixup() {
    case "${1}" in
        lib/libsink.so)
            "${PATCHELF}" --add-needed "libshim_vtservice.so" "${2}"
            ;;
	vendor/bin/hw/android.hardware.keymaster@4.0-service.beanpod)
            "${PATCHELF}" --add-needed "libshim_beanpod.so" "${2}"
            ;;
        lib/libmtk_vt_service.so)
            "${PATCHELF}" --add-needed "libshim_vtservice.so" "${2}"
            ;;
        vendor/lib64/hw/audio.primary.mt6785.so)
            "${PATCHELF}" --replace-needed "libmedia_helper.so" "libmedia_helper-v30.so" "${2}"
            ;;
        vendor/lib/hw/audio.primary.mt6785.so)
            "${PATCHELF}" --replace-needed "libmedia_helper.so" "libmedia_helper-v30.so" "${2}"
            ;;
        vendor/lib/libudf.so)
            "${PATCHELF}" --replace-needed "libunwindstack.so" "libunwindstack-v30.so" "${2}"
            ;;
        vendor/lib64/libudf.so)
            "${PATCHELF}" --replace-needed "libunwindstack.so" "libunwindstack-v30.so" "${2}"
            ;;
        vendor/lib/libmtkcam_stdutils.so)
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v30.so" "${2}"
            ;;
        vendor/lib64/libmtkcam_stdutils.so)
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v30.so" "${2}"
            ;;
        vendor/lib64/libwifi-hal-mtk.so)
            "${PATCHELF}" --set-soname "libwifi-hal-mtk.so" "${2}"
            ;;
        vendor/lib/hw/vendor.mediatek.hardware.pq@2.6-impl.so )
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v30.so" "${2}"
            ;;
        vendor/lib64/hw/vendor.mediatek.hardware.pq@2.6-impl.so )
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v30.so" "${2}"
            ;;
        vendor/lib/hw/dfps.mt6785.so )
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v30.so" "${2}"
            ;;
        vendor/lib64/hw/dfps.mt6785.so )
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v30.so" "${2}"
            ;;
        lib/libshowlogo.so)
            "${PATCHELF}" --add-needed "libshim_showlogo.so" "${2}"
            ;;
        vendor/lib/libMtkOmxVdecEx.so)
            "${PATCHELF}" --replace-needed "libui.so" "libui-v32.so" "${2}"
            ;;
    esac
}

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
