#!/usr/bin/env bash
# Set the repo wallpaper on every KDE Plasma 6 virtual desktop of this user.
#
#   ./scripts/set-wallpaper.sh              # uses /etc/swarm/wallpaper.jpg
#   ./scripts/set-wallpaper.sh ~/pic.jpg    # or any image you point it at
#
# The image is also copied to ~/Pictures so it appears in System Settings.
set -euo pipefail

SOURCE="${1:-/etc/swarm/wallpaper.jpg}"

if [[ ! -r "$SOURCE" ]]; then
  echo "error: cannot read $SOURCE" >&2
  echo "hint: run a nixos-rebuild first, or pass an image path explicitly" >&2
  exit 1
fi

mkdir -p "$HOME/Pictures"
TARGET="$HOME/Pictures/maxresdefault2.jpg"
cp -f "$SOURCE" "$TARGET"

if ! command -v qdbus >/dev/null 2>&1; then
  echo "warning: qdbus not found; image copied to $TARGET" >&2
  echo "set it manually via System Settings > Appearance > Wallpaper" >&2
  exit 0
fi

qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
  var all = desktops();
  for (var i = 0; i < all.length; i++) {
    all[i].wallpaperPlugin = 'org.kde.image';
    all[i].currentConfigGroup = ['Wallpaper', 'org.kde.image', 'General'];
    all[i].writeConfig('Image', 'file://$TARGET');
  }
"

echo "wallpaper set to $TARGET"
