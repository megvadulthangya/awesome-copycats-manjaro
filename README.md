# Awesome WM Nordic Copycats (Manjaro Respin Edition)

A highly customized, ready-to-use AwesomeWM configuration featuring a unified **Nord color scheme** across 10 distinct themes. 

This project is an integral part of the **Awesome Manjaro Edition** — a personal, unified system installer designed to provide a consistent, beautiful, and highly productive AwesomeWM environment.

---

## 💾 Download the ISO

To experience the full, pre-configured environment with all dependencies and system tweaks included, download the official **Awesome Manjaro ISO**.

**Get the latest ISO and updates on our Facebook page:**
👉 **[https://www.facebook.com/manjaroawesome](https://www.facebook.com/manjaroawesome)**

---

## 🚀 What's Inside?

*   **10 Nord-Themed Layouts:** Blackburn, Copland, Dremora, Holo, Multicolor, Powerarrow, Powerarrow-Dark, Rainbow, Steamburn, and Vertex.
*   **Smart Workspaces:** Tags (workspaces) and their layouts are saved per physical monitor. Your workspace setup and open windows will be restored exactly where they were, even after a reboot or monitor hot-plug.
*   **Native Dunst OSD:** Replaced standard notifications with Dunst, fully themed to match the Nord palette (volume, brightness, and system alerts).
*   **CopyQ Clipboard Manager:** Seamless clipboard history bound directly to your keyboard.
*   **Brave Browser Integration:** Session restore is configured with specific flags to ensure a smooth startup without shared memory locking issues.
*   **Modular Configuration:** Clean, well-organized directory structure (`configuration/`, `modules/`, `bin/`) for easy customization.

---

## ⌨️ Key Bindings (Custom Highlights)

The default AwesomeWM keybindings apply, with the following custom additions:

| Shortcut | Action |
| :--- | :--- |
| `Mod4 + Shift + N` | Create a new Workspace (Tag) |
| `Mod4 + Shift + R` | Rename the current Workspace |
| `Mod4 + Shift + D` | Delete the current Workspace |
| `Mod4 + Shift + V` | Toggle CopyQ Clipboard Manager |
| `Mod4 + Z` | Show previous Dunst notification (History) |
| `Mod4 + Shift + Q` | Power Menu (Logout/Reboot/Shutdown) |
| `Mod4 + Return` | Open Terminal (Tilix) |
| `Mod4 + Q` | Open Browser (Brave) |
| `Mod4 + R` | App Launcher |

---

## 🛠️ Manual Installation (For Developers)

If you want to apply this configuration to an existing Arch-based system manually, follow these steps:

1. Clone this repository:
   ```bash
   git clone https://github.com/megvadulthangya/awesome-copycats-manjaro.git
   ```

2. Copy the main configuration to the system-wide Awesome directory:
   ```bash
   sudo cp -rv awesome-copycats-manjaro/{configuration,modules,signals,themes,rc.lua} /etc/xdg/awesome/
   ```

3. Copy the utility scripts from the `bin` directory to your local executable path and make them executable:
   ```bash
   sudo cp -v awesome-copycats-manjaro/bin/*.sh /usr/local/bin/
   sudo chmod +x /usr/local/bin/brightness-osd.sh /usr/local/bin/safe-lock.sh /usr/local/bin/volume-osd.sh
   ```

4. Ensure all required system packages (terminal, browser, dunst, copyq, lua environment, etc.) are installed.

**Changing Themes:**
To switch themes, edit `/etc/xdg/awesome/rc.lua` and change the `themes` array index (1-10):
```lua
local chosen_theme = themes[7] -- 7 is powerarrow-dark
```

---

## 🎨 Theme Gallery

*(Screenshots coming soon in the ISO presentation)*

*   **Powerarrow / Powerarrow Dark** (Based on romockee)
*   **Blackburn**
*   **Dremora**
*   **Rainbow**
*   **Multicolor** (Inspired by lucamanni)
*   **Steamburn** (Based on ok100)
*   **Holo**
*   **Copland**
*   **Vertex**

---
*Based on the original work by Luca CPZ, Veratil, and the AwesomeWM community. Maintained for the Manjaro Respin by megvadulthangya.*
```
