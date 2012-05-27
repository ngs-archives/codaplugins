#!/bin/bash

git submodule update --init --recursive

if [ ! -f gist/Gist/GistPlugin-APIKey.h ];
then
  cp ~/Documents/DropBox/Codes/GistPlugin-APIKey.h gist/Gist/GistPlugin-APIKey.h
fi
