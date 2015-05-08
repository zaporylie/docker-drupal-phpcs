#!/bin/bash

handleSigTerm()
{
        echo SIGTERM
}

oneTimeSetUp()
{
        trap "handleSigTerm" TERM
	git clone --depth 10 ${CLONE_URL} /tmp/test
	cd /tmp/test
	git checkout ${SHA1}
	git reset ${SHA1}
}

testPHPCodeSniffer() {
	git log --pretty=oneline
	FILES=$(git diff --name-only HEAD~1 | tr "\\n" " ")
	$HOME/.composer/vendor/bin/phpcs --standard=$HOME/.composer/vendor/drupal/coder/coder_sniffer/Drupal --extensions="php,module,inc,install,test,profile,theme,js,css,info,txt" $FILES
        assertEquals "PHP Code Sniffer haven't found any errors" 0 $?
}

. shunit2
