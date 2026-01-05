#!/bin/bash

# Set proper encoding for CocoaPods
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# Navigate to iOS directory
cd "$(dirname "$0")"

# Run pod install
pod install --repo-update
