-- configuration/autostart.lua
local awful = require("awful")
local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()

-- {{{ Autostart windowless processes
-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end

run_once({
--== Startup and Environment ==--
-- Starts the 'xss-lock' daemon. It first sets the display power management idle time (xset s).
-- The 'safe-lock.sh' script is executed when the system locks, and the xss-lock setup
-- will prevent locking while media (MPV, Grayjay, browser) is playing.
    "xset s 300 300; xss-lock -- /usr/local/bin/safe-lock.sh", -- Idle time hardcoded from logic
-- Ensures GTK appearance settings (icons/themes for Thunar, mouse cursor, fonts) 
-- are applied in the AwesomeWM session. It only starts the daemon if it's not already running.
--        "xfsettingsd",
--pamac updater desktop icon
--    "GDK_BACKEND=x11 pamac-tray",
-- Starts the LXQt PolicyKit authentication agent. This agent handles privilege requests, 
-- providing the graphical password prompt for tasks requiring system administrator permissions.
--    "lxqt-policykit-agent",
--Starts the mate Policykit authentication agent.
--    "/usr/lib/mate-polkit/polkit-mate-authentication-agent-1",
-- Starts the Legacy gnome Polkit authentication agent to handle privilege requests (e.g., password prompt for system changes).
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
-- This line would start the KDE Polkit authentication agent, an alternative to polkit-gnome-au (used above) for handling privilege escalation requests.
    --"polkit-kde-authentication-agent-1"
-- Starts the NetworkManager Applet. This is a GTK-based application that provides 
-- a graphical icon in the system tray (systray) for monitoring network status, 
-- managing connections (Wi-Fi, Wired, VPN), and configuring network settings.
--    "nm-applet",
-- This line would typically start 'picom', a standalone compositor used for managing
-- shadows, transparency, and tearing (it provides the visual effects for the desktop).
--    "picom",
-- Runs 'unclutter' to automatically hide the mouse cursor when it is not being moved
-- (i.e., when you are actively typing or not using the mouse). The '-root' flag
-- ensures it works across the entire root window.
    "unclutter -root",
-- Updates the D-Bus activation environment to include necessary systemd variables
-- like DISPLAY and WAYLAND_DISPLAY, ensuring applications started via D-Bus
-- (or systemd) can correctly display graphics.
    "dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY",

--== Wallets (Credential Management) ==--
-- Runs the pam_kwallet initialization script. This integrates KWallet with PAM (Pluggable Authentication Modules),
-- allowing KWallet to automatically unlock when the user logs in, based on the login password.
--    "/usr/lib/pam_kwallet_init",
-- Starts the KWallet D-Bus service itself. This service manages and stores sensitive user information (like passwords).
--    "kwalletd6",
-- Starts the KWallet Manager application, which is the graphical interface for managing the wallets and stored credentials.
--    "kwalletmanager6",

--== KDE Integration ==--
-- Starts the KDE Connect daemon. This service allows for integration between the desktop and mobile devices (Android/iOS),
-- providing features like notification sync, shared clipboard, and file transfer.
--    "kdeconnectd",
-- Starts the KDE Connect system tray indicator, providing a visual way to manage the connection and access its features
--    "kdeconnect-indicator",
-- Starts the Gsconnect-backround service.
    "gjs -m /usr/share/gnome-shell/extensions/gsconnect@andyholmes.github.io/service/daemon.js"
-- Starts Manjaro Hello
--    "/usr/bin/manjaro-hello",
-- Start install script
--    "/bin/bash/ -c `sleep 10 && $HOME/awesome-setup-wrapper.sh`"
 }) -- comma-separated entries

-- This function implements the XDG autostart specification

awful.spawn.with_shell(
    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
    'xrdb -merge <<< "awesome.started:true";' ..
    -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
    'dex --environment Awesome --autostart --search-paths ' ..
    '"${XDG_CONFIG_HOME:-$HOME/.config}/autostart:${XDG_CONFIG_DIRS:-/etc/xdg}/autostart";' -- https://github.com/jceb/dex
)

-- Wallpaper setup (moved from end of file)
--awful.spawn.with_shell("feh --randomize --bg-fill ~/.wallpapers/*")
--awful.spawn.with_shell("feh --randomize --bg-fill /usr/share/bac-- {{{ Key bindingskgrounds/*")
--awful.spawn.with_shell("feh --randomize --bg-fill /usr/share/wallpapers/*")
--awful.spawn.with_shell("feh --randomize --bg-fill /usr/share/backgrounds/nordic-backgrounds*")
awful.spawn.with_shell("feh --bg-fill /usr/share/backgrounds/nordic-backgrounds/ign_manjaro.jpg")
