#!/bin/bash

set -e

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

# [skip travis] ensures that the commits made via CI will not trigger travis job
commit_files() {
  echo "Updating Last Version in file to $1"

  echo "$1" > last_version

  echo "Latest Version: "
  cat last_version
  
  git add last_version
  # TODO: find a better solution to exit with 0 if there is nothing to commit
  git commit --message "[skip ci] Updating last version from travis job $TRAVIS_JOB_WEB_URL" || true
}

push_files() {
  git remote add https_push https://anup-kodlekere:${GH_TOKEN}@github.com/anup-kodlekere/gaplib.git > /dev/null 2>&1
  git pull origin $TRAVIS_BRANCH --rebase
  git push https_push HEAD:$TRAVIS_BRANCH
}

setup_git
commit_files
push_files
