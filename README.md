<div align="center">
    <h1>Freedye's Hyprland dotfiles</h1>
    <h3></h3>
</div>

<div align="center"> 

![](https://img.shields.io/github/last-commit/Freedye/dotfiles-hyprland?&style=for-the-badge&color=8ad7eb&logo=git&logoColor=D9E0EE&labelColor=1E202B)
![](https://img.shields.io/github/stars/Freedye/dotfiles-hyprland?style=for-the-badge&logo=andela&color=86dbd7&logoColor=D9E0EE&labelColor=1E202B)
![](https://img.shields.io/github/repo-size/Freedye/dotfiles-hyprland?color=86dbce&label=SIZE&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B)

</div>

<div align="center">
    <h2>• Software overview •</h2>
    <h3></h3>
</div>

 <details> 
  <summary>Programs used</summary>
     
  - **Hyprland**: The compositor, started directly by the login manager (no uwsm)
  - **greetd**: The login manager, with a lain-themed greeter written in quickshell
  - **Hyprpaper**: The wallpapers utility
  - **pywal16**: Automatic color scheme generation from the wallpaper
  - **fastfetch**: To fetch system infos
  - **kitty**: The terminal
  - **pcmanfm**: The file manager
  - **quickshell**: The whole shell: upper bar (window title, clock and calendar, media and audio, hardware stats and device batteries, Bluetooth, notifications), tray, power menu, app launcher, notification popups, polkit prompt and screen lock
  - **grim & slurp**: The screenshoot utility
  - **wl-copy**: The clipboard utility
</details>

<div align="center">
    <h2>• screenshots •</h2>
    <h3></h3>
</div>

| Base view | Some programs |
|:---|:---------------|
| <img width="1920" height="1080" alt="image" src="https://raw.githubusercontent.com/Freedye/dotfiles-hyprland/refs/heads/master/assets/20251210-022222.png" /> | <img width="1920" height="1080" alt="image" src="https://raw.githubusercontent.com/Freedye/dotfiles-hyprland/refs/heads/master/assets/20251211-174001.png" /> |
| Wallpaper change | Automatic color switch with pywal16 |
| <img width="1920" height="1080" alt="image" src="https://raw.githubusercontent.com/Freedye/dotfiles-hyprland/refs/heads/master/assets/20251210-024358.png" /> | <img width="1920" height="1080" alt="image" src="https://raw.githubusercontent.com/Freedye/dotfiles-hyprland/refs/heads/master/assets/20251210-022314.png" /> |

<div align="center">
    <h2>• installation •</h2>
    <h3></h3>
</div>

 <details>
  <summary>Dependencies & setup</summary>

  Besides the [programs listed above](#software-overview), these dotfiles also expect:
  - **[Maple Mono](https://github.com/subframe7536/maple-font)**: font used across kitty and quickshell
  - **[JetBrainsMono Nerd Font](https://www.nerdfonts.com/)**: icon font of the bar and the screen lock
  - **ArcadeClassic**: font of the login and lock screens, installed system-wide (e.g. in `/usr/share/fonts`)
  - **[rose-pine-hyprcursor](https://github.com/ndom91/rose-pine-hyprcursor)**: cursor theme
  - **wal-flat**: flat GTK theme that follows the live pywal16 palette, for GTK3 and GTK4 apps (included under `.themes/wal-flat`). libadwaita apps ignore GTK themes, so `.config/gtk-4.0/gtk.css` applies the same palette through their named colors
  - **[Tela](https://github.com/vinceliuice/Tela-icon-theme)**: GTK icon theme, also used by the launcher (it follows whatever `gsettings` icon theme is set)
  - **OpenRGB**: started minimized from `autostart.lua`, remove that line if you don't use it
  - **[xembedsniproxy](https://github.com/Freedye/xembedsniproxy-standalone)**: XEmbed system tray proxy (installed at `/usr/local/bin`)

  To use these configs, clone the repo and symlink (or copy) the folders/files you want into your `$HOME` and `~/.config`, e.g.:

  ```sh
  git clone https://github.com/Freedye/dotfiles-hyprland.git
  cd dotfiles-hyprland
  ln -s "$PWD/.config/hypr"       ~/.config/hypr
  ln -s "$PWD/.config/quickshell" ~/.config/quickshell
  ln -s "$PWD/.config/kitty"      ~/.config/kitty
  ln -s "$PWD/.config/fastfetch"  ~/.config/fastfetch
  ln -s "$PWD/.themes/wal-flat"   ~/.themes/wal-flat
  ln -s "$PWD/.zshrc"             ~/.zshrc
  ln -s "$PWD/.gtkrc-2.0"         ~/.gtkrc-2.0

  # single files, so the other contents of these folders are left alone
  mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
  ln -s "$PWD/.config/gtk-3.0/settings.ini"        ~/.config/gtk-3.0/settings.ini
  ln -s "$PWD/.config/gtk-4.0/settings.ini"        ~/.config/gtk-4.0/settings.ini
  ln -s "$PWD/.config/gtk-4.0/gtk.css"             ~/.config/gtk-4.0/gtk.css

  # GTK3 apps read the theme from gsettings first
  gsettings set org.gnome.desktop.interface gtk-theme wal-flat
  ```

  Then, before linking:
  - replace the `<PATH_TO_...>` placeholders (wallpaper) in `hyprpaper.conf` with your own paths;
  - replace `/home/user` with your home directory in the files that contain it (GTK CSS cannot expand `~` or `$HOME`): `grep -rl /home/user --exclude-dir=.git --exclude=README.md . | xargs sed -i "s|/home/user|$HOME|g"`.

  Hyprland reads the pywal16 colors when it loads its config, so after changing the wallpaper run `hyprctl reload`; quickshell follows `~/.cache/wal/colors.json` live.
</details>

 <details>
  <summary>Shell (quickshell)</summary>

  Everything runs in the bar's `qs` process except the screen lock, which is a separate config started on demand, so a crash of the bar can't take it down.

  - **Launcher** (`Launcher.qml`), `SUPER+SPACE`: type to search, `Up`/`Down` or `Tab` to move, `Enter` to launch, `Esc` to close. It takes app icons from the GTK icon theme (`scripts/launcher-index.sh`), while the bar keeps `QS_ICON_THEME` for the tray.
  - **Notifications** (`Notifs.qml`, `NotifPopups.qml`, `NotifCard.qml`, `NotifCenter.qml`): popups in the top-right corner (low 5s, normal 10s, critical until closed, paused on hover; left click runs the default action, right click dismisses). The bell in the bar opens the history (left click) and toggles do-not-disturb (right click).
  - **Bluetooth** (`BluetoothIsland.qml`): left click opens the device list (connect, disconnect, pair, forget, scan), right click turns the adapter on or off. There is no pairing agent: pair devices that ask for a PIN with `bluetoothctl`.
  - **Polkit** (`PolkitAuth.qml`, `PolkitDialog.qml`): password prompt for admin actions, on the focused screen.
  - **Screen lock** (`lock/`), `SUPER+L` or the power menu: same look as the login screen, with the same user picture (`/var/lib/AccountsService/icons/<user>`, see the login screen install), password field on `DP-1` (`LAIN_PRIMARY`), the other screens stay black. It uses the `login` PAM service. `misc.allow_session_lock_restore` is on, so if it ever crashes you can switch to a TTY and start it again with `hyprctl --instance 0 dispatch 'hl.dsp.exec_cmd("qs -n -p ~/.config/quickshell/lock/shell.qml")'`. Preview it without locking (password `lain`, `Esc` quits): `LAIN_LOCK_PREVIEW=1 qs -p ~/.config/quickshell/lock/shell.qml`.

  IPC, e.g. for keybinds: `qs ipc call launcher toggle`, `qs ipc call notifications clear|toggleDnd|count`, `qs ipc call bluetooth toggle|power`.
</details>

 <details>
  <summary>Login screen (greetd)</summary>

  The login screen is a quickshell greeter (`etc/greetd/lain-greeter`) running inside a minimal Hyprland instance (`etc/greetd/hyprland.lua`), started by greetd. greetd does the actual authentication (PAM) as root and starts the session; the greeter runs as the unprivileged `greeter` user and only draws the screen and forwards the password.

  - The form is shown only on `DP-1` and `DP-2` is turned off until the session starts: change the `hl.monitor` lines and `LAIN_PRIMARY` in `etc/greetd/hyprland.lua` to match your monitors.
  - The last user and session are remembered in `/var/lib/lain-greeter`.
  - The selected user's picture is read from `/var/lib/AccountsService/icons/<user>` (the `greeter` user can't read home directories); without it, no picture is shown.
  - The output of the greeter and of the session launcher goes to the journal instead of the screen.
  - No autologin: the password is always asked before anything of the session starts.
  - The ArcadeClassic font must be installed system-wide (e.g. in `/usr/share/fonts`), since the `greeter` user can't see your user fonts.

  Install (files are copied, not linked, since the `greeter` user can't read your home):

  ```sh
  sudo pacman -S --needed greetd quickshell
  sudo install -d -m 755 /etc/greetd/lain-greeter/{Components,Assets,Backgrounds}
  sudo install -m 644 etc/greetd/lain-greeter/{shell.qml,Greeter.qml,LICENSE} /etc/greetd/lain-greeter/
  sudo install -m 644 etc/greetd/lain-greeter/Components/*.qml /etc/greetd/lain-greeter/Components/
  sudo install -m 644 etc/greetd/lain-greeter/Assets/*.svg /etc/greetd/lain-greeter/Assets/
  sudo install -m 644 etc/greetd/lain-greeter/Backgrounds/lain.jpg /etc/greetd/lain-greeter/Backgrounds/
  sudo install -m 644 etc/greetd/{config.toml,config-agreety.toml,hyprland.lua} /etc/greetd/
  sudo install -d -m 700 -o greeter -g greeter /var/lib/lain-greeter
  sudo install -D -m 644 .config/hypr/img/profile.webp /var/lib/AccountsService/icons/$USER   # your picture
  sudo systemctl enable greetd   # disable your current display manager first
  ```

  Preview it without logging out (any password but `lain` fails, `Esc` quits): `LAIN_PRIMARY=DP-1 quickshell -p etc/greetd/lain-greeter/shell.qml`.

  If the greeter breaks, switch to another TTY (`Ctrl+Alt+F2`), log in and fall back to the plain-text greeter:

  ```sh
  sudo cp /etc/greetd/config-agreety.toml /etc/greetd/config.toml
  sudo systemctl restart greetd
  ```

  Logs: `journalctl -b -u greetd`, `journalctl -b -t lain-greeter` (greeter), `journalctl -b -t hyprland-session` (session launcher).
</details>

<div align="center">
    <h2>• inspirations •</h2>
    <h3></h3>
</div>

 <details> 
  <summary>Click me</summary>
     
  - **Windows**: Some keybinds are the same for an easy switch.
  - **MacOS**: I tried to make it as simple as possibile, work is still needed but it's something.
  - **[@diinki](https://github.com/diinki)**: Without their video I wouldn’t have even started.
  - **[@BreadOnPenguins](https://github.com/BreadOnPenguins)**: Her channel and her tips helped me to stay focused while I was learning new stuff.
</details>

<div align="center">
    <h2>• license •</h2>
    <h3></h3>
</div>

<div align="center">

Licensed under the [Apache License 2.0](LICENSE), except `etc/greetd/lain-greeter`, which is derived from [Keyitdev](https://github.com/Keyitdev)'s astronaut theme and is licensed under the [GPLv3+](etc/greetd/lain-greeter/LICENSE).

</div>