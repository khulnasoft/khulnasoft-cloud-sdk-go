#!/bin/bash -e

if [ "${CI}" != "true" ] ; then
    echo "Exiting: $0 can only be run from the CI system."
    exit 1
fi

if [ -z "${GITHUB_TOKEN}" ] ; then
    echo "No \$GITHUB_TOKEN set, exiting ..."
    exit 1
fi

if [ -z "${GITHUB_ORG}" ] ; then
    GITHUB_ORG=splunk
    echo "No \$GITHUB_ORG set, using ${GITHUB_ORG} by default ..."
fi

if [ -z "${GITHUB_PROJECT}" ] ; then
    # We are moving kcloud into the splunk-cloud-sdk-go repo for public distribution,
    # until that happens officially we will publish kcloud artifacts there from this repo
    GITHUB_PROJECT=splunk-cloud-sdk-go
    echo "No \$GITHUB_PROJECT set, using ${GITHUB_PROJECT} by default ..."
fi
GITHUB_REPO="https://github.com/${GITHUB_ORG}/${GITHUB_PROJECT}"

if [[ "$(uname)" == "Darwin" ]] ; then
    # MacOS
    SED_FLG="-E"
else
    # Linux
    SED_FLG="-r"
fi
# Get release version from services/client_info.go e.g. v0.9.2
RELEASE_TAG=v$(cat services/client_info.go | sed ${SED_FLG} -n 's/const Version = "([0-9]+\.[0-9]+\.[0-9]+.*)"/\1/p')
if [ -n "${OVERRIDE_RELEASE_TAG}" ] ; then
    echo "\$OVERRIDE_RELEASE_TAG was set so uploading cross-compiled artifacts to ${OVERRIDE_RELEASE_TAG} rather than the default for this tag (${RELEASE_TAG}) ..."
    RELEASE_TAG="${OVERRIDE_RELEASE_TAG}"
fi

echo "Installing github-release ..."
go get github.com/aktau/github-release

echo "Checking to make sure release of ${RELEASE_TAG} exists at ${GITHUB_REPO}/releases ..."
github-release info --user "${GITHUB_ORG}" --repo "${GITHUB_PROJECT}" --tag "${RELEASE_TAG}"

echo "Uploading (replacing if files already existed) cross-compiled archive artifacts to existing release of ${RELEASE_TAG} at ${GITHUB_REPO}/releases ..."
echo ""
artifacts=bin/cross-compiled_kcloud/archive/*
for artifact in $artifacts ; do
    echo "Uploading ${artifact} ..."
    github-release upload --replace --user "${GITHUB_ORG}" --repo "${GITHUB_PROJECT}" --tag "${RELEASE_TAG}" --file "${artifact}" --name "$(basename ${artifact})"
done
echo ""
echo "Success!"

echo "Uploading (replacing if files already existed) cross-compiled kcloud archive artifacts to existing release of ${RELEASE_TAG} at ${GITHUB_REPO}/releases ..."
echo ""
artifacts=bin/cross-compiled_kcloud/archive/*
for artifact in $artifacts ; do
    echo "Uploading ${artifact} ..."
    github-release upload --replace --user "${GITHUB_ORG}" --repo "${GITHUB_PROJECT}" --tag "${RELEASE_TAG}" --file "${artifact}" --name "$(basename ${artifact})"
done
echo ""
echo "Success!"