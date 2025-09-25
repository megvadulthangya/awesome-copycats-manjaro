#!/bin/bash
exec > >(tee -a setup.log) 2>&1

if [ "$(id -u)" -ne "0" ]; then
  echo "Ez a script root jogosultságokat igényel. Futtassa sudo-val vagy root-ként."
  exit 1
fi

# --- Nem-root felhasználó és home könyvtár ---
USERNAME=$(logname)
USER_HOME=$(eval echo "~${USERNAME}")
echo "Felhasználó: $USERNAME"
echo "Felhasználó home: $USER_HOME"

# --- Csomagkezelő autodetektálás ---
if command -v pamac &>/dev/null; then
    PKG_MGR="pamac"
elif command -v paru &>/dev/null; then
    PKG_MGR="paru"
elif command -v yay &>/dev/null; then
    PKG_MGR="yay"
elif command -v pacman &>/dev/null; then
    PKG_MGR="pacman"
else
    echo "Nem található támogatott csomagkezelő (pacman/pamac/yay/paru)."
    exit 1
fi

echo "Használt csomagkezelő: $PKG_MGR"

# --- Függvények ---
install_repo() {
    pacman -S --needed --noconfirm "$@"
}

install_aur() {
    case "$PKG_MGR" in
        pamac)
            sudo -u "$USERNAME" pamac install --no-confirm "$@"
            ;;
        yay|paru)
            sudo -u "$USERNAME" $PKG_MGR -S --needed --noconfirm "$@"
            ;;
        pacman)
            echo "Figyelem: AUR csomagok telepítéséhez nincs AUR helper telepítve."
            ;;
    esac
}

# --- Repo csomagok ---
REPO_PKGS=(
  dmenu rofi picom scrot unclutter xorg-xbacklight slock alsa-utils
  mpd mpc playerctl xorg-fonts-misc ttf-roboto woff2-font-awesome
  arandr lxappearance lxqt-policykit xorg-xev terminus-font xss-lock
)

echo "Repo csomagok telepítése..."
install_repo "${REPO_PKGS[@]}"

# --- AUR csomagok ---
AUR_PKGS=(
  lain-git awesome-git awesome-freedesktop-git tilix-git tamzen-font i3lock-fancy-git
)

echo "AUR csomagok telepítése..."
install_aur "${AUR_PKGS[@]}"

# --- Ikon font telepítése ---
echo "Ikon font telepítése $USERNAME számára..."
sudo -u "$USERNAME" mkdir -p "$USER_HOME/.local/share/fonts"
sudo -u "$USERNAME" curl -L -o "$USER_HOME/.local/share/fonts/Icons.bdf" \
  https://raw.githubusercontent.com/lcpz/dots/refs/heads/master/.fonts/Icons.bdf
sudo -u "$USERNAME" fc-cache -fv "$USER_HOME/.local/share/fonts"

echo "Telepítés befejezve!"

set -e

# --- Nano Syntax Highlighting ---
INSTALL_PATH="/usr/share/nano-syntax-highlighting"

echo "=== Nano Syntax Highlighting telepítése system-wide ==="
if [ ! -d "$INSTALL_PATH" ]; then
    git clone https://github.com/scopatz/nanorc.git "$INSTALL_PATH"
fi

if [ -f /etc/nanorc ]; then
    cp /etc/nanorc /etc/nanorc.backup.$(date +%F_%H-%M-%S)
fi

if ! grep -q "include $INSTALL_PATH/*.nanorc" /etc/nanorc 2>/dev/null; then
    echo "include $INSTALL_PATH/*.nanorc" >> /etc/nanorc
fi

echo "=== Kész! System-wide szintaxis kiemelés beállítva. ==="

# --- Nano mint alapértelmezett szerkesztő ---
echo "A 'nano' beállítása alapértelmezett szövegszerkesztőnek..."
echo "export EDITOR=nano" | sudo tee -a /etc/environment
echo "nano beállítva alapértelmezett szerkesztőnek!"

# --- safe-lock.sh ---
echo "safe-lock.sh létrehozása..."
cat <<EOF > /usr/local/bin/safe-lock.sh
#!/usr/bin/env bash
# safe-lock.sh - xss-lock által hívva

LOCK_CMD="i3lock-fancy"

is_video_playing() {
  players=\$(playerctl -l 2>/dev/null)
  [ -z "\$players" ] && return 1

  for p in \$players; do
    status=\$(playerctl -p "\$p" status 2>/dev/null || echo "")
    [ "\$status" != "Playing" ] && continue

    media_type=\$(playerctl -p "\$p" metadata mpris:media-type 2>/dev/null || echo "")

    if [ "\$media_type" = "Video" ]; then
      return 0
    fi

    case "\$p" in
      mpv|chromium*|brave*|chrome*|grayjay*)
        return 0
        ;;
    esac
  done

  return 1
}

if is_video_playing; then
  exit 0
fi

exec \$LOCK_CMD
EOF

chmod +x /usr/local/bin/safe-lock.sh
echo "Lock script elhelyezve."

# --- .xprofile létrehozása ---
sudo -u "$USERNAME" bash -c "echo '.xprofile létrehozása...' && cat <<EOF > \"$USER_HOME/.xprofile\"
export QT_QPA_PLATFORMTHEME=\"qt5ct\"
EOF"

# --- AwesomeWM Copycats ---
echo "AwesomeWM Copycats konfiguráció telepítése $USERNAME számára..."
cd /tmp
sudo -u "$USERNAME" -H git clone --branch Autoinstall --recurse-submodules --remote-submodules --depth 1 -j 2 \
  https://github.com/megvadulthangya/awesome-copycats-manjaro.git

if [ -d /tmp/awesome-copycats-manjaro ]; then
  sudo -u "$USERNAME" -H mkdir -p "$USER_HOME/.config/awesome"
  sudo -u "$USERNAME" -H bash -c "mv -bv /tmp/awesome-copycats-manjaro/{*,.[^.]*} \"$USER_HOME/.config/awesome/\""
  rm -rf /tmp/awesome-copycats-manjaro
  echo "Telepítve ide: $USER_HOME/.config/awesome"
else
  echo "HIBA: Nem sikerült klónozni a repót!"
fi

# --- rc.lua kezelés ---
if [ -f "$USER_HOME/.config/awesome/rc.lua.template" ]; then
    if [ -f "$USER_HOME/.config/awesome/rc.lua" ]; then
        backup_file="$USER_HOME/.config/awesome/rc.lua.backup-$(date +%Y%m%d%H%M%S)"
        cp "$USER_HOME/.config/awesome/rc.lua" "$backup_file"
        echo "Biztonsági mentés készült: $backup_file"
        cp "$USER_HOME/.config/awesome/rc.lua.template" "$USER_HOME/.config/awesome/rc.lua"
        echo "rc.lua felülírva a sablonnal."
    else
        cp "$USER_HOME/.config/awesome/rc.lua.template" "$USER_HOME/.config/awesome/rc.lua"
        echo "rc.lua létrehozva a sablonból."
    fi
else
    echo "rc.lua.template nem található a $USER_HOME/.config/awesome mappában!"
fi

echo "=== i3lock-fancy javítása (convert → magick convert) ==="
if [ -f /usr/bin/i3lock-fancy ]; then
  sudo sed -i 's/\bconvert\b/magick/g' /usr/bin/i3lock-fancy
  echo "i3lock-fancy sikeresen javítva!"
else
  echo "Figyelem: /usr/bin/i3lock-fancy nem található."
fi



# --- Rendszer újraindítása ---
echo "Újraindíthatod a rendszert..."
#reboot
