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

    # Ellenőrizzük, hogy az AUR be van-e kapcsolva (nem #-el kezdődik a sor)
    if grep -q "^${AUR_SETTING}" "$CONFIG_FILE"; then
        echo "✅ Pamac AUR támogatás: Már engedélyezve."
    else
        # Ellenőrizzük, hogy ki van-e kommentelve
        if grep -q "^#${AUR_SETTING}" "$CONFIG_FILE"; then
            echo "⚠️ Pamac AUR támogatás: Tiltva. Engedélyezés..."
            # SED paranccsal eltávolítjuk a komment (hash) jelet a sor elejéről
            # NINCS SZÜKSÉG 'sudo'-ra, mert a script eleve rootként fut
            sed -i "/^#${AUR_SETTING}/s/^#//g" "$CONFIG_FILE"
            echo "✅ Pamac AUR támogatás: Sikeresen engedélyezve."
        else
            echo "❌ Hiba: Az '${AUR_SETTING}' beállítás formátuma nem megfelelő a(z) '${CONFIG_FILE}' fájlban."
        fi
    fi
    
    # Frissítjük a Pamac adatbázisait, hogy felismerje a változást
    # NINCS SZÜKSÉG 'sudo'-ra, mert a script eleve rootként fut
    pamac update --force-refresh
    echo "Pamac adatbázisok frissítve."

# 2. EGYÉB AUR SEGÍTŐK (Yay/Paru) ELLENŐRZÉSE
else
    echo "Pamac nem található. Egyéb AUR segítők ellenőrzése..."
    
    # Mivel a yay és a paru alapértelmezetten engedélyezi az AUR-t,
    # nincs szükség globális konfigurációs változtatásra.
    
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
  dmenu rofi flameshot picom scrot unclutter xorg-xbacklight alsa-utils mpd mpc playerctl xorg-fonts-misc ttf-roboto woff2-font-awesome arandr lxappearance lxqt-policykit xorg-xev terminus-font xss-lock wavemon network-manager-applet feh qt6ct raw-thumbnailer geany ttf-firacode-nerd fish starship bat eza jq
)

echo "Repo csomagok telepítése..."
install_repo "${REPO_PKGS[@]}"

# --- AUR csomagok ---
AUR_PKGS=(
  lain-git awesome-git awesome-freedesktop-git tilix-git tamzen-font i3lock-fancy-git grayjay-bin betterlockscreen nordic-theme nordic-darker-theme nordic-darker-standard-buttons-theme nordic-polar-standard-buttons-theme nordic-standard-buttons-theme nordic-bluish-accent-theme nordic-bluish-accent-standard-buttons-theme geany-nord-theme nordzy-icon-theme nordic-wallpapers oh-my-posh-bin fish-done find-the-command
)

echo "AUR csomagok telepítése..."
install_aur "${AUR_PKGS[@]}"

# --- Ikon font telepítése ---
echo "Ikon font telepítése $USERNAME számára..."
sudo -u "$USERNAME" mkdir -p "$USER_HOME/.local/share/fonts"
sudo -u "$USERNAME" curl -fL -o "$USER_HOME/.local/share/fonts/Icons.bdf" \
  https://raw.githubusercontent.com/lcpz/dots/refs/heads/master/.fonts/Icons.bdf
sudo -u "$USERNAME" fc-cache -fv "$USER_HOME/.local/share/fonts"

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

