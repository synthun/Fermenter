#!/bin/sh

abs_path="dirname $(realpath "$0")"
bin=$HOME/.local/bin
assets=$HOME/.local/share/fermenter/assets

mkdir -p "$assets"
mkdir -p "$bin"

if [ -z "$(find "$assets" -name "wrapper.lua")" ]; then
	cp "$($abs_path)"/src/wrapper.lua "$assets"/wrapper.lua
fi

if [ -z "$(find "$bin" -name "fermenter")" ]; then
	cp "$($abs_path)"/src/fermenter "$bin"/fermenter
fi
