#!/bin/bash

if [ -e "/tmp/.ssh/id_rsa" ]; then
	cp /tmp/.ssh/id_rsa ~/.ssh/id_rsa
	chmod 400 ~/.ssh/id_rsa
fi

if [ ${DEBUG} = TRUE ]; then
	cat /root/.ssh/config
fi

if [ ${METHOD} = "http" ]; then
	CLONE_URL="https://${SERVICE}/${USERNAME}/${REPOSITORY}.git"
else
	CLONE_URL="git@${SERVICE}:${USERNAME}/${REPOSITORY}.git"
fi

if [ ${DEBUG} = TRUE ]; then
	git clone --depth ${DEPTH} --branch ${BRANCH} ${CLONE_URL} ${CLONE_PATH} 2>&1
else
	git clone --depth ${DEPTH} --branch ${BRANCH} ${CLONE_URL} ${CLONE_PATH} > /dev/null 2>&1
fi

# Check if error.
if [ $? -ne 0 ]; then
	echo "Clone error"
	exit $?
fi

cd ${CLONE_PATH} > /dev/null 2>&1
git checkout ${SHA} > /dev/null 2>&1

# Check if error.
if [ $? -ne 0 ]; then
	echo "Checkout error";
        exit $?
fi

git reset ${SHA} > /dev/null 2>&1

# Check if error.
if [ $? -ne 0 ]; then
	echo "Reset error"
        exit $?
fi

if [ ${DEBUG} = TRUE ]; then
	git log --pretty=oneline
fi

IFS='|' read -r -a EXTENSIONS_ARRAY <<< "${EXTENSIONS}"
EXTENSIONS=""
for element in "${EXTENSIONS_ARRAY[@]}"
do
    EXTENSIONS="${EXTENSIONS} :/*.$element"
done

if [ ${DEBUG} = TRUE ]; then
	echo "all"
        git diff --diff-filter=ACMRTUXB --name-only ${SHA_BEFORE}
	echo "only matching extensions: ${EXTENSIONS}"
        git diff --diff-filter=ACMRTUXB --name-only ${SHA_BEFORE} --${EXTENSIONS}
	echo "only matching extensions ${EXTENSIONS} and include pattern ${INCLUDE}"
        git diff --diff-filter=ACMRTUXB --name-only ${SHA_BEFORE} --${EXTENSIONS} | grep -E ${INCLUDE}
fi


FILES=$(git diff --diff-filter=ACMRTUXB --name-only ${SHA_BEFORE} --${EXTENSIONS} | grep -E ${INCLUDE} | tr "\\n" " ")

if [ -z "$FILES" ]; then
        echo "No files"
        exit 0;
fi

if [ ${DEBUG} = TRUE ]; then
	echo "Files:"
        echo ${FILES}
fi

$HOME/.composer/vendor/bin/phpcs --standard=$HOME/.composer/vendor/drupal/coder/coder_sniffer/Drupal --report-${REPORT_FORMAT}=${REPORT_PATH}/${REPORT_FILENAME} --report-full $FILES
