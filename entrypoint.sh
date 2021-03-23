#!/bin/bash

set -e

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
	EVENT_ACTION=$(jq -r ".action" "${GITHUB_EVENT_PATH}")
	if [[ "${EVENT_ACTION}" != "opened" ]]; then
		echo "No need to run analysis. It is already triggered by the push event."
		exit 78
	fi
fi

REPOSITORY_NAME=$(basename "${GITHUB_REPOSITORY}")

[[ ! -z ${INPUT_PASSWORD} ]] && SONAR_PASSWORD="${INPUT_PASSWORD}" || SONAR_PASSWORD=""
[[ ! -z ${INPUT_EXCLUSIONS} ]] && SONAR_EXCLUSIONS="${INPUT_EXCLUSIONS}" || SONAR_EXCLUSIONS=""
[[ ! -z ${INPUT_COVERAGE_REPORTS} ]] && SONAR_COVERAGE_REPORTS="${COVERAGE_REPORTS}" || SONAR_COVERAGE_REPORTS=""
[[ -z ${INPUT_PROJECTKEY} ]] && SONAR_PROJECTKEY="${REPOSITORY_NAME}" || SONAR_PROJECTKEY="${INPUT_PROJECTKEY}"
[[ -z ${INPUT_PROJECTNAME} ]] && SONAR_PROJECTNAME="${REPOSITORY_NAME}" || SONAR_PROJECTNAME="${INPUT_PROJECTNAME}"
[[ -z ${INPUT_PROJECTVERSION} ]] && SONAR_PROJECTVERSION="" || SONAR_PROJECTVERSION="${INPUT_PROJECTVERSION}"

export SONAR_SCANNER_OPTS="${INPUT_SCANNEROPTIONS}" && sonar-scanner \
	-Dsonar.host.url=${INPUT_HOST} \
	-Dsonar.projectKey=${SONAR_PROJECTKEY} \
	-Dsonar.projectName=${SONAR_PROJECTNAME} \
	-Dsonar.projectVersion=${SONAR_PROJECTVERSION} \
	-Dsonar.projectBaseDir=${INPUT_PROJECTBASEDIR} \
	-Dsonar.login=${INPUT_LOGIN} \
	-Dsonar.password=${INPUT_PASSWORD} \
	-Dsonar.sources=. \
	-Dsonar.exclusions=${INPUT_EXCLUSIONS} \
	-Dsonar.sourceEncoding=UTF-8
    -Dsonar.typescript.lcov.reportPaths=${SONAR_COVERAGE_REPORTS}