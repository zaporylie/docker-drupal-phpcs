#!/bin/bash

if [ -e "/tmp/.ssh/id_rsa" ]; then
	cp /tmp/.ssh/id_rsa ~/.ssh/id_rsa
	chmod 400 ~/.ssh/id_rsa
fi

if [ ${DEBUG} = TRUE ]; then
	cat /root/.ssh/config
fi

if [ -d "${GIT_CLONE_PATH}" ]; then
	rm -rf ${GIT_CLONE_PATH}
fi

git clone --depth ${GIT_DEPTH} --branch ${GIT_BRANCH} ${GIT_CLONE_URL} ${GIT_CLONE_PATH} > /dev/null 2>&1

# Check if error.
if [ $? -ne 0 ]; then
	exit $?
fi

cd ${GIT_CLONE_PATH} > /dev/null 2>&1
git checkout ${GIT_AFTER} > /dev/null 2>&1

# Check if error.
if [ $? -ne 0 ]; then
        exit $?
fi

git reset ${GIT_AFTER} > /dev/null 2>&1

# Check if error.
if [ $? -ne 0 ]; then
        exit $?
fi

if [ ${DEBUG} = TRUE ]; then
	git log --pretty=oneline
fi

if [ ${DEBUG} = TRUE ]; then
	echo "all"
        git diff --diff-filter=ACMRTUXB --name-only ${GIT_BEFORE}
	echo "only matching extensions: ${EXTENSIONS}"
        git diff --diff-filter=ACMRTUXB --name-only ${GIT_BEFORE} | grep ${EXTENSIONS}
	echo "only matching extensions ${EXTENSIONS} and include patternt ${INCLUDE}"
        git diff --diff-filter=ACMRTUXB --name-only ${GIT_BEFORE} | grep ${EXTENSIONS} | grep ${INCLUDE}
fi


FILES=$(git diff --diff-filter=ACMRTUXB --name-only ${GIT_BEFORE} | grep ${EXTENSIONS} | grep ${INCLUDE} | tr "\\n" " ")

if [ ${DEBUG} = TRUE ]; then
        echo ${FILES}
fi

if [ -z "$FILES" ]; then
	exit 1;
fi

$HOME/.composer/vendor/bin/phpcs --standard=$HOME/.composer/vendor/drupal/coder/coder_sniffer/Drupal --report-${REPORT_FORMAT}=${REPORT_PATH}/${REPORT_FILENAME} --report-full $FILES
