#!/bin/bash -e


SCLOUD_SRC_PATH=./cmd/kcloud/cmd/kcloud

if [[ -z "${SCLOUD_SRC_PATH}" ]] ; then
    echo "SCLOUD_SRC_PATH must be set, exiting ..."
    exit 1
fi

if [[ "$(uname)" == "Darwin" ]] ; then
    # MacOS
    SED_FLG="-E"
else
    # Linux
    SED_FLG="-r"

fi

BUILD_TARGETS_ARCH=( 386 amd64 arm64)
BUILD_TARGETS_OS=( darwin linux windows )
TARGET_ROOT_DIR=bin/cross-compiled_kcloud
ARCHIVE_DIR=${TARGET_ROOT_DIR}/archive
TAG=$(git describe --abbrev=0 --tags)

rm -fr ${TARGET_ROOT_DIR}
mkdir -p ${ARCHIVE_DIR}

for os in ${BUILD_TARGETS_OS[@]}
do
    for arch in ${BUILD_TARGETS_ARCH[@]}
    do
        if [[ 'windows' == ${os} ]]
        then
            program_name='kcloud.exe'
        else
            program_name='kcloud'
        fi
        if [[ 'darwin' == ${os} ]] && [[ '386' == ${arch} ]]
        then
            echo "Skipping darwin/386, no longer supported in go 1.15+"
            continue
        fi
        target_dir=${TARGET_ROOT_DIR}/${os}_${arch}
        mkdir -p ${target_dir}
        target_file=${target_dir}/${program_name}
        echo "Building ${target_file}";
        # The -s flag strips debug symbols from Linux, -w from DWARF (darwin). This reduces binary size by about half.
        env GOOS=${os} GOARCH=${arch} GO111MODULE=on go build -ldflags "-s -w" -a -mod=readonly -o ${target_file} ${SCLOUD_SRC_PATH}
        kcloud_version=v$(cat cmd/kcloud/cmd/kcloud/version/client_info.go | sed ${SED_FLG} -n 's/const ScloudVersion = "([0-9]+\.[0-9]+\.[0-9]+.*)"/\1/p')
        archive_file=${PWD}/${ARCHIVE_DIR}/kcloud_${kcloud_version}_${os}_${arch}

        if [[ 'windows' == ${os} ]]
        then
            pushd ${target_dir}
            zip ${archive_file}.zip ${program_name}
            popd
        else
            tar -C ${target_dir} -czvf ${archive_file}.tar.gz ${program_name}
        fi
        echo ""
    done
done

if [[ "$(uname -m)" == "x86_64" ]] ; then
    myarch=amd64
else
    myarch=386
fi
if [[ "$OS" == "Windows_NT" ]] ; then
	myos=windows
    program_name='kcloud.exe'
else
    program_name='kcloud'
	if [[ "$(uname -s)" == "Linux" ]] ; then
		myos=linux
	else
		myos=darwin
	fi
fi

mykcloud="${TARGET_ROOT_DIR}/${myos}_${myarch}/${program_name}"
echo "Testing binary for this environment: ${mykcloud} ..."
if ! [[ -f "${mykcloud}" ]] ; then
    echo "File not found: ${mykcloud} , exiting ..."
    exit 1
fi
${mykcloud} version
status=$?
if [[ "${status}" -gt "0" ]] ; then
    echo "Error running \"${mykcloud} version\", exiting ..."
    exit 1
fi
echo "Success."
echo ""

echo "Package archives created: "
echo ""
archives=$(ls ${ARCHIVE_DIR})
echo "${archives}"