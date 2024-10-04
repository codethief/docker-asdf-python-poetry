#!/usr/bin/env bash

# This installs asdf to the home dir, adapts the Bash config, and installs all
# plugins & tools from .tool-versions.
#
# Assumption: Working dir contains the .tool-versions file.

set -ex

git clone --depth 1 https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.14.1

ASDF_SOURCE_FILE="$HOME/.asdf/asdf.sh"

# Make asdf available…
# …in future login shells
echo ". $ASDF_SOURCE_FILE" > $HOME/.bashrc
# …in future non-login shells
echo ". $ASDF_SOURCE_FILE" > $HOME/.profile
# …and make it available now!
. "$ASDF_SOURCE_FILE"

# asdf doesn't support auto-installing plugins mentioned in .tool-versions, see
# https://github.com/asdf-vm/asdf/issues/276 , so let's do this manually.
cat .tool-versions | cut -d' ' -f1 | grep "^[^\#]" | xargs -I{} sh -c 'asdf plugin add {} > /dev/null'

# Install the required tool versions listed in .tool-versions
asdf install
