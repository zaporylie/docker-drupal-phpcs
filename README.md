Dockerized PHPCS for Drupal projects
================================

# Quickstart

docker run --rm -ti -e SERVICE=github.com -e USERNAME=drupal -e REPOSITORY=drupal -e BRANCH=7.x zaporylie/drupalcs

## Variables

SERVICE="github.com"
SHA="HEAD"
SHA_BEFORE="HEAD~1"
USERNAME="drupal"
REPOSITORY="drupal"
METHOD="http"
BRANCH="7.x"
DEPTH="20"
CLONE_PATH="/workspace"
REPORT_FORMAT="checkstyle"
REPORT_PATH="/reports"
REPORT_FILENAME="checkstyle-result.xml"
EXTENSIONS="php|module|inc|install|test|profile|theme|js|css|info|txt"
INCLUDE="."
DEBUG=FALSE

