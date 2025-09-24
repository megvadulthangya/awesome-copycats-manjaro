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


# Nano szintaxis kiemelés beállítása
echo "Nano szintaxis kiemelés beállítása..."
sudo git clone https://github.com/scopatz/nanorc.git $install_path

#mkdir -p "$USER_HOME/.nano"
#if [ ! -d "$USER_HOME/.nano/nanorc-files" ]; then
 # git clone https://github.com/scopatz/nanorc.git "$USER_HOME/.nano/nanorc-files"
#else
 # echo "Nanorc már létezik a $USER_HOME/.nano könyvtárban."
#fi
# Felhasználó .nanorc fájlának frissítése
#echo "include ~/.nano/nanorc-files/*.nanorc" >> "$USER_HOME/.nanorc"
echo "include $install_path/*.nanorc" >> /etc/nanorc

# Root számára is beállítjuk a nano szintaxis-kiemelést
#mkdir -p /root/.nano
#ln -sf "$USER_HOME/.nano/nanorc-files" /root/.nano/nanorc-files
#echo "include ~/.nano/nanorc-files/*.nanorc" >> /root/.nanorc

echo "Nano szintaxis kiemelés beállítva!"



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

echo ".xprofile létrehozàsa..."
cat <<EOF > ~/.xprofile
export QT_QPA_PLATFORMTHEME="qt5ct"
EOF



# AwesomeWM Copycats konfiguráció telepítése
echo "AwesomeWM Copycats konfiguráció telepítése..."

cd /tmp
sudo -u "$USERNAME" git clone --branch Autoinstall --recurse-submodules --remote-submodules --depth 1 -j 2 \
  https://github.com/megvadulthangya/awesome-copycats-manjaro.git

# Cél mappa létrehozása
sudo -u "$USERNAME" mkdir -p "$USER_HOME/.config/awesome"

# Átmásolás (git fájlokkal együtt)
sudo -u "$USERNAME" bash -c "mv -bv /tmp/awesome-copycats-manjaro/{*,.[^.]*} $USER_HOME/.config/awesome/"

# Klónozott repo törlése
rm -rf /tmp/awesome-copycats-manjaro

echo "AwesomeWM Copycats konfiguráció telepítve: $USER_HOME/.config/awesome"



# Rendszer újraindítása
echo "ùjraindîthatod a rendszert..."
#reboot
