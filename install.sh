#!/bin/bash

# Language detection and message setup
if [[ $LANG == *"hu"* ]] || [[ $LANGUAGE == *"hu"* ]]; then
    # Hungarian messages
    MSG_TITLE="Awesome WM Konfiguráció Telepítő"
    MSG_CHECK_DEPS="Függőségek ellenőrzése..."
    MSG_INSTALL_DEPS="Függőségek telepítése..."
    MSG_ARCH_DEPS="Arch-alapú rendszer észlelve, AUR csomagok telepítése..."
    MSG_DEBIAN_DEPS="Debian-alapú vagy egyéb rendszer észlelve, manuális telepítés..."
    MSG_MANUAL_DEPS="Manuális függőségek telepítése..."
    MSG_MAIN_INSTALL="Fő konfiguráció telepítése..."
    MSG_SUCCESS="Telepítés sikeresen befejezve!"
    MSG_ERROR="Hiba történt a telepítés során."
    MSG_MISSING_GIT="A git nincs telepítve. Kérem, telepítse először."
    MSG_CONFIRM="Folytatja a telepítést? (i/n)"
    MSG_CANCELLED="Telepítés megszakítva."
    MSG_RC_EXISTS="Már létezik egy rc.lua fájl a konfigurációs könyvtárban."
    MSG_RC_CHOICE="Mit szeretne tenni a meglévő rc.lua fájllal?"
    MSG_RC_OPTION1="1 - Biztonsági másolat készítése (rc.lua -> rc.lua.backup) és új rc.lua létrehozása"
    MSG_RC_OPTION2="2 - Megtartom a meglévőt (FIGYELMEZTETÉS: a konfiguráció nem fog betöltődni amíg át nem nevezi rc.lua-ra!)"
    MSG_RC_OPTION3="3 - Felülírom a meglévő rc.lua-t az új sablonnal"
    MSG_RC_PROMPT="Válasszon egy lehetőséget [1-3] (alapértelmezett: 1): "
    MSG_RC_INVALID="Érvénytelen válasz. Kérem, válasszon 1, 2 vagy 3 közül."
    MSG_RC_BACKUP="Biztonsági másolat készült: rc.lua -> rc.lua.backup"
    MSG_RC_WARNING="FIGYELMEZTETÉS: A konfiguráció nem fog betöltődni amíg át nem nevezi az rc.lua.template fájlt rc.lua-ra!"
    MSG_RC_OVERWRITTEN="rc.lua felülírva az új sablonnal"
    MSG_NO_TEMPLATE="Hiba: rc.lua.template fájl nem található!"
else
    # English messages
    MSG_TITLE="Awesome WM Configuration Installer"
    MSG_CHECK_DEPS="Checking dependencies..."
    MSG_INSTALL_DEPS="Installing dependencies..."
    MSG_ARCH_DEPS="Arch-based system detected, installing AUR packages..."
    MSG_DEBIAN_DEPS="Debian-based or other system detected, manual installation..."
    MSG_MANUAL_DEPS="Installing dependencies manually..."
    MSG_MAIN_INSTALL="Installing main configuration..."
    MSG_SUCCESS="Installation completed successfully!"
    MSG_ERROR="An error occurred during installation."
    MSG_MISSING_GIT="Git is not installed. Please install it first."
    MSG_CONFIRM="Continue with installation? (y/n)"
    MSG_CANCELLED="Installation cancelled."
    MSG_RC_EXISTS="An rc.lua file already exists in the config directory."
    MSG_RC_CHOICE="What would you like to do with the existing rc.lua file?"
    MSG_RC_OPTION1="1 - Create backup (rc.lua -> rc.lua.backup) and create new rc.lua"
    MSG_RC_OPTION2="2 - Keep existing (WARNING: configuration won't load until you rename rc.lua.template to rc.lua!)"
    MSG_RC_OPTION3="3 - Overwrite existing rc.lua with new template"
    MSG_RC_PROMPT="Choose an option [1-3] (default: 1): "
    MSG_RC_INVALID="Invalid choice. Please enter 1, 2, or 3."
    MSG_RC_BACKUP="Backup created: rc.lua -> rc.lua.backup"
    MSG_RC_WARNING="WARNING: Configuration won't load until you rename rc.lua.template to rc.lua!"
    MSG_RC_OVERWRITTEN="rc.lua overwritten with new template"
    MSG_NO_TEMPLATE="Error: rc.lua.template file not found!"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install dependencies based on distribution
install_dependencies() {
    print_message $BLUE "$MSG_INSTALL_DEPS"
    
    if command_exists pacman; then
        # Arch-based distributions
        print_message $YELLOW "$MSG_ARCH_DEPS"
        
        # Check for AUR helpers
        if command_exists yay; then
            yay -S awesome-freedesktop-git lain-git --needed --noconfirm
        elif command_exists paru; then
            paru -S awesome-freedesktop-git lain-git --needed --noconfirm
        elif command_exists pamac; then
            pamac install awesome-freedesktop-git lain-git --no-confirm
        else
            print_message $YELLOW "No AUR helper found. Please install yay, paru, or pamac first."
            return 1
        fi
        
    else
        # Debian-based and other distributions
        print_message $YELLOW "$MSG_DEBIAN_DEPS"
        install_manual_dependencies
    fi
}

