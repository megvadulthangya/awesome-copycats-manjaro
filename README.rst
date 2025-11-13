Awesome WM Nordic Copycats
===================

-------------------------
Themes for Awesome WM 4.x
-------------------------

:Author: Luca CPZ (forked and modified by megvadulthangya)
:Version: git
:License: BY-SA_
:Source: https://github.com/megvadulthangya/awesome-copycats-manjaro

Description
===========
A forked and enhanced version of the original Awesome WM Copycats repository, featuring unified Nordic color scheme across all themes.

This repository contains themes for Awesome_ window manager 4.x that consistently follow the beautiful Nordic color palette, providing a cohesive and visually harmonious desktop experience.


Purpose
=======

The main purpose of this repository is to spread ready to use configurations, which can also serve as a cookbook for customisation.

A secondary aim is to add new themes only when they constitute different UI/UX designs.

**This fork specifically maintains the original design philosophy while applying a cohesive Nordic color palette across all themes, creating a unified visual experience for Manjaro Awesome users.**

Manjaro Awesome Integration
This theme collection is specially curated and maintained for the Manjaro Awesome edition. The Nordic color scheme provides a consistent and visually appealing desktop environment that complements the Manjaro Awesome distribution.

**🏔️ Awesome Manjaro Edition**
This theme repository is an integral part of the Awesome Manjaro Edition - a personal, unified system installer designed to create the same consistent AwesomeWM environment across all devices.

For the complete Manjaro Awesome experience, including ISO and installation details, visit:
Awesome Manjaro Edition_

Features
========

- Modularity
- Autohide widgets
- Autostart windowless processes
- Fast MPD and volume shortcuts (first time this trick has been used in Awesome)
- Shortcuts for copying to the clipboard, toggle wiboxes, widgets popups, screenshots capture, moving and magnifying clients
- Quake drop-down terminal
- Calendar with current day highlighted and months switch with a click/scroll
- Notifications for new mails, current song, volume level, hdd critical state, low battery
- OpenWeatherMap integration
- Net carrier status notifier
- Symbolic tag names
- DWM-like textual layoutbox
- Cairo wibar
- Custom layouts
- No borders when there's only one visible client
- Freedesktop.org compliant menu and desktop icons
- Vi-like client focus
- Non-empty tag browsing
- On-the-fly useless gaps resize
- Dynamic tagging
- Cohesive Nordic color scheme across all themes

Gallery
=======
Screenshots for each theme showcasing the unified Nordic color palette...

**Multicolor**, inspired by lucamanni_

.. image:: screenshots/multicolor.png

**Powerarrow**, porting of romockee_'s

.. image:: screenshots/powerarrow.png

**Powerarrow Dark**

.. image:: screenshots/powerarrow_dark.png

**Steamburn**, porting of ok100_'s dwm

.. image:: screenshots/steamburn.png

**Blackburn**

.. image:: screenshots/blackburn.png

**Dremora**

.. image:: screenshots/dremora.png

**Rainbow**

.. image:: screenshots/rainbow.png

**Holo**, requested by amouly_

.. image:: screenshots/holo.png

**Copland**, inspired by foozer_

.. image:: screenshots/copland.png

**Vertex**, requested by swordfischer_

.. image:: screenshots/vertex.png

Installation
============

.. code-block:: shell

    git clone --branch Autoinstall --recurse-submodules --remote-submodules --depth 1 -j 2 https://github.com/megvadulthangya/awesome-copycats-manjaro.git
    mkdir -p ~/.config/awesome && mv -bv awesome-copycats-manjaro/{*,.[^.]*} ~/.config/awesome &&  rm -rf awesome-copycats-manjaro

In case you do not want the Git files, use the following as the second command:

.. code-block:: shell

    mv -bv awesome-copycats-manjaro/* ~/.config/awesome; rm -rf awesome-copycats-manjaro

Usage
=====

The modular structure allows to

* set variables
* define startup processes
* change keybindings and layouts
* set client properties

in ``rc.lua``, and

* configure widgets
* define wiboxes and screen settings

in ``theme.lua``, so that you just need to change ``chosen_theme`` variable in ``rc.lua`` to preserve your preferences *and* switch the theme, instead of having file redundancy.

Just do the following:

.. code-block:: shell

    $ cd ~/.config/awesome
    $ cp rc.lua.template rc.lua

Then, set the variable ``chosen_theme`` in ``rc.lua`` to your preferred theme, do your settings, and restart Awesome (``Mod4 + ctrl + r``).

To customize a theme, head over to ``themes/$chosen_theme/theme.lua``.

Otherwise, if you want to be synced with upstream, modify the theme path in ``rc.lua`` like this:

.. code-block:: diff

    -beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))
    +beautiful.init(string.format("%s/.config/awesome/themes/%s/theme-personal.lua", os.getenv("HOME"), chosen_theme))

then, copy ``theme.lua`` to ``theme-personal.lua`` and do your customizations there.

This way, you can safely ``git pull`` anytime.

Notes
=====

Complements are provided by lain_ and freedesktop_. **Be sure** to satisfy their dependencies_. In particular, mail_ and weather_ widgets have **mandatory** arguments.

The fonts used in the screenshots are: Terminus_ (Multicolor, Powerarrow, Powerarrow Dark), Roboto_ (Holo, Vertex) and Tamzen_ (other ones).

As taglist font, Blackburn and Dremora use Icons_, Vertex uses FontAwesome_: be sure to have bitmaps enabled if running under Debian or Ubuntu_.

All themes consistently implement the Nordic color scheme, providing a unified aesthetic experience while maintaining distinct layout variations.

Additional default software used: ::

    amixer dmenu librewolf mpc mpd scrot unclutter xbacklight xsel slock

.. _BY-SA: https://creativecommons.org/licenses/by-sa/4.0
.. _Awesome: http://github.com/awesomeWM/awesome
.. _branches: https://github.com/lcpz/awesome-copycats/branches
.. _lucamanni: https://github.com/lucamanni/awesome
.. _romockee: https://github.com/romockee/powerarrow
.. _ok100: http://ok100.deviantart.com/art/DWM-January-2013-348656846
.. _amouly: https://bbs.archlinux.org/viewtopic.php?pid=1307158#p1307158
.. _swordfischer: https://github.com/lcpz/awesome-copycats/issues/53
.. _foozer: http://dotshare.it/dots/499
.. _lain: https://github.com/lcpz/lain
.. _freedesktop: https://github.com/lcpz/awesome-freedesktop
.. _Terminus: http://terminus-font.sourceforge.net
.. _Roboto: https://fonts.google.com/specimen/Roboto
.. _Tamzen: https://github.com/sunaku/tamzen-font
.. _Icons: https://github.com/lcpz/dots/tree/master/.fonts
.. _FontAwesome: https://github.com/FortAwesome/Font-Awesome
.. _Ubuntu: https://wiki.ubuntu.com/Fonts#Enabling_Bitmapped_Fonts
.. _colorscheme: https://github.com/lcpz/dots/tree/master/.colors
.. _dependencies: https://github.com/lcpz/lain/wiki#dependencies
.. _mail: https://github.com/lcpz/lain/wiki/mail
.. _weather: https://github.com/lcpz/lain/wiki/weather
.. _Awesome Manjaro Edition: https://github.com/megvadulthangya/manjaro-awesome-iso
