#!/bin/bash

handleSigTerm()
{
        echo SIGTERM
}

oneTimeSetUp()
{
  trap "handleSigTerm" TERM
  if [ ${DEBUG} = TRUE ]; then
    ls -la $(dirname ${SSH_AUTH_SOCK})
    cat /root/.ssh/config
  fi
	git clone --depth 10 --branch ${BRANCH} ${CLONE_URL} /tmp/test
	cd /tmp/test
	git checkout ${SHA1}
	git reset ${SHA1}
}

testPHPCodeSniffer() {
	git log --pretty=oneline
	FILES=$(git diff --name-only HEAD~1 | tr "\\n" " ")
	$HOME/.composer/vendor/bin/phpcs --standard=$HOME/.composer/vendor/drupal/coder/coder_sniffer/Drupal --extensions="php,module,inc,install,test,profile,theme,js,css,info,txt" --report=${FORMAT} $FILES
  assertEquals 0 $?
}

. shunit2
