#!/usr/bin/env bash
# remove trailing slash
runtimepath="${1%/}"
shift
# Use the actual nvim binary, bypassing any wrappers
# Set up runtimepath and after directory explicitly
nvim --clean \
	--cmd "set runtimepath^=$runtimepath" \
	--cmd "set runtimepath+=$runtimepath/after" \
	-u "$runtimepath/init.lua" "$@"
