#!/bin/bash

set -e

# Arch Haskell snapshot of 2015-03-12.
HABS_TAG=913ba6202d209fa1aff57e12e2c7105ddad724d5

# cblrepo snapshot of 2015-03-12.
CBLREPO_TAG=eefac7ced65fca3758478b97a5256433da52c57a

. /hinance-docker/setup/share.sh

sed 's/^CheckSpace/#CheckSpace/g' -i /etc/pacman.conf

pacman-key --refresh-keys

# Pacman database has changed in version 4.2 on 2014-12-29.
# Need to upgrade it first before going any further.
echo "Server = $AA_ROOT/repos/2014/12/28/\$repo/os/\$arch" \
    > /etc/pacman.d/mirrorlist
pacman -Syyuu --noconfirm

echo "Server = $AA_ROOT/repos/2014/12/29/\$repo/os/\$arch" \
    > /etc/pacman.d/mirrorlist
pacman -Sy --noconfirm pacman
pacman-db-upgrade
pacman -Syyuu --noconfirm

# Finish the upgrade.
echo "Server = $AA_ROOT/repos/$AA_YEAR/$AA_MONTH/$AA_DAY/\$repo/os/\$arch" \
    > /etc/pacman.d/mirrorlist
pacman -Syyuu --noconfirm

pacman -S --noconfirm --needed base base-devel cabal-install ghc git happy \
                               mupdf python2-prettytable sudo v8

# habs
git clone https://github.com/archhaskell/habs /hinance-docker/habs
cd /hinance-docker/habs
git checkout $HABS_TAG

# cblrepo
git clone https://github.com/magthe/cblrepo /hinance-docker/cblrepo
cd /hinance-docker/cblrepo
git checkout $CBLREPO_TAG

# user
useradd -m user -G wheel
chmod +w /etc/sudoers
echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
chown -R user:user /hinance-docker

sudo -iu user /hinance-docker/setup/setup-pkgs.sh

paccache -rk0
rm -rf /hinance-docker/{aur,habs}
