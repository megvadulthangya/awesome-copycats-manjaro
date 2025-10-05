#!/bin/bash
set -euo pipefail
exec > >(tee -a setup.log) 2>&1

if [ "$(id -u)" -ne "0" ]; then
  echo "Ez a script root jogosultságokat igényel. Futtassa sudo-val vagy root-ként."
  exit 1
fi

# Felhasználó és home könyvtár meghatározása
if [ -n "${SUDO_USER:-}" ]; then
    USERNAME="$SUDO_USER"
else
    USERNAME=$(logname 2>/dev/null || echo "$(whoami)")
fi

USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)

if [ -z "$USER_HOME" ]; then
    echo "Hiba: Nem található a(z) '$USERNAME' felhasználó home könyvtára."
    exit 1
fi

echo "Felhasználó: $USERNAME"
echo "Felhasználó home: $USER_HOME"

# 1. PAMAC ELLENŐRZÉSE ÉS BEÁLLÍTÁSA (Manjaro specifikus)
if command -v pamac &> /dev/null; then
    echo "Pamac telepítve. Pamac konfiguráció ellenőrzése..."
    
    CONFIG_FILE="/etc/pamac.conf"
    AUR_SETTING="EnableAUR"

    if grep -q "^${AUR_SETTING}" "$CONFIG_FILE"; then
        echo "✅ Pamac AUR támogatás: Már engedélyezve."
    else
        if grep -q "^#${AUR_SETTING}" "$CONFIG_FILE"; then
            echo "⚠️ Pamac AUR támogatás: Tiltva. Engedélyezés..."
            sed -i "/^#${AUR_SETTING}/s/^#//g" "$CONFIG_FILE"
            echo "✅ Pamac AUR támogatás: Sikeresen engedélyezve."
        else
            echo "❌ Hiba: Az '${AUR_SETTING}' beállítás formátuma nem megfelelő a(z) '${CONFIG_FILE}' fájlban."
        fi
    fi
    
    pamac update --force-refresh
    echo "Pamac adatbázisok frissítve."
else
    echo "Pamac nem található. Egyéb AUR segítők ellenőrzése..."
    
    if command -v yay &> /dev/null; then
        echo "Yay telepítve. Az AUR alapértelmezetten elérhető a 'yay' paranccsal."
    elif command -v paru &> /dev/null; then
        echo "Paru telepítve. Az AUR alapértelmezetten elérhető a 'paru' paranccsal."
    else
        echo "Nincs telepített Pamac, Yay vagy Paru. Kézi AUR segéd telepítés szükséges."
    fi
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
  dmenu rofi flameshot picom scrot unclutter xorg-xbacklight alsa-utils mpd mpc playerctl xorg-fonts-misc ttf-roboto woff2-font-awesome arandr lxappearance lxqt-policykit xorg-xev terminus-font xss-lock wavemon network-manager-applet feh qt6ct geany ttf-firacode-nerd fish starship bat eza jq fzf nano-syntax-highlighting noto-fonts-emoji
)

echo "Repo csomagok telepítése..."
install_repo "${REPO_PKGS[@]}"

# --- AUR csomagok ---
AUR_PKGS=(
  raw-thumbnailer lain-git awesome-git awesome-freedesktop-git tilix-git tamzen-font i3lock-fancy-git grayjay-bin betterlockscreen nordic-theme nordic-darker-theme nordic-darker-standard-buttons-theme nordic-polar-standard-buttons-theme nordic-standard-buttons-theme nordic-bluish-accent-theme nordic-bluish-accent-standard-buttons-theme geany-nord-theme nordzy-icon-theme nordic-wallpapers-git oh-my-posh-bin fish-done find-the-command
)

echo "AUR csomagok telepítése..."
install_aur "${AUR_PKGS[@]}"

# --- Ikon font telepítése ---
echo "Ikon font telepítése $USERNAME számára..."
sudo -u "$USERNAME" mkdir -p "$USER_HOME/.local/share/fonts"
sudo -u "$USERNAME" curl -fL -o "$USER_HOME/.local/share/fonts/Icons.bdf" \
  https://raw.githubusercontent.com/lcpz/dots/refs/heads/master/.fonts/Icons.bdf

echo "Removing inappropriate wallpapers from nordic-wallpapers-git ..."
rm -f /usr/share/backgrounds/nordic-wallpapers-git/artix-nord.png \
      /usr/share/backgrounds/nordic-wallpapers-git/debian.png \
      /usr/share/backgrounds/nordic-wallpapers-git/debian-galaxy.png \
      /usr/share/backgrounds/nordic-wallpapers-git/elementaryos.png \
      /usr/share/backgrounds/nordic-wallpapers-git/fedora.png \
      /usr/share/backgrounds/nordic-wallpapers-git/gnu-linux.png \
      /usr/share/backgrounds/nordic-wallpapers-git/ign_endeavour1.png \
      /usr/share/backgrounds/nordic-wallpapers-git/ign_endeavour2.png \
      /usr/share/backgrounds/nordic-wallpapers-git/ign_endeavour3.png \
      /usr/share/backgrounds/nordic-wallpapers-git/ign_endeavour4.png \
      /usr/share/backgrounds/nordic-wallpapers-git/ign-hevlettpackard.png \
      /usr/share/backgrounds/nordic-wallpapers-git/ign_windows_11.png \
      /usr/share/backgrounds/nordic-wallpapers-git/ign_zorin.png \
      /usr/share/backgrounds/nordic-wallpapers-git/Minimal-Nord.png \
      /usr/share/backgrounds/nordic-wallpapers-git/nixos.png \
      /usr/share/backgrounds/nordic-wallpapers-git/nordic-obsession.png \
      /usr/share/backgrounds/nordic-wallpapers-git/nordtheme.png \
      /usr/share/backgrounds/nordic-wallpapers-git/nord_triangles.png \
      /usr/share/backgrounds/nordic-wallpapers-git/openbsd.png \
      /usr/share/backgrounds/nordic-wallpapers-git/opensuse.png \
      /usr/share/backgrounds/nordic-wallpapers-git/rocket.png \
      /usr/share/backgrounds/nordic-wallpapers-git/slackware.png \
      /usr/share/backgrounds/nordic-wallpapers-git/ubuntu-aurora.png \
      /usr/share/backgrounds/nordic-wallpapers-git/ubuntu-frost.png \
      /usr/share/backgrounds/nordic-wallpapers-git/voidlinux.png \
      /usr/share/backgrounds/nordic-wallpapers-git/voidlinux-01.png

