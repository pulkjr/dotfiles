#!/bin/bash

echo "Configuring Podman machine"
podman machine init --cpus 4 --memory 8096 --disk-size 50

echo "Creating directories"
git clone git@github.com:pulkjr/linux-dotfiles.git ~/linux-dotfiles

