#!/bin/bash

git submodule update --init --recursive

if [ ! -f gist/Gist/GistPlugin-APIKey.h ];
then
  cp ~/DropBox/Codes/GistPlugin-APIKey.h gist/Gist/GistPlugin-APIKey.h
fi

if [ ! -f evernote/Evernote/EvernotePlugin-APIKey.h ];
then
  cp ~/DropBox/Codes/EvernotePlugin-APIKey.h evernote/Evernote/EvernotePlugin-APIKey.h
fi
