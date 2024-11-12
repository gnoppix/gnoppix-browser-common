#!/bin/bash

set -e

cd "$(dirname "$0")"

UPPER="$PWD"

function move {
    mv -v "$1" "$UPPER/patches/$2" || true
}

rebrand() {
    find ./* -type f -exec sed -i "s/$1/$2/g" {} +
}

# cleanup librewolf patches
rm -rf patches/{sed-patches,librewolf-ui,unity_kde,librewolf,pref-pane}/*

[[ -d "librewolf" ]] || git clone --depth 1 -q "https://codeberg.org/librewolf/source.git" librewolf
cd "$UPPER/librewolf/patches"

for entry in "sed-patches/"*; do move "$entry" sed-patches; done;
for entry in "ui-patches/"*; do move "$entry" librewolf-ui; done;
for entry in "unity_kde/"*; do move "$entry" unity_kde; done;

for entry in "./"*; do
    [[ -d "$entry" ]] || move "$entry" librewolf
done

for entry in "./pref-pane/"*; do
    [[ -d "$entry" ]] || move "$entry" pref-pane
done

cd "$UPPER"
rm -rf librewolf

cd "$UPPER/patches"

# remove and rename files at pref-pane
rm -f pref-pane/README.md
"$UPPER"/rename-files.py pref-pane librewolf gnoppix-browser
cp "$UPPER"/category-gnoppix-browser.svg pref-pane/category-gnoppix-browser.svg

# rename file names in librewolf patchset folders
"$UPPER"/rename-files.py sed-patches librewolf gnoppix-browser
"$UPPER"/rename-files.py librewolf-ui librewolf gnoppix-browser
"$UPPER"/rename-files.py unity_kde librewolf gnoppix-browser
"$UPPER"/rename-files.py librewolf librewolf gnoppix-browser

curl -o librewolf-patchset.txt 'https://codeberg.org/librewolf/source/raw/branch/main/assets/patches.txt'

sed -i 's/lib\/librewolf/lib\/gnoppix-browser/g' librewolf/mozilla_dirs.patch
sed -i 's/lib64\/librewolf/lib64\/gnoppix-browser/g' librewolf/mozilla_dirs.patch
sed -i 's/librewolf/gnoppix/g' librewolf/mozilla_dirs.patch

rebrand "\/io\/gitlab\/" "\/org\/gnoppixos\/"
rebrand "io.gitlab." "org.gnoppixos."
rebrand LibreWolf Gnoppix
rebrand Librewolf Gnoppix
rebrand librewolf gnoppix-browser
rebrand "gnoppix-browser\.net" "librewolf.net"
rebrand "#why-is-gnoppix-browser-forcing-light-theme" "#why-is-librewolf-forcing-light-theme"

rebrand gnoppix-browser.cfg .cfg

rebrand "gnoppix-browser\/gnoppix-browser-pref-pane.patch" "librewolf\/librewolf-pref-pane.patch"

# we do that after rebrand step is done
"$UPPER"/manage-librewolf-patchlist.py --file="librewolf-patchset.txt" --exclude="windows-theming-bug,rust-gentoo-musl,flatpak-autoconf"

cd "$UPPER"
# patch our logo to devtools
patch -Np1 -i lw-gnoppix-logo-devtools.patch

