#!/bin/bash

	if [ -e "/tmp/.ssh/id_rsa" ]; then
		cp /tmp/.ssh/id_rsa ~/.ssh/id_rsa
		chmod 400 ~/.ssh/id_rsa
	fi

	if [ ${DEBUG} = TRUE ]; then
		ls -la $(dirname ${SSH_AUTH_SOCK})
		cat /root/.ssh/config
	fi

	git clone --depth 10 --branch ${BRANCH} ${CLONE_URL} /tmp/test
	
	# Check if error.
	if [ $? -ne 0 ]; then
		exit $?
	fi

	cd /tmp/test
	git checkout ${SHA1}
	git reset ${SHA1}
	
	if [ ${DEBUG} = TRUE ]; then
		git log --pretty=oneline
	fi

	FILES=$(git diff --diff-filter=ACMRTUXB --name-only HEAD~1 | tr "\\n" " ")

	if [ -z "$FILES" ]; then
		exit 1;
	fi

	$HOME/.composer/vendor/bin/phpcs --standard=$HOME/.composer/vendor/drupal/coder/coder_sniffer/Drupal --extensions="php,module,inc,install,test,profile,theme,js,css,info,txt" --report-${FORMAT}=/reports/${FORMAT}.xml --report-full $FILES

