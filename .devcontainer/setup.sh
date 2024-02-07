#!/bin/bash
set -x

# . $PWD/variables.sh && \
#     rm -f /etc/apt/sources.list && \
#     echo "deb http://snapshot.debian.org/archive/debian/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') "$DIST" main" >> /etc/apt/sources.list && \
#     echo "deb http://snapshot.debian.org/archive/debian/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') "$DIST"-updates main" >> /etc/apt/sources.list && \
#     echo "deb http://snapshot.debian.org/archive/debian-security/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') "$DIST"-security main" >> /etc/apt/sources.list && \
#     echo "deb http://snapshot.debian.org/archive/debian/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') "$DIST_ADD" main" >> /etc/apt/sources.list 

# apt-get update -o Acquire::Check-Valid-Until=false
apt-get update

ln -s $PWD/tools /tools
ln -s $PWD/tools/archives-env /var/cache/apt/archives

# apt-get install -o Acquire::Check-Valid-Until=false --no-install-recommends --yes \
#     grub-common mtools \
#     liblzo2-2 xorriso debootstrap debuerreotype locales squashfs-tools
apt-get install --no-install-recommends --yes \
    grub-common mtools \
    liblzo2-2 xorriso debootstrap debuerreotype locales squashfs-tools

localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
