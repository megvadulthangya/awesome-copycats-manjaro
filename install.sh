#!/bin/bash
exec > >(tee -a setup.log) 2>&1

if [ "$(id -u)" -ne "0" ]; then
  echo "Ez a script root jogosultságokat igényel. Futtassa sudo-val vagy root-ként."
  exit 1
fi

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

# --- Függvény a telepítéshez ---
install_repo() {
    pacman -S --needed --noconfirm "$@"
}

install_aur() {
    case "$PKG_MGR" in
        pamac)
            sudo -u "$SUDO_USER" pamac install --no-confirm "$@"
            ;;
        yay|paru)
            sudo -u "$SUDO_USER" $PKG_MGR -S --needed --noconfirm "$@"
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





# Ikon font telepítése a felhasználóhoz
mkdir -p "$USER_HOME/.local/share/fonts"
curl -L -o "$USER_HOME/.local/share/fonts/Icons.bdf" \
  https://raw.githubusercontent.com/lcpz/dots/refs/heads/master/.fonts/Icons.bdf

# Frissítjük a font cache-t
fc-cache -fv "$USER_HOME/.local/share/fonts"


#Opcionális: yay mappa törlése a végén
#echo "Takarítás..."
#sudo -u "$SUDO_USER" rm -rf "$USER_HOME/yay"
echo "Telepítés befejezve!"



# Nem-root felhasználó és home könyvtárának meghatározása
USER=$(logname)
USER_HOME=$(eval echo "~${USER}")
echo "Felhasználó: $USER"
echo "Felhasználó home: $USER_HOME"



set -e

INSTALL_PATH="/usr/share/nano-syntax-highlighting"

echo "=== Nano Syntax Highlighting telepítése system-wide ==="

# repo klónozása, ha még nem létezik
if [ ! -d "$INSTALL_PATH" ]; then
    git clone https://github.com/scopatz/nanorc.git "$INSTALL_PATH"
fi

# backup készítése /etc/nanorc fájlról
if [ -f /etc/nanorc ]; then
    cp /etc/nanorc /etc/nanorc.backup.$(date +%F_%H-%M-%S)
fi

# konfiguráció hozzáadása, ha még nincs benne
if ! grep -q "include $INSTALL_PATH/*.nanorc" /etc/nanorc 2>/dev/null; then
    echo "include $INSTALL_PATH/*.nanorc" >> /etc/nanorc
fi

echo "=== Kész! System-wide szintaxis kiemelés beállítva. ==="



# Nano mint alapértelmezett szerkesztő beállítása (rendszerszintű)
echo "A 'nano' beállítása alapértelmezett szövegszerkesztőnek..."
#echo "export EDITOR=nano" >> /etc/profile
#echo "export VISUAL=nano" >> /etc/profile
echo "export EDITOR=nano" | sudo tee -a /etc/environment
echo "export EDITOR=nano" | sudo tee -a /etc/environment
#source /etc/profile
echo "nano beállítva alapértelmezett szerkesztőnek!"

echo "safe-lock.sh létrehozàsa..."
cat <<EOF > /usr/local/bin/safe-lock.sh
#!/usr/bin/env bash
# safe-lock.sh - xss-lock által hívva

LOCK_CMD="i3lock-fancy"

is_video_playing() {
  players=$(playerctl -l 2>/dev/null)
  [ -z "$players" ] && return 1

  for p in $players; do
    status=$(playerctl -p "$p" status 2>/dev/null || echo "")
    [ "$status" != "Playing" ] && continue

    media_type=$(playerctl -p "$p" metadata mpris:media-type 2>/dev/null || echo "")

    if [ "$media_type" = "Video" ]; then
      return 0
    fi

    case "$p" in
      mpv|chromium*|brave*|chrome*|grayjay*)
        return 0
        ;;
    esac
  done

  return 1
}

# Ha épp videó fut → ne lockoljon
if is_video_playing; then
  exit 0
fi

# Egyébként lock
exec $LOCK_CMD
EOF

chmod +x /usr/local/bin/safe-lock.sh

echo "Lock script elhelyezése."

# először felhasználó változók
USERNAME=$(logname)
USER_HOME=$(eval echo "~$USERNAME")


sudo -u "$USERNAME" bash -c 'echo ".xprofile létrehozása..." && cat <<EOF > ~/.xprofile
export QT_QPA_PLATFORMTHEME="qt5ct"
EOF'




USERNAME=$(logname)
USER_HOME=$(eval echo "~$USERNAME")

echo "AwesomeWM Copycats konfiguráció telepítése $USERNAME számára..."

cd /tmp
sudo -u "$USERNAME" -H git clone --branch Autoinstall --recurse-submodules --remote-submodules --depth 1 -j 2 \
  https://github.com/megvadulthangya/awesome-copycats-manjaro.git

# ha sikerült a klónozás
if [ -d /tmp/awesome-copycats-manjaro ]; then
  sudo -u "$USERNAME" -H mkdir -p "$USER_HOME/.config/awesome"
  sudo -u "$USERNAME" -H bash -c "mv -bv /tmp/awesome-copycats-manjaro/{*,.[^.]*} \"$USER_HOME/.config/awesome/\""
  rm -rf /tmp/awesome-copycats-manjaro
  echo "Telepítve ide: $USER_HOME/.config/awesome"
else
  echo "HIBA: Nem sikerült klónozni a repót!"
fi

# rc.lua kezelése
if [ -f "$HOME/.config/awesome/rc.lua.template" ]; then
    if [ -f "$HOME/.config/awesome/rc.lua" ]; then
        backup_file="$HOME/.config/awesome/rc.lua.backup-$(date +%Y%m%d%H%M%S)"
        cp "$HOME/.config/awesome/rc.lua" "$backup_file"
        echo "Biztonsági mentés készült: $backup_file"
        cp "$HOME/.config/awesome/rc.lua.template" "$HOME/.config/awesome/rc.lua"
        echo "rc.lua felülírva a sablonnal."
    else
        cp "$HOME/.config/awesome/rc.lua.template" "$HOME/.config/awesome/rc.lua"
        echo "rc.lua létrehozva a sablonból."
    fi
else
    echo "rc.lua.template nem található a ~/.config/awesome mappában!"
fi



# Rendszer újraindítása
echo "ùjraindîthatod a rendszert..."
#reboot