# Ellenőrizzük, hogy a scriptet sudo-val futtatták-e, és létezik-e a SUDO_USER
if [ -n "$SUDO_USER" ]; then
    # A HOME könyvtár meghatározása az eredeti felhasználó alapján
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)

    # A parancsokat a 'runuser' segítségével az eredeti felhasználó nevében futtatjuk
    # A '-c' kapcsoló utáni idézőjelek között van minden, amit végre akarunk hajtani
    runuser -l "$SUDO_USER" -c '
        echo "[INFO] Rofi témák letöltése a GitHubról...";
        # Egy ideiglenes könyvtárba klónozzuk, hogy ne szemeteljünk
        cd /tmp;
        # Ha már létezik a mappa, töröljük, hogy tiszta telepítés legyen
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
        # Biztonsági mentés készítése a meglévő Rofi konfigurációról
        if [[ -d "$ROFI_DIR" ]]; then
            echo "[INFO] Meglévő Rofi konfiguráció biztonsági mentése ide: ${ROFI_DIR}.bak";
            mv "$ROFI_DIR" "${ROFI_DIR}.bak";
        fi
        
        echo "[INFO] Rofi témák telepítése...";
        mkdir -p "$ROFI_DIR";
        cp -rf files/* "$ROFI_DIR";
        
        echo "[SUCCESS] Rofi témák sikeresen telepítve.";
    '
    
    # Takarítás a végén
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

# --- .xprofile létrehozása ---
sudo -u "$USERNAME" bash -c "echo '.xprofile létrehozása...' && cat <<EOF >> \"$USER_HOME/.xprofile\"
export QT_QPA_PLATFORMTHEME=\"qt6ct\"
EOF"

# --- Set flameshot to a conservative color ---
sudo -u "$USERNAME" mkdir -p "$USER_HOME/.config/flameshot"
sudo -u "$USERNAME" bash -c "echo 'Set flameshot colors...' && cat <<EOF >> \"$USER_HOME/.config/flameshot/flameshot.ini\"                                                                                                 
[General]
contrastOpacity=188
drawColor=#ff0000
uiColor=#f5eef8
EOF"


# --- AwesomeWM Copycats ---
echo "AwesomeWM Copycats konfiguráció telepítése $USERNAME számára..."
cd /tmp
sudo -u "$USERNAME" -H git clone --branch Autoinstall --recurse-submodules --remote-submodules --depth 1 -j 2 \
  https://github.com/megvadulthangya/awesome-copycats-manjaro.git

if [ -d /tmp/awesome-copycats-manjaro ]; then

 # --- Nordic-cursors téma telepítése ---
  # Ellenőrizzük, hogy létezik-e a kurzor archívum a klónozott mappában
  CURSOR_ARCHIVE="/tmp/awesome-copycats-manjaro/Nordic-cursors.tar.xz"
  if [ -f "$CURSOR_ARCHIVE" ]; then
    echo "Nordic-cursors téma telepítése..."
    # Kicsomagoljuk a /usr/share/icons mappába. A folyamat megvárja a végét.
    # A '&&' biztosítja, hogy a törlés csak sikeres kicsomagolás után fusson le.
    tar -xJf "$CURSOR_ARCHIVE" -C /usr/share/icons/ && \
    rm "$CURSOR_ARCHIVE" && \
    echo "✅ Nordic-cursors téma sikeresen telepítve és az archívum törölve."
  else
    echo "FIGYELMEZTETÉS: A Nordic-cursors.tar.xz nem található, a kurzor telepítése kihagyva."
  fi
  # --- Kurzor téma telepítésének vége ---
  
  # --- Fish konfiguráció telepítése ---
  FISH_CONFIG_ARCHIVE="/tmp/awesome-copycats-manjaro/fish.cfg.tar.xz"
  if [ -f "$FISH_CONFIG_ARCHIVE" ]; then
    echo "Fish konfiguráció telepítése..."
    FISH_CONFIG_DIR="$USER_HOME/.config/fish"
    # Létrehozzuk a mappát a felhasználó nevében, a '-p' kapcsoló miatt nem baj, ha már létezik
    sudo -u "$USERNAME" -H mkdir -p "$FISH_CONFIG_DIR" && \
    # Kicsomagoljuk a konfigurációt a felhasználó nevében a célmappába
    sudo -u "$USERNAME" -H tar -xJf "$FISH_CONFIG_ARCHIVE" -C "$FISH_CONFIG_DIR/" && \
    # Töröljük a feleslegessé vált archívumot
    rm "$FISH_CONFIG_ARCHIVE" && \
    echo "✅ Fish konfiguráció sikeresen telepítve és az archívum törölve."
  else
    echo "FIGYELMEZTETÉS: A fish.cfg.tar.xz nem található, a fish konfiguráció telepítése kihagyva."
  fi
  # --- Fish konfiguráció telepítésének vége ---
  

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
#    Ez egy megbízhatóbb módszer, mintha csak a /home/$SUDO_USER-re hagyatkoznánk
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)

# Ha valamiért nem sikerülne, kilépünk
if [ -z "$USER_HOME" ]; then
    echo "Hiba: Nem található a(z) '$SUDO_USER' felhasználó home könyvtára."
    exit 1
fi

# 2. Definiáljuk a célfájl elérési útját
#    Feltételezzük, hogy a szkript már a helyére másolta a fájlt
AWESOME_CONFIG_PATH="${USER_HOME}/.config/awesome/rc.lua"

echo "A célkonfigurációs fájl: ${AWESOME_CONFIG_PATH}"

# 3. Ellenőrizzük, hogy a fájl létezik-e, mielőtt módosítanánk
if [ -f "$AWESOME_CONFIG_PATH" ]; then
    # A sed parancs, ami a cserét elvégzi.
    # A | karaktert használjuk elválasztónak a / helyett,
    # mert az elérési út is tartalmaz /-t.
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
# Ez a script úgy van kialakítva, hogy biztonságosan futtatható legyen sudo-val,
# miközben a beállításokat a jelenlegi felhasználó xfconf profiljába menti.
# ----------------------------------------------------------------------

# 1. Célfelhasználó azonosítása
# Megpróbáljuk kitalálni, ki a felhasználó, aki a sudo-t hívta.
if [ "$EUID" -ne 0 ]; then
  echo "Hiba: A szkriptet root jogosultságokkal (sudo-val) kell futtatni."
  exit 1
fi

# A SUDO_USER változó tárolja annak a felhasználónak a nevét, aki a sudo parancsot kiadta.
TARGET_USER=${SUDO_USER}

if [ -z "$TARGET_USER" ]; then
  # Ha valamilyen oknál fogva a SUDO_USER üres, megpróbáljuk kitalálni a jelenlegi konzolfelhasználót.
  TARGET_USER=$(logname 2>/dev/null)
fi

if [ -z "$TARGET_USER" ]; then
  echo "Hiba: Nem sikerült azonosítani a célfelhasználót (SUDO_USER üres vagy logname sikertelen)."
  echo "A szkript futtatása megszakítva."
  exit 1
fi

# 2. Végrehajtó parancs (Runner) beállítása
# A beállításokat a TARGET_USER nevében kell futtatni (sudo -u $TARGET_USER).
# A DBUS_SESSION_BUS_ADDRESS beállítása szükséges ahhoz, hogy a grafikus munkamenet megkapja az értesítést.
TARGET_UID=$(id -u ${TARGET_USER})
RUNNER="sudo -u ${TARGET_USER} DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${TARGET_UID}/bus"

echo "Beállítások futtatása a következő felhasználó nevében: ${TARGET_USER} (UID: ${TARGET_UID})"
echo "---"

# 3. Xfconf beállítások elindítása (minden parancsot a RUNNER-en keresztül futtatunk)

# A '--create -t string' paraméterek biztosítják, hogy ha a beállítás még nem létezik,
# akkor a szkript hozza azt létre, mint sztring típusú értéket.

# 3.1. GTK Téma beállítása (Net/ThemeName)
echo "-> GTK Téma beállítása: Nordic"
${RUNNER} xfconf-query -c xsettings -p /Net/ThemeName -s "Nordic" --create -t string

# 3.2. Ikon Téma beállítása (Net/IconThemeName)
echo "-> Ikon Téma beállítása: Nordzy-dark"
${RUNNER} xfconf-query -c xsettings -p /Net/IconThemeName -s "Nordzy-dark" --create -t string

# 3.3. Egérmutató Téma beállítása (Gtk/CursorThemeName)
echo "-> Egérmutató Téma beállítása: Nordic-cursors"
${RUNNER} xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Nordic-cursors" --create -t string

# 3.4. Színpaletta beállítása (Gtk/ColorPalette)
# A színpaletta közvetlenül a megadott XML fájlból származik.
echo "-> Színpaletta beállítása..."
COLOR_PALETTE="black:white:gray50:red:purple:blue:light blue:green:yellow:orange:lavender:brown:goldenrod4:dodger blue:pink:light green:gray10:gray30:gray75:gray90"
${RUNNER} xfconf-query -c xsettings -p /Gtk/ColorPalette -s "${COLOR_PALETTE}" --create -t string

# 4. Befejezés és üzenet
echo "---"
echo "✅ Az Xfce Nordic téma beállításai sikeresen alkalmazva a ${TARGET_USER} felhasználónak."
echo "   A teljes változáshoz (különösen a kurzor témához) a felhasználói session újraindítása szükséges lehet."

# Ellenőrizzük, hogy a scriptet root-ként (sudo-val) futtatják-e
if [ "$EUID" -ne 0 ]; then
  echo "Kérlek futtasd ezt a scriptet sudo-val: sudo $0"
  exit 1
fi

# A felhasználó, aki a sudo-t használta
# Ha közvetlenül root-ként vagy bejelentkezve, akkor a 'root' lesz az
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

include "/home/gabi/.gtkrc-2.0.mine"
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

# Alapértelmezett shell beállítása az eredeti felhasználónak ($SUDO_USER)
if [ -n "$SUDO_USER" ]; then
    echo "Shell beállítása a(z) '$SUDO_USER' felhasználónak..."
    chsh -s "$FISH_PATH" "$SUDO_USER"
else
    echo "Figyelem: A script nem sudo-val fut, a saját felhasználódnak állítom be a shellt."
    chsh -s "$FISH_PATH" "$USER"
fi

# Alapértelmezett shell beállítása a root felhasználónak
echo "Shell beállítása a 'root' felhasználónak..."
chsh -s "$FISH_PATH" root

echo "Kész! A Fish shell sikeresen beállítva."

# --- Rendszer újraindítása ---
echo "Újraindíthatod a rendszert..."
#reboot