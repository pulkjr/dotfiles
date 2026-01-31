#!/usr/bin/env bash

printf "\nApplying macOS Dock settings...\n"

# Autohide Dock
defaults write com.apple.dock "autohide" -bool "true"

# disable macOS Dock animations
defaults write com.apple.dock autohide-time-modifier -int 0

# Don't show recents in dock
defaults write com.apple.dock "show-recents" -bool "false"

# Show only running apps in Dock
defaults write com.apple.dock "static-only" -bool "true"

# Remove the auto-hiding Dock delay
defaults write com.apple.dock "autohide-delay" -float "0"

killall Dock

printf "\nApplying macOS Finder settings...\n"
# Use list view as default display style
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"

# Show file extensions in Finder
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# Show path bar in Finder
defaults write com.apple.finder "ShowPathbar" -bool "true"

killall Finder

printf "\nApplying macOS Keyboard settings...\n"
# All values copied from https://mac-key-repeat.zaymon.dev
# The system has to be restarted for changes to take effect.

# disable press and hold for special characters
defaults write -g ApplePressAndHoldEnabled -bool false

# set a fast keyboard repeat rate
# set the delay until key repeat
defaults write -g InitialKeyRepeat -int 12

# set the key repeat rate
defaults write -g KeyRepeat -int 2

# Enable moving focus with Tab and Shift-Tab
defaults write NSGlobalDomain AppleKeyboardUIMode -int "2"

printf "\nApplying macOS Menu Bar settings...\n"
# Hide menu bar
defaults write NSGlobalDomain _HIHideMenuBar -bool true && killall Dock

printf "\nApplying macOS Mission Control settings...\n"

# Disable "Displays have separate spaces"
defaults write com.apple.spaces "spans-displays" -bool "false" && killall SystemUIServer

# Group windows by application in Mission Control
defaults write com.apple.dock "expose-group-apps" -bool "true" && killall Dock
