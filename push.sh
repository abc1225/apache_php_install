#!/usr/bin/env sh

git pull origin master
git pull origin dev
git add -A
git commit -m "修改代码"
git push origin master
git push origin dev