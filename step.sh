#!/bin/bash
set -e

BUILD_COMMAND=""
GENERATE_CODE_COVERAGE_FILES="no"

if [ "${is_clean_build}" == "yes" ] ; then
	BUILD_COMMAND="clean"
fi

if [ "${generate_code_coverage_files}" == "yes" ] ; then
	GENERATE_CODE_COVERAGE_FILES="GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES"
fi

if [ ! -z "${workdir}" ] ; then
	echo "==> Switching to working directory: ${workdir}"
	cd "${workdir}"
	if [ $? -ne 0 ] ; then
		echo " [!] Failed to switch to working directory: ${workdir}"
		exit 1
	fi
fi

set -x
set -o pipefail && xcodebuild -project "${project_path}" -scheme "${scheme}" ${BUILD_COMMAND} build test "${GENERATE_CODE_COVERAGE_FILES}" | xcpretty
ret=$?
set +x

if [ $ret -eq 0 ] ;
then BITRISE_XCODE_TEST_RESULT="succeeded"
else BITRISE_XCODE_TEST_RESULT="failed"
fi

envman add --key BITRISE_XCODE_TEST_RESULT --value "${BITRISE_XCODE_TEST_RESULT}"
