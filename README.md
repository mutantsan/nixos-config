# nixos-config

NixOS + Home Manager flake: Hyprland, Noctalia, Nord.

Needs [mutantsan/dotfiles](https://github.com/mutantsan/dotfiles) checked out
at `~/dotfiles`; Home Manager symlinks configs straight into it.

## Setup on a new machine

1. Install NixOS 26.05 from the graphical ISO with a user named `kiwi`.

2. Clone both repos:

   ```sh
   nix-shell -p git
   git clone https://github.com/mutantsan/nixos-config.git ~/nixos-config
   git clone https://github.com/mutantsan/dotfiles.git ~/dotfiles
   ```

3. Replace the hardware config with this machine's:

   ```sh
   cp /etc/nixos/hardware-configuration.nix \
      ~/nixos-config/modules/hosts/m90q/_hardware-configuration.nix
   ```

4. Link `/etc/nixos` to the repo:

   ```sh
   sudo mv /etc/nixos /etc/nixos.bak
   sudo ln -s ~/nixos-config /etc/nixos
   ```

5. Build:

   ```sh
   sudo nixos-rebuild switch \
     --extra-experimental-features 'nix-command flakes' \
     --flake path:/home/kiwi/nixos-config#nixos
   ```

6. Reboot.

## Machine-specific settings

Check these on different hardware:

- `_configuration.nix`: `intel-media-driver`, `systemd-boot`, `services.keyd`
- `_hypr/monitors.lua`: monitor scale

## Not managed by Nix

- SSH key for GitHub
- Language toolchains: Nix installs only the version managers, which start
  empty. Run once to download the actual toolchains:

  ```sh
  rustup default stable     # Rust
  fnm install --lts         # Node
  pyenv install <version>   # Python
  ```

## Rebuild

```sh
sudo nixos-rebuild switch --flake path:/home/kiwi/nixos-config#nixos
```