echo "Telepítés befejezve!"

# ------------------------------------------------------
# Adi1090x Rofi témák telepítése
# ------------------------------------------------------
echo "[INFO] Rofi témák telepítése a megvadulthangya forkjából..."

if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)

    runuser -l "$SUDO_USER" -c '
        echo "[INFO] Rofi témák letöltése a GitHubról...";
        cd /tmp;
        rm -rf rofi;
        git clone --depth=1 -b my-awesome-config https://github.com/megvadulthangya/Awesome-rofi.git rofi;
        cd rofi;
        echo "[INFO] Betűtípusok telepítése...";
        FONT_DIR="$HOME/.local/share/fonts";
        mkdir -p "$FONT_DIR";
        cp -rf fonts/* "$FONT_DIR";
        
        echo "[INFO] Betűtípus gyorsítótár frissítése...";
        fc-cache -f -v;
        
        ROFI_DIR="$HOME/.config/rofi";
        if [[ -d "$ROFI_DIR" ]]; then
            echo "[INFO] Meglévő Rofi konfiguráció biztonsági mentése ide: ${ROFI_DIR}.bak";
            mv "$ROFI_DIR" "${ROFI_DIR}.bak";
        fi
        
        echo "[INFO] Rofi témák telepítése...";
        mkdir -p "$ROFI_DIR";
        cp -rf files/* "$ROFI_DIR";
        
        echo "[SUCCESS] Rofi témák sikeresen telepítve.";
    '
    
    echo "[INFO] Ideiglenes fájlok törlése..."
    rm -rf /tmp/rofi
    
else
    echo "[HIBA] A scriptet sudo-val kell futtatni, hogy a felhasználói beállításokat elvégezhesse!"
    echo "[HIBA] A Rofi témák telepítése kimarad."
fi

echo "[INFO] Rofi téma telepítése kész."

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
echo "export EDITOR=nano" | tee -a /etc/environment
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

# --- AwesomeWM Copycats ---
echo "AwesomeWM Copycats konfiguráció telepítése $USERNAME számára..."
cd /tmp
sudo -u "$USERNAME" -H git clone --branch Autoinstall --recurse-submodules --remote-submodules --depth 1 -j 2 \
  https://github.com/megvadulthangya/awesome-copycats-manjaro.git

if [ -d /tmp/awesome-copycats-manjaro ]; then

 # --- Nordic-cursors téma telepítése ---
  CURSOR_ARCHIVE="/tmp/awesome-copycats-manjaro/Nordic-cursors.tar.xz"
  if [ -f "$CURSOR_ARCHIVE" ]; then
    echo "Nordic-cursors téma telepítése..."
    tar -xJf "$CURSOR_ARCHIVE" -C /usr/share/icons/ && \
    rm "$CURSOR_ARCHIVE" && \
    echo "✅ Nordic-cursors téma sikeresen telepítve és az archívum törölve."
  else
    echo "FIGYELMEZTETÉS: A Nordic-cursors.tar.xz nem található, a kurzor telepítése kihagyva."
  fi
  
  # --- Fish konfiguráció telepítése ---
  FISH_CONFIG_ARCHIVE="/tmp/awesome-copycats-manjaro/fish.cfg.tar.xz"
  if [ -f "$FISH_CONFIG_ARCHIVE" ]; then
    echo "Fish konfiguráció telepítése..."
    FISH_CONFIG_DIR="$USER_HOME/.config/fish"
    sudo -u "$USERNAME" -H mkdir -p "$FISH_CONFIG_DIR" && \
    sudo -u "$USERNAME" -H tar -xJf "$FISH_CONFIG_ARCHIVE" -C "$FISH_CONFIG_DIR/" && \
    rm "$FISH_CONFIG_ARCHIVE" && \
    echo "✅ Fish konfiguráció sikeresen telepítve és az archívum törölve."
  else
    echo "FIGYELMEZTETÉS: A fish.cfg.tar.xz nem található, a fish konfiguráció telepítése kihagyva."
  fi
  
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
        sudo -u "$USERNAME" -H cp "$USER_HOME/.config/awesome/rc.lua" "$backup_file"
        echo "Biztonsági mentés készült: $backup_file"
        sudo -u "$USERNAME" -H cp "$USER_HOME/.config/awesome/rc.lua.template" "$USER_HOME/.config/awesome/rc.lua"
        echo "rc.lua felülírva a sablonnal."
    else
        sudo -u "$USERNAME" -H cp "$USER_HOME/.config/awesome/rc.lua.template" "$USER_HOME/.config/awesome/rc.lua"
        echo "rc.lua létrehozva a sablonból."
    fi
else
    echo "rc.lua.template nem található a $USER_HOME/.config/awesome mappában!"
fi

# 1. Lekérjük az eredeti felhasználó home könyvtárát
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)

if [ -z "$USER_HOME" ]; then
    echo "Hiba: Nem található a(z) '$SUDO_USER' felhasználó home könyvtára."
    exit 1
fi

# 2. Definiáljuk a célfájl elérési útját
AWESOME_CONFIG_PATH="${USER_HOME}/.config/awesome/rc.lua"

echo "A célkonfigurációs fájl: ${AWESOME_CONFIG_PATH}"

# 3. Ellenőrizzük, hogy a fájl létezik-e, mielőtt módosítanánk
if [ -f "$AWESOME_CONFIG_PATH" ]; then
    sed -i "s|__USER_HOME__|${USER_HOME}|g" "$AWESOME_CONFIG_PATH"
    echo "✅ Az rc.lua fájl sikeresen frissítve a(z) '${USER_HOME}' elérési úttal."
else
    echo "Hiba: A(z) ${AWESOME_CONFIG_PATH} fájl nem található!"
    exit 1
fi

echo "=== i3lock-fancy javítása (convert → magick convert) ==="
if [ -f /usr/bin/i3lock-fancy ]; then
  sed -i 's/\bconvert\b/magick/g' /usr/bin/i3lock-fancy
  echo "i3lock-fancy sikeresen javítva!"
else
  echo "Figyelem: /usr/bin/i3lock-fancy nem található."
fi

# ----------------------------------------------------------------------
# XFCE NORDIC TÉMA BEÁLLÍTÓ SCRIPTE (SUDO-KOMPATIBILIS)
# ----------------------------------------------------------------------

# 1. Célfelhasználó azonosítása
if [ "$EUID" -ne 0 ]; then
  echo "Hiba: A szkriptet root jogosultságokkal (sudo-val) kell futtatni."
  exit 1
fi

TARGET_USER=${SUDO_USER}

if [ -z "$TARGET_USER" ]; then
  TARGET_USER=$(logname 2>/dev/null)
fi

if [ -z "$TARGET_USER" ]; then
  echo "Hiba: Nem sikerült azonosítani a célfelhasználót (SUDO_USER üres vagy logname sikertelen)."
  echo "A szkript futtatása megszakítva."
  exit 1
fi

TARGET_UID=$(id -u ${TARGET_USER})
RUNNER="sudo -u ${TARGET_USER} DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${TARGET_UID}/bus"

echo "Beállítások futtatása a következő felhasználó nevében: ${TARGET_USER} (UID: ${TARGET_UID})"
echo "---"

# 3. Xfconf beállítások elindítása
echo "-> GTK Téma beállítása: Nordic"
${RUNNER} xfconf-query -c xsettings -p /Net/ThemeName -s "Nordic" --create -t string

echo "-> Ikon Téma beállítása: Nordzy-dark"
${RUNNER} xfconf-query -c xsettings -p /Net/IconThemeName -s "Nordzy-dark" --create -t string

echo "-> Egérmutató Téma beállítása: Nordic-cursors"
${RUNNER} xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Nordic-cursors" --create -t string

echo "-> Színpaletta beállítása..."
COLOR_PALETTE="black:white:gray50:red:purple:blue:light blue:green:yellow:orange:lavender:brown:goldenrod4:dodger blue:pink:light green:gray10:gray30:gray75:gray90"
${RUNNER} xfconf-query -c xsettings -p /Gtk/ColorPalette -s "${COLOR_PALETTE}" --create -t string

echo "---"
echo "✅ Az Xfce Nordic téma beállításai sikeresen alkalmazva a ${TARGET_USER} felhasználónak."

# ----------------------------------------------------------------------
# GTK ÉS QT BEÁLLÍTÁSOK
# ----------------------------------------------------------------------

# Ellenőrizzük, hogy a scriptet root-ként (sudo-val) futtatják-e
if [ "$EUID" -ne 0 ]; then
  echo "Kérlek futtasd ezt a scriptet sudo-val: sudo $0"
  exit 1
fi

# A felhasználó, aki a sudo-t használta
REGULAR_USER=${SUDO_USER:-root}
REGULAR_USER_HOME=$(eval echo ~$REGULAR_USER)

# --- GTK BEÁLLÍTÁSOK ---
apply_gtk_settings() {
  local TARGET_HOME=$1
  local TARGET_USER=$2

  echo "=> GTK beállítások alkalmazása a(z) '$TARGET_USER' felhasználó számára a '$TARGET_HOME' mappában..."

  # GTK-2.0 beállítások
  cat <<EOF > "$TARGET_HOME/.gtkrc-2.0"
# DO NOT EDIT! This file will be overwritten by LXAppearance.
# Any customization should be done in ~/.gtkrc-2.0.mine instead.

include "~/.gtkrc-2.0.mine"
gtk-theme-name="Nordic"
gtk-icon-theme-name="Nordzy-dark"
gtk-font-name="Noto Sans 10"
gtk-cursor-theme-name="Nordic-cursors"
gtk-cursor-theme-size=16
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintfull"
gtk-xft-rgba="none"
EOF

  # GTK-3.0 beállítások
  mkdir -p "$TARGET_HOME/.config/gtk-3.0"
  cat <<EOF > "$TARGET_HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Nordic
EOF

  # Tulajdonos beállítása
  chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.gtkrc-2.0" "$TARGET_HOME/.config"
  echo "GTK2/GTK3 kész!"
  echo
}

# --- QT BEÁLLÍTÁSOK ---
apply_qt_settings() {
  local TARGET_HOME=$1
  local TARGET_USER=$2

  echo "=> Qt5/Qt6 beállítások alkalmazása a(z) '$TARGET_USER' felhasználó számára a '$TARGET_HOME' mappában..."

  # --- Qt5ct ---
  mkdir -p "$TARGET_HOME/.config/qt5ct"
  cat <<EOF > "$TARGET_HOME/.config/qt5ct/qt5ct.conf"
[Appearance]
color_scheme_path=/usr/share/qt5ct/colors/darker.conf
custom_palette=true
icon_theme=Nordzy-dark
standard_dialogs=default
style=Fusion

[Fonts]
fixed="Cantarell,10,-1,5,50,0,0,0,0,0"
general="Cantarell,10,-1,5,50,0,0,0,0,0"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=3
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[SettingsWindow]
geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\0\x4\xff\0\0\x2\xfa\0\0\0\0\0\0\0\x1c\0\0\x4\xff\0\0\x2\xfa\0\0\0\0\x2\0\0\0\x5\0\0\0\0\0\0\0\0 \0\0\x4\xff\0\0\x2\xfa)

[Troubleshooting]
force_raster_widgets=1
ignored_applications=@Invalid()
EOF

  # --- Qt6ct ---
  mkdir -p "$TARGET_HOME/.config/qt6ct"
  cat <<EOF > "$TARGET_HOME/.config/qt6ct/qt6ct.conf"
[Appearance]
custom_palette=false
icon_theme=Nordzy-dark
standard_dialogs=default
style=kvantum

[Fonts]
fixed="DejaVu LGC Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
general="DejaVu LGC Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1200
dialog_buttons_have_icons=1
double_click_interval=532
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[SettingsWindow]
geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\0\x4\xff\0\0\x2\xfa\0\0\0\0\0\0\0 \0\0\x4\xff\0\0\x2\xfa\0\0\0\0\x2\0\0\0\x5\0\0\0\0\0\0\0\0 \0\0\x4\xff\0\0\x2\xfa)

[Troubleshooting]
force_raster_widgets=1
ignored_applications=@Invalid()
EOF

  # Tulajdonos beállítása
  chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/qt5ct" "$TARGET_HOME/.config/qt6ct"
  echo "Qt5/Qt6 kész!"
  echo
}

# --- A SCRIPT FŐ RÉSZE: A FUNKCIÓ MEGHÍVÁSA ---

# 1. Alkalmazzuk a beállításokat a SUDO-t futtató felhasználóra
if [ "$REGULAR_USER" != "root" ]; then
    apply_gtk_settings "$REGULAR_USER_HOME" "$REGULAR_USER"
    apply_qt_settings "$REGULAR_USER_HOME" "$REGULAR_USER"
else
    echo "=> A scriptet közvetlenül root-ként futtatod, a felhasználói beállításokat átugorjuk."
    echo
fi

# 2. Alkalmazzuk a beállításokat a ROOT felhasználóra
apply_gtk_settings ~ "root"
apply_qt_settings ~ "root"

echo "Minden GTK és Qt beállítás sikeresen alkalmazva."

# ----------------------------------------------------------------------
# KVANTUM TÉMÁK TELEPÍTÉSE RENDSZERSZINTEN
# ----------------------------------------------------------------------

echo "=== Kvantum témák telepítése rendszerszinten ==="

# Kvantum témák letöltése és RENDSZERSZINTŰ telepítése
echo "Nordic Kvantum témák letöltése rendszerszintre..."
cd /tmp
if [ -d "Nordic" ]; then
    rm -rf Nordic
fi

git clone --depth=1 https://github.com/EliverLara/Nordic.git
cd Nordic/kde/kvantum

# RENDSZERSZINTŰ témák telepítése - /usr/share/Kvantum mappába
KVANTUM_SYSTEM_DIR="/usr/share/Kvantum"
mkdir -p "$KVANTUM_SYSTEM_DIR"

# Témák kicsomagolása RENDSZERSZINTŰ könyvtárba
for theme_file in *.tar.xz; do
    if [ -f "$theme_file" ]; then
        theme_name="${theme_file%.tar.xz}"
        echo "Kvantum téma telepítése rendszerszintre: $theme_name"
        tar -xf "$theme_file" -C "$KVANTUM_SYSTEM_DIR/"
        # Jogok beállítása, hogy mindenki elérhesse
        chmod -R 755 "$KVANTUM_SYSTEM_DIR/$theme_name"
    fi
done

# Ha nincsenek tar.xz fájlok, akkor a mappákat másoljuk
if [ ! -f "Nordic.tar.xz" ]; then
    for theme_dir in Nordic*; do
        if [ -d "$theme_dir" ]; then
            echo "Kvantum téma másolása rendszerszintre: $theme_dir"
            cp -r "$theme_dir" "$KVANTUM_SYSTEM_DIR/"
            chmod -R 755 "$KVANTUM_SYSTEM_DIR/$theme_dir"
        fi
    done
fi

echo "✅ Kvantum témák telepítve rendszerszinten"

# Takarítás
cd /
rm -rf /tmp/Nordic

# ----------------------------------------------------------------------
# LIGHTDM GREETER BEÁLLÍTÁSA
# ----------------------------------------------------------------------

echo "=== LightDM GTK Greeter beállítása ==="

# Ellenőrizzük, hogy a kép fájl létezik-e
BACKGROUND_FILE="/usr/share/backgrounds/nordic-wallpapers-git/ign_groot.png"
if [ ! -f "$BACKGROUND_FILE" ]; then
    echo "Figyelem: A háttérkép nem található: $BACKGROUND_FILE"
    echo "Alternatív háttérkép keresése..."
    # Alternatív háttérkép keresése
    ALTERNATIVE_BG=$(find /usr/share/backgrounds/nordic-wallpapers-git -name "*.png" -o -name "*.jpg" | head -1)
    if [ -n "$ALTERNATIVE_BG" ]; then
        BACKGROUND_FILE="$ALTERNATIVE_BG"
        echo "Alternatív háttérkép használata: $BACKGROUND_FILE"
    else
        echo "Hiba: Nem található háttérkép a nordic-wallpapers-git mappában!"
    fi
fi

# LightDM config fájl biztonsági mentése
LIGHTDM_CONFIG="/etc/lightdm/lightdm-gtk-greeter.conf"
if [ -f "$LIGHTDM_CONFIG" ]; then
    cp "$LIGHTDM_CONFIG" "${LIGHTDM_CONFIG}.backup.$(date +%Y%m%d%H%M%S)"
    echo "LightDM config biztonsági mentése kész"
fi

# LightDM greeter konfiguráció alkalmazása
echo "LightDM greeter konfiguráció beállítása..."
cat > "$LIGHTDM_CONFIG" << EOF
[greeter]
background = $BACKGROUND_FILE
user-background = false
font-name = FiraCode Nerd Font 12
xft-antialias = true
icon-theme-name = Nordzy
screensaver-timeout = 60
theme-name = Nordic
cursor-theme-name = Nordic-cursors
show-clock = true
default-user-image = #manjaro
xft-hintstyle = hintfull
position = 20%,center 40%,center
clock-format = %Y.%m.%d %H:%M
panel-position = bottom
indicators = ~host;~spacer;~clock;~spacer;~language;~session;~a11y;~power
EOF

echo "✅ LightDM GTK Greeter beállítva"

# ----------------------------------------------------------------------
# FISH SHELL ALAPÉRTELMEZETTÉ TÉTELE
# ----------------------------------------------------------------------

echo "=== Fish shell alapértelmezetté tétele ==="

# A Fish shell teljes elérési útjának megkeresése
FISH_PATH=$(command -v fish)

# Ellenőrzés, hogy a Fish telepítve van-e
if [ -z "$FISH_PATH" ]; then
    echo "Hiba: A Fish shell nincs telepítve vagy nem található az elérési útvonalon."
    exit 1
fi

echo "Fish shell alapértelmezetté tétele..."

# Hozzáadjuk a Fish-t az engedélyezett shellekhez, ha még nem szerepel ott
if ! grep -q "^${FISH_PATH}$" /etc/shells; then
    echo "A(z) '$FISH_PATH' hozzáadása a /etc/shells fájlhoz..."
    echo "$FISH_PATH" | tee -a /etc/shells
fi

# Alapértelmezett shell beállítása a root felhasználónak
echo "Shell beállítása a 'root' felhasználónak..."
chsh -s "$FISH_PATH" root

echo "Kész! A Fish shell sikeresen beállítva."

# ===========================================================================
# === KONFIGURÁCIÓS FÁJLOK BEÁLLÍTÁSA - JELENLEGI FELHASZNÁLÓ ÉS /etc/skel ===
# ===========================================================================

echo "=== Konfigurációs fájlok beállítása mindenkinek ==="

# --- Függvény fájlok másolására felhasználóhoz és /etc/skel-be ---
setup_config_file() {
    local source_content="$1"
    local user_path="$2"
    local skel_path="/etc/skel/${user_path#$USER_HOME/}"
    local user_dir=$(dirname "$user_path")
    local skel_dir=$(dirname "$skel_path")
    
    # Felhasználói fájl létrehozása
    echo "  Felhasználó: $user_path"
    sudo -u "$USERNAME" mkdir -p "$user_dir"
    echo "$source_content" | sudo -u "$USERNAME" tee "$user_path" > /dev/null
    
    # /etc/skel fájl létrehozása
    echo "  /etc/skel: $skel_path"
    mkdir -p "$skel_dir"
    echo "$source_content" | tee "$skel_path" > /dev/null
}

# --- Geany color scheme ---
echo "Geany color scheme beállítása..."
setup_config_file '[geany]
color_scheme=nord.conf' "$USER_HOME/.config/geany/geany.conf"

# --- Zsh beállítások ---
echo "Zsh beállítása..."
setup_config_file '# Use powerline
USE_POWERLINE="true"
# Has weird character width
# Example:
#    is not a diamond
HAS_WIDECHARS="false"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi' "$USER_HOME/.zshrc"

# --- Kvantum beállítás ---
echo "Kvantum beállítása..."
setup_config_file '[General]
theme=Nordic' "$USER_HOME/.config/kvantum/kvantum.kvconfig"

# --- .xprofile beállítás ---
echo ".xprofile beállítása..."
setup_config_file 'export QT_QPA_PLATFORMTHEME="qt6ct"' "$USER_HOME/.xprofile"

# --- .profile beállítás ---
echo ".profile beállítása..."
setup_config_file 'export EDITOR=/usr/bin/nano
export QT_QPA_PLATFORMTHEME="qt6ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"' "$USER_HOME/.profile"

# === Bashrc beállítások (biztonságos, hozzáfűző módszer) ===
echo "Bashrc beállítása (hozzáfűzéssel)..."

# Definiáljuk a kódrészletet, amit hozzá akarunk adni
VTE_SNIPPET=$(cat <<'EOF'

# Automatikusan hozzáadva a Tilix/VTE integrációhoz
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
    source /etc/profile.d/vte.sh
fi
EOF
)

# --- 1. Felhasználói .bashrc módosítása ---
BASHRC_USER_PATH="$USER_HOME/.bashrc"
echo "  Ellenőrzés: $BASHRC_USER_PATH"

# Ellenőrizzük, hogy a bejegyzés már létezik-e, hogy elkerüljük a duplikációt
if ! grep -q "source /etc/profile.d/vte.sh" "$BASHRC_USER_PATH" 2>/dev/null; then
    echo "  VTE bejegyzés hozzáadása a felhasználó .bashrc fájljához..."
    # Hozzáfűzzük a kódrészletet a fájl végéhez
    echo "$VTE_SNIPPET" | sudo -u "$USERNAME" tee -a "$BASHRC_USER_PATH" > /dev/null
else
    echo "  A VTE bejegyzés már létezik, nincs teendő."
fi

# --- 2. /etc/skel/.bashrc módosítása ---
BASHRC_SKEL_PATH="/etc/skel/.bashrc"
echo "  Ellenőrzés: $BASHRC_SKEL_PATH"

# Itt is ellenőrizzük a duplikációt
if ! grep -q "source /etc/profile.d/vte.sh" "$BASHRC_SKEL_PATH" 2>/dev/null; then
    echo "  VTE bejegyzés hozzáadása a /etc/skel/.bashrc fájlhoz..."
    # Hozzáfűzzük a kódrészletet a fájl végéhez (itt már nem kell sudo -u)
    echo "$VTE_SNIPPET" | tee -a "$BASHRC_SKEL_PATH" > /dev/null
else
    echo "  A VTE bejegyzés már létezik, nincs teendő."
fi

echo "Bashrc beállítása kész."

# --- XFCE xsettings beállítások ---
echo "XFCE xsettings beállítása..."
setup_config_file '<?xml version="1.1" encoding="UTF-8"?>

<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Nordic"/>
    <property name="IconThemeName" type="string" value="Nordzy-dark"/>
    <property name="DoubleClickTime" type="int" value="532"/>
    <property name="DoubleClickDistance" type="int" value="8"/>
    <property name="DndDragThreshold" type="int" value="8"/>
    <property name="CursorBlink" type="bool" value="true"/>
    <property name="CursorBlinkTime" type="int" value="1200"/>
    <property name="SoundThemeName" type="string" value="default"/>
    <property name="EnableEventSounds" type="bool" value="false"/>
    <property name="EnableInputFeedbackSounds" type="bool" value="false"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="int" value="96"/>
    <property name="Antialias" type="int" value="1"/>
    <property name="Hinting" type="int" value="-1"/>
    <property name="HintStyle" type="string" value="hintfull"/>
    <property name="RGBA" type="string" value="none"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CanChangeAccels" type="bool" value="false"/>
    <property name="ColorPalette" type="string" value="black:white:gray50:red:purple:blue:light blue:green:yellow:orange:lavender:brown:goldenrod4:dodger blue:pink:light green:gray10:gray30:gray75:gray90"/>
    <property name="FontName" type="string" value="Noto Sans 10"/>
    <property name="MonospaceFontName" type="empty"/>
    <property name="IconSizes" type="string" value=""/>
    <property name="KeyThemeName" type="string" value=""/>
    <property name="MenuImages" type="bool" value="true"/>
    <property name="ButtonImages" type="bool" value="true"/>
    <property name="MenuBarAccel" type="string" value="F10"/>
    <property name="CursorThemeName" type="string" value="Nordic-cursors"/>
    <property name="CursorThemeSize" type="int" value="0"/>
    <property name="DecorationLayout" type="string" value="icon,menu:minimize,maximize,close"/>
    <property name="DialogsUseHeader" type="empty"/>
    <property name="TitlebarMiddleClick" type="empty"/>
    <property name="ToolbarStyle" type="string" value="icons"/>
    <property name="ToolbarIconSize" type="int" value="3"/>
    <property name="IMPreeditStyle" type="string" value=""/>
    <property name="IMStatusStyle" type="string" value=""/>
    <property name="IMModule" type="string" value=""/>
  </property>
  <property name="Gdk" type="empty">
    <property name="WindowScalingFactor" type="empty"/>
  </property>
  <property name="Xfce" type="empty">
    <property name="LastCustomDPI" type="int" value="96"/>
  </property>
</channel>' "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"

# --- XFCE xfwm4 beállítások ---
echo "XFCE xfwm4 beállítása..."
setup_config_file '<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="activate_action" type="string" value="bring"/>
    <property name="borderless_maximize" type="bool" value="true"/>
    <property name="box_move" type="bool" value="false"/>
    <property name="box_resize" type="bool" value="false"/>
    <property name="button_layout" type="string" value="O|SHMC"/>
    <property name="button_offset" type="int" value="0"/>
    <property name="button_spacing" type="int" value="0"/>
    <property name="click_to_focus" type="bool" value="true"/>
    <property name="focus_delay" type="int" value="250"/>
    <property name="cycle_apps_only" type="bool" value="false"/>
    <property name="cycle_draw_frame" type="bool" value="true"/>
    <property name="cycle_hidden" type="bool" value="true"/>
    <property name="cycle_minimum" type="bool" value="true"/>
    <property name="cycle_workspaces" type="bool" value="false"/>
    <property name="double_click_time" type="int" value="250"/>
    <property name="double_click_distance" type="int" value="5"/>
    <property name="double_click_action" type="string" value="maximize"/>
    <property name="easy_click" type="string" value="Alt"/>
    <property name="focus_hint" type="bool" value="true"/>
    <property name="focus_new" type="bool" value="true"/>
    <property name="frame_opacity" type="int" value="100"/>
    <property name="full_width_title" type="bool" value="true"/>
    <property name="inactive_opacity" type="int" value="100"/>
    <property name="maximized_offset" type="int" value="0"/>
    <property name="move_opacity" type="int" value="100"/>
    <property name="placement_ratio" type="int" value="60"/>
    <property name="placement_mode" type="string" value="center"/>
    <property name="popup_opacity" type="int" value="100"/>
    <property name="mousewheel_rollup" type="bool" value="true"/>
    <property name="prevent_focus_stealing" type="bool" value="false"/>
    <property name="raise_delay" type="int" value="250"/>
    <property name="raise_on_click" type="bool" value="true"/>
    <property name="raise_on_focus" type="bool" value="false"/>
    <property name="raise_with_any_button" type="bool" value="true"/>
    <property name="repeat_urgent_blink" type="bool" value="false"/>
    <property name="resize_opacity" type="int" value="100"/>
    <property name="restore_on_move" type="bool" value="true"/>
    <property name="scroll_workspaces" type="bool" value="true"/>
    <property name="shadow_delta_height" type="int" value="0"/>
    <property name="shadow_delta_width" type="int" value="0"/>
    <property name="shadow_delta_x" type="int" value="0"/>
    <property name="shadow_delta_y" type="int" value="-3"/>
    <property name="shadow_opacity" type="int" value="50"/>
    <property name="show_app_icon" type="bool" value="false"/>
    <property name="show_dock_shadow" type="bool" value="true"/>
    <property name="show_frame_shadow" type="bool" value="true"/>
    <property name="show_popup_shadow" type="bool" value="false"/>
    <property name="snap_resist" type="bool" value="false"/>
    <property name="snap_to_border" type="bool" value="true"/>
    <property name="snap_to_windows" type="bool" value="false"/>
    <property name="snap_width" type="int" value="10"/>
    <property name="theme" type="string" value="Nordic-standard-buttons"/>
    <property name="title_alignment" type="string" value="center"/>
    <property name="title_font" type="string" value="Noto Sans 10"/>
    <property name="title_horizontal_offset" type="int" value="0"/>
    <property name="title_shadow_active" type="string" value="false"/>
    <property name="title_shadow_inactive" type="string" value="false"/>
    <property name="title_vertical_offset_active" type="int" value="0"/>
    <property name="title_vertical_offset_inactive" type="int" value="0"/>
    <property name="toggle_workspaces" type="bool" value="false"/>
    <property name="unredirect_overlays" type="bool" value="true"/>
    <property name="urgent_blink" type="bool" value="false"/>
    <property name="use_compositing" type="bool" value="true"/>
    <property name="workspace_count" type="int" value="2"/>
    <property name="wrap_cycle" type="bool" value="true"/>
    <property name="wrap_layout" type="bool" value="true"/>
    <property name="wrap_resistance" type="int" value="10"/>
    <property name="wrap_windows" type="bool" value="true"/>
    <property name="wrap_workspaces" type="bool" value="false"/>
    <property name="workspace_names" type="array">
      <value type="string" value="Workspace 1"/>
      <value type="string" value="Workspace 2"/>
      <value type="string" value="Workspace 3"/>
      <value type="string" value="Workspace 4"/>
    </property>
    <property name="tile_on_move" type="bool" value="true"/>
    <property name="titleless_maximize" type="bool" value="false"/>
    <property name="cycle_preview" type="bool" value="true"/>
    <property name="cycle_tabwin_mode" type="int" value="0"/>
    <property name="sync_to_vblank" type="bool" value="true"/>
    <property name="zoom_desktop" type="bool" value="true"/>
  </property>
</channel>' "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml"

# --- Flameshot beállítások ---
echo "Flameshot beállítása..."
setup_config_file '[General]
contrastOpacity=188
drawColor=#ff0000
uiColor=#f5eef8' "$USER_HOME/.config/flameshot/flameshot.ini"

# --- Fontok áthelyezése rendszerszintűvé ---
echo "Fontok áthelyezése rendszerszintűvé..."
mkdir -p /usr/share/fonts/truetype/custom

# Felhasználó fontjainak áthelyezése
if [ -d "$USER_HOME/.local/share/fonts" ]; then
    echo "Felhasználó fontjainak áthelyezése rendszerszintűvé..."
    mv "$USER_HOME/.local/share/fonts"/* /usr/share/fonts/truetype/custom/ 2>/dev/null || true
    rmdir "$USER_HOME/.local/share/fonts" 2>/dev/null || true
fi

# /etc/skel font mappa ürítése, mert a fontok most már rendszerszintűek
if [ -d "/etc/skel/.local/share/fonts" ]; then
    echo "/etc/skel font mappa ürítése..."
    rm -rf /etc/skel/.local/share/fonts
fi

fc-cache -fv
echo "✅ Fontok áthelyezve rendszerszintűvé: /usr/share/fonts/truetype/custom/"

# --- AwesomeWM és Rofi másolása /etc/skel-be ---
echo "AwesomeWM és Rofi konfiguráció másolása /etc/skel-be..."
if [ -d "$USER_HOME/.config/awesome" ]; then
    mkdir -p /etc/skel/.config
    cp -r "$USER_HOME/.config/awesome" /etc/skel/.config/
    # Sablonosítjuk a rc.lua-t
    if [ -f "/etc/skel/.config/awesome/rc.lua" ]; then
        sed -i "s|${USER_HOME}|__USER_HOME__|g" "/etc/skel/.config/awesome/rc.lua"
    fi
fi

if [ -d "$USER_HOME/.config/rofi" ]; then
    mkdir -p /etc/skel/.config
    cp -r "$USER_HOME/.config/rofi" /etc/skel/.config/
fi

if [ -d "$USER_HOME/.config/fish" ]; then
    mkdir -p /etc/skel/.config
    cp -r "$USER_HOME/.config/fish" /etc/skel/.config/
fi



echo "=== 💣 Mission Impossibru - Dual-Stage Edition w/ Logging ==="

USERNAME=$(logname)
USER_HOME=$(eval echo "~$USERNAME")
SOURCE_DIR="$USER_HOME/.config/rofi/scripts"
TARGET_DIR="$USER_HOME/.local/bin"
SKEL_DIR="/etc/skel"
MAIN_SCRIPT_NAME="mission_impossibru.sh"
USER_SCRIPT_NAME="mission_user_firstlogin.sh"

echo "👤 Aktuális felhasználó: $USERNAME"
echo "🏠 Home: $USER_HOME"

# === SYMLINK LÉTREHOZÁS (rootként) ===
mkdir -p "$TARGET_DIR"
chown "$USERNAME:$USERNAME" "$TARGET_DIR"
chmod 755 "$TARGET_DIR"

if [ -d "$SOURCE_DIR" ]; then
for item in "$SOURCE_DIR"/*; do
[ -e "$item" ] || continue
ln -sf "$item" "$TARGET_DIR/$(basename "$item")"
chown "$USERNAME:$USERNAME" "$TARGET_DIR/$(basename "$item")"
echo "✅ $(basename "$item") symlink kész"
done
fi

# === FELHASZNÁLÓI SCRIPT A SKELBE LOGGAL ===
USER_SCRIPT_PATH="$SKEL_DIR/$USER_SCRIPT_NAME"
cat > "$USER_SCRIPT_PATH" << 'EOF'
#!/usr/bin/env bash
set -e

USER_HOME="$HOME"
SOURCE_DIR="$USER_HOME/.config/rofi/scripts"
TARGET_DIR="$USER_HOME/.local/bin"
PROFILE_FILE="$USER_HOME/.bash_profile"
LOG_FILE="$HOME/.mission_impossibru.log"

echo "💫 Első bejelentkezés: Mission Impossibru user script indul..." | tee -a "$LOG_FILE"
echo "⏱ $(date)" >> "$LOG_FILE"

mkdir -p "$TARGET_DIR"

if [ -d "$SOURCE_DIR" ]; then
for item in "$SOURCE_DIR"/*; do
[ -e "$item" ] || continue
ln -sf "$item" "$TARGET_DIR/$(basename "$item")"
echo "✅ $(basename "$item") symlink létrehozva" | tee -a "$LOG_FILE"
done
else
echo "⚠  Nem található: $SOURCE_DIR" | tee -a "$LOG_FILE"
fi

# Takarítás
sed -i "/mission_user_firstlogin.sh/d" "$PROFILE_FILE" 2>/dev/null || true
rm -f "$USER_HOME/mission_user_firstlogin.sh"
echo "🧹 Mission Impossibru user script lefutott, takarítás kész." | tee -a "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
EOF

# === Root chmod, hogy az új user futtathassa ===
chmod +x "$USER_SCRIPT_PATH"
echo "✅ Felhasználói script futtatható: $USER_SCRIPT_PATH"

# === /etc/skel/.bash_profile módosítása ===
PROFILE_FILE="$SKEL_DIR/.bash_profile"
RUN_CMD='bash "$HOME/mission_user_firstlogin.sh"'

if [ -f "$PROFILE_FILE" ]; then
if ! grep -q "$USER_SCRIPT_NAME" "$PROFILE_FILE"; then
echo "$RUN_CMD" >> "$PROFILE_FILE"
echo "✅ Hozzáadva a /etc/skel/.bash_profile-hoz"
else
echo "ℹ Már benne van a bejegyzés"
fi
else
echo "$RUN_CMD" > "$PROFILE_FILE"
echo "✅ Új /etc/skel/.bash_profile létrehozva"
fi


echo ""
echo "🎉 Mission Impossibru - CLEAN SKEL EDITION w/ Logging beállítva!"
echo "   ✅ Első login script: $USER_SCRIPT_NAME"
echo "   ✅ /etc/skel készen áll"
echo "   ✅ Logolás bekapcsolva: ~/.mission_impossibru.log"



#============================================================================
# === VÉGE - MINDEN FELHASZNÁLÓ SZÁMÁRA ===
# ===========================================================================

echo ""
echo "🎉 MINDEN KÉSZ! 🎉"
echo ""
echo "✅ Összes rendszerszintű telepítés befejezve"
echo "✅ A jelenlegi felhasználó megkapta a beállításokat"
echo "✅ Az /etc/skel beállítva - új felhasználók automatikusan megkapják a konfigurációt"
echo "✅ Nordic téma beállítva mindenhol (GTK, QT, Kvantum, AwesomeWM, LightDM, XFCE)"
echo "✅ Fish shell beállítva alapértelmezettként (csak root)"
echo "✅ Fontok áthelyezve rendszerszintűvé: /usr/share/fonts/truetype/custom/"
echo "✅ Rofi szkriptek szimbolikus linkjei létrehozva"
echo "✅ Emoji font telepítve (noto-fonts-emoji)"
echo ""
echo "ℹ️  Fontos:"
echo "   - Az /etc/skel mappa MOST MÁR TELJESEN be lett állítva"
echo "   - Minden új felhasználó automatikusan megkapja a Nordic témát"
echo "   - A jelenlegi felhasználó is megkapta az összes beállítást"
echo "   - A fontok most már rendszerszintűek (/usr/share/fonts/truetype/custom/)"
echo "   - Az emojik most már megjelennek a terminálban"
echo ""
echo "Újraindíthatod a rendszert a teljes élményért:"
echo "sudo reboot"
