# dotfiles

![rice](./.assets/2023-04-11_rice.png)

| programs      | using            |
| ------------- | ---------------- |
| wm            | i3               |
| os            | debian 11        |
| terminal      | kitty            |
| shell         | zsh + p10k       |
| compositor    | picom            |
| launcher      | rofi             |
| screen locker | betterlockscreen |
| status bar    | i3status         |

## Setup

For Debian based systems, on a fresh install, choose no desktop environment and standard system utilities.

```sh
[ ] Debian desktop environment
[ ] ... GNOME
[ ] ... Xfce
...
[ ] SSH server
[*] standard system utilities
```

Install xorg and i3 (See [installing Xorg](https://wiki.debian.org/Xorg#Installing_Xorg))

```sh
sudo apt install xorg i3 -y
```

Now `x-session-manager` should be linked to `i3`, but just to be sure, run:

```sh
# See https://wiki.debian.org/Xsession#Configuration
echo "exec i3" > ~/.xsession
```

Before starting the X server, install some dependencies:

```sh
sudo apt install sakura rofi picom dunst alsa-utils pulseaudio feh xclip
libnotify-bin gnome-keyring gparted fonts-font-awesome devscripts pqiv bc
curl adwaita-qt flameshot wget mate-polkit-bin fonts-noto-color-emoji
```

And choose a web browser.

```sh
# Firefox
sudo apt install firefox-esr
# Chromium
sudo apt install chromium
# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
-O /tmp/chrome.deb
sudo apt install /tmp/chrome.deb
# etc
```

Then install the dotfiles (see the [setup script](https://github.com/paoloose/dotfiles/blob/main/.scripts/setup.sh))

```sh
curl -s https://raw.githubusercontent.com/paoloose/dotfiles/main/.scripts/setup.sh | bash
```

Start the X session with `startx` and you should be good to go.

Setup the kitty terminal

```sh
# Not sure why but the binary in the installer was faster on startup time than
# the distributed package for debian (can't confirm this)
# see https://sw.kovidgoyal.net/kitty/binary/#binary-install
# sudo apt install kitty

# see https://github.com/kovidgoyal/kitty/issues/1613
sudo apt install kitty-terminfo
```

Thinks you might want to configure:

- A session manager, I recommend [lightdm](https://wiki.debian.org/LightDM).
- A file manager like [thunar](https://wiki.debian.org/Thunar).
- A network manager like [nm-applet](https://wiki.debian.org/NetworkManager).
- The bluetooth, see [this](https://wiki.debian.org/BluetoothUser).
- Your mouse sensitivity, see [this](https://askubuntu.com/a/1051759).
- Your keyboard layout:

  ```sh
  localectl list-x11-keymap-layouts # to see available layouts
  localectl list-x11-keymap-variants <layout> # available variants
  localectl set-x11-keymap <layout>
  localectl set-x11-keymap <layout> <variant>
  ```
- A lock screen, I use [betterlockscreen](https://github.com/betterlockscreen/betterlockscreen#installation)
  as a *better* replacement for i3lock.

- The recommended packages (firmware) for your hardware.

  - For nvidia, see [Nvidia Drivers for Debian](https://wiki.debian.org/NvidiaGraphicsDrivers).
  - For other such as AMD see [Debian graphics card](https://wiki.debian.org/GraphicsCard).

## How to create your own dotfiles repo

Small guide here. See [this](https://news.ycombinator.com/item?id=11070797) for more info.

```bash
# In your home directory

# Create your dotfiles repo as a bare repo

mkdir .dotfiles
git init --bare ./.dotfiles

# Create an alias for working on it

alias dotfiles='/usr/bin/git --work-tree=$HOME --git-dir=$HOME/.dotfiles'

# or make a global alias
echo alias dotfiles='/usr/bin/git --work-tree=$HOME --git-dir=$HOME/.dotfiles' >> ~/.zshrc # or ~/.bashrc

# Use the alias whenever you want to interact with your new repo
dotfiles config --local status.showUntrackedFiles no
dotfiles branch -M main

# Link the repo to a remote git repository
dotfiles remote add origin <repo-url>
```

Usage

```bash
# In your home directory
dotfiles add .somefile
dotfiles status
dotfiles commit -m 'add .somefile'
dotfiles push origin main
```

## Inspiration

Awesome repos that I've used as inspiration:

- <https://github.com/addy-dclxvi/i3-starterpack>
- <https://github.com/adi1090x/rofi>
