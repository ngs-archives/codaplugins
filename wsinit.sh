#!/bin/bash

BASE=$PWD

for PROJ in arduino creole evernote gist markdown; do
  cd "${BASE}/${PROJ}"
  git checkout master
  git pull origin master
  if [ -d "${BASE}/${PROJ}/Shared" ]; then
    cd "${BASE}/${PROJ}/Shared"
    git checkout shared
    git pull
  fi
  if [ -d "${BASE}/pages/${PROJ}" ]; then
    cd "${BASE}/pages/${PROJ}"
    git checkout gh-pages
    git pull
  fi
done


git submodule update --init --recursive

if [ ! -f "${BASE}/gist/Gist/GistPlugin-APIKey.h" ];
then
  cp ~/DropBox/Codes/GistPlugin-APIKey.h "${BASE}/gist/Gist/GistPlugin-APIKey.h"
fi

if [ ! -f "${BASE}/evernote/Evernote/EvernotePlugin-APIKey.h" ];
then
  cp ~/DropBox/Codes/EvernotePlugin-APIKey.h "${BASE}/evernote/Evernote/EvernotePlugin-APIKey.h"
fi
