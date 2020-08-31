#!/usr/bin/env sh

set -e

npm vue-cli-service build

cd dist

git init
git add -A
git commit -m 'deploy'

git push -f git@github.com:evgeniya-osmakova/simon.git master:gh-pages

cd -
