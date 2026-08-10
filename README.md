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
     
  - **Hyprland**: The compositor
  - **Hyprlock**: The screen lock
  - **Hyprpaper & waypaper**: The wallpapers utility
  - **pywal16**: Automatic color scheme generation from the wallpaper
  - **fastfetch**: To fetch system infos
  - **kitty**: The terminal
  - **mako**: The notification daemon
  - **pcmanfm**: The file manager
  - **waybar**: The upper bar
  - **wlogout**: To go out and touch some grass
  - **wofi**: The launcher
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
  - **[Maple Mono](https://github.com/subframe7536/maple-font)**: font used across kitty, mako, wofi and hyprlock
  - **[rose-pine-hyprcursor](https://github.com/ndom91/rose-pine-hyprcursor)**: cursor theme
  - **Adwaita GTK theme** (dark variant) and **qt6ct**: GTK/Qt theming
  - **hyprpolkitagent**: polkit authentication agent
  - **[xembedsniproxy](https://github.com/Freedye/xembedsniproxy-standalone)**: XEmbed system tray proxy (installed at `/usr/local/bin`)
  - **[hyprshutdown](https://github.com/hyprwm/contrib)** *(optional)*: nicer shutdown/logout menu, falls back to `hyprctl dispatch exit` if missing

  To use these configs, clone the repo and symlink (or copy) the folders/files you want into your `$HOME` and `~/.config`, e.g.:

  ```sh
  git clone https://github.com/Freedye/dotfiles-hyprland.git
  cd dotfiles-hyprland
  ln -s "$PWD/.config/hypr"     ~/.config/hypr
  ln -s "$PWD/.config/waybar"   ~/.config/waybar
  ln -s "$PWD/.config/kitty"    ~/.config/kitty
  ln -s "$PWD/.config/mako"     ~/.config/mako
  ln -s "$PWD/.config/wofi"     ~/.config/wofi
  ln -s "$PWD/.config/wlogout"  ~/.config/wlogout
  ln -s "$PWD/.config/waypaper" ~/.config/waypaper
  ln -s "$PWD/.config/fastfetch" ~/.config/fastfetch
  ln -s "$PWD/.zshrc"           ~/.zshrc
  ```

  Then replace the `<PATH_TO_...>` placeholders (wallpaper, profile picture, waypaper stylesheet) in `hyprpaper.conf`, `hyprlock.conf` and `waypaper/config.ini` with your own paths.
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

Licensed under the [Apache License 2.0](LICENSE).

</div>