#!/bin/bash
#
# COEN Development Container Setup Script
# Sets up the development environment for building COEN ISOs
#

set -euo pipefail  # Exit on error, undefined variables, pipe failures
set -x             # Print commands for debugging

echo "Setting up COEN development environment..."

# Load variables from variables.sh
if [ -f "$PWD/variables.sh" ]; then
    # shellcheck disable=SC1091
    . "$PWD/variables.sh"
    export SOURCE_DATE_EPOCH
    echo "Loaded variables from variables.sh"
fi

# Note: Using latest Debian packages instead of pinned snapshot
# This is intentional for development environment to get security updates
# Production builds use pinned DATE in variables.sh via Dockerfile

echo "Updating package lists..."
apt-get update || {
    echo "Error: Failed to update package lists"
    exit 1
}

# Create symlinks to tools directory
echo "Creating symlinks to tools directory..."
if [ -d "$PWD/tools" ]; then
    ln -sf "$PWD/tools" /tools
    echo "Created /tools symlink"
else
    echo "Warning: $PWD/tools directory not found"
fi

if [ -d "$PWD/tools/archives-env" ]; then
    ln -sf "$PWD/tools/archives-env" /var/cache/apt/archives
    echo "Created apt archives symlink"
else
    echo "Warning: $PWD/tools/archives-env directory not found"
fi

# Install required packages for ISO building
echo "Installing required packages..."
apt-get install --no-install-recommends --yes \
    grub-common mtools \
    liblzo2-2 xorriso debootstrap debuerreotype locales squashfs-tools || {
    echo "Error: Failed to install required packages"
    exit 1
}

# Verify critical packages are installed
for pkg in xorriso debootstrap debuerreotype squashfs-tools; do
    if ! dpkg -l "$pkg" | grep -q '^ii'; then
        echo "Error: Package $pkg not installed correctly"
        exit 1
    fi
done
echo "All required packages installed successfully"

# Generate locale
echo "Generating en_US.UTF-8 locale..."
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 || {
    echo "Warning: Locale generation failed (non-fatal)"
}

echo "COEN development environment setup complete"
echo "You can now run: make all"