# Function for manual dependency installation
install_manual_dependencies() {
    print_message $BLUE "$MSG_MANUAL_DEPS"
    
    # Create awesome config directory if it doesn't exist
    mkdir -p ~/.config/awesome
    
    # Install awesome-freedesktop
    if [ -e ~/.config/awesome/freedesktop ]; then
        rm -rf ~/.config/awesome/freedesktop
    fi
    git clone https://github.com/lcpz/awesome-freedesktop.git ~/.config/awesome/freedesktop
    
    # Install lain
    if [ -e ~/.config/awesome/lain ]; then
        rm -rf ~/.config/awesome/lain
    fi
    git clone https://github.com/lcpz/lain.git ~/.config/awesome/lain
    
    # Try LuaRocks installation as alternative/fallback
    if command_exists luarocks; then
        luarocks install lcpz/awesome-freedesktop || true
    fi
}

# Function to install main configuration
install_main_config() {
    print_message $BLUE "$MSG_MAIN_INSTALL"
    
    # Clone the repository
    git clone --branch nord --recurse-submodules --remote-submodules --depth 1 -j 2 \
        https://github.com/megvadulthangya/awesome-copycats-manjaro.git
    
    # Create config directory and move files
    mkdir -p ~/.config/awesome
    
    # Move files (two methods as in original instructions)
    if mv -bv awesome-copycats-manjaro/{*,.[^.]*} ~/.config/awesome 2>/dev/null; then
        rm -rf awesome-copycats-manjaro
    else
        # Alternative method if the first fails
        shopt -s dotglob
        mv -bv awesome-copycats-manjaro/* ~/.config/awesome
        rm -rf awesome-copycats-manjaro
        shopt -u dotglob
    fi
}

# Function to handle rc.lua creation
handle_rc_lua() {
    local awesome_dir="$HOME/.config/awesome"
    
    # Check if template exists
    if [ ! -f "$awesome_dir/rc.lua.template" ]; then
        print_message $RED "$MSG_NO_TEMPLATE"
        return 1
    fi
    
    # If rc.lua doesn't exist, simply create it from template
    if [ ! -f "$awesome_dir/rc.lua" ]; then
        cp "$awesome_dir/rc.lua.template" "$awesome_dir/rc.lua"
        print_message $GREEN "rc.lua created from template"
        return 0
    fi
    
    # rc.lua exists - ask user what to do
    print_message $YELLOW "$MSG_RC_EXISTS"
    echo "$MSG_RC_CHOICE"
    echo "$MSG_RC_OPTION1"
    echo "$MSG_RC_OPTION2"
    echo "$MSG_RC_OPTION3"
    
    while true; do
        echo -n "$MSG_RC_PROMPT"
        read -r choice
        choice=${choice:-1}  # Default to 1 if empty
        
        case $choice in
            1)
                # Create backup and new rc.lua
                mv "$awesome_dir/rc.lua" "$awesome_dir/rc.lua.backup"
                cp "$awesome_dir/rc.lua.template" "$awesome_dir/rc.lua"
                print_message $GREEN "$MSG_RC_BACKUP"
                print_message $GREEN "New rc.lua created from template"
                break
                ;;
            2)
                # Keep existing rc.lua, but warn user
                print_message $YELLOW "$MSG_RC_WARNING"
                break
                ;;
            3)
                # Overwrite existing rc.lua
                cp "$awesome_dir/rc.lua.template" "$awesome_dir/rc.lua"
                print_message $YELLOW "$MSG_RC_OVERWRITTEN"
                break
                ;;
            *)
                print_message $RED "$MSG_RC_INVALID"
                ;;
        esac
    done
}

# Main installation function
main() {
    clear
    print_message $GREEN "=== $MSG_TITLE ==="
    
    # Check if git is installed
    if ! command_exists git; then
        print_message $RED "$MSG_MISSING_GIT"
        exit 1
    fi
    
    # Confirmation
    print_message $YELLOW "$MSG_CONFIRM"
    read -r response
    case $response in
        [yY]|[yY][eE][sS]|i|I|[iI][gG][eE][nN])
            # Continue
            ;;
        *)
            print_message $YELLOW "$MSG_CANCELLED"
            exit 0
            ;;
    esac
    
    # Check dependencies
    print_message $BLUE "$MSG_CHECK_DEPS"
    
    # Install dependencies
    if ! install_dependencies; then
        print_message $YELLOW "Dependency installation had issues, but continuing with main installation..."
    fi
    
    # Install main configuration
    if install_main_config; then
        # Handle rc.lua creation
        handle_rc_lua
        
        print_message $GREEN "$MSG_SUCCESS"
        print_message $GREEN "Awesome WM configuration has been installed to ~/.config/awesome"
        
        # Additional reminder if user chose option 2
        if [[ $choice == "2" ]]; then
            echo
            print_message $YELLOW "=========================================================="
            print_message $YELLOW "FIGYELMEZTETÉS: A konfiguráció nem fog betöltődni!"
            print_message $YELLOW "A következő parancsot kell futtatnia a konfiguráció betöltéséhez:"
            print_message $YELLOW "cd ~/.config/awesome && cp rc.lua.template rc.lua"
            print_message $YELLOW "=========================================================="
        fi
    else
        print_message $RED "$MSG_ERROR"
        exit 1
    fi
}

# Error handling
set -e

# Run main function
main "$@"