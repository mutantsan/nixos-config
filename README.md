# nixos-config

NixOS + Home Manager flake: Hyprland, Noctalia, Nord.

Needs [mutantsan/dotfiles](https://github.com/mutantsan/dotfiles) checked out
at `~/dotfiles`; Home Manager symlinks configs straight into it.

## Setup on a new machine

1. Install NixOS 26.05 from the graphical ISO. The user name has to match
   `my.user` in the host's `_configuration.nix`.

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
     --flake path:/home/kiwi/nixos-config#m90q
   ```

6. Reboot.

## Layout

- `modules/features/`: shared NixOS modules (`base`, `desktop`, `hyprland`,
  `dev`, `gaming`, `home`), exposed as `nixosModules.<name>`.
- `modules/hosts/<name>/`: one machine. `default.nix` picks the features;
  `_configuration.nix` holds only what is specific to that machine.

## Machine-specific settings

Set these in the host's `_configuration.nix`:

- `my.user`: login name of the primary user
- `networking.hostName`
- `my.hyprland.monitorScale`
- `intel-media-driver`, `systemd-boot`, `services.keyd`
- `system.stateVersion` and the Home Manager `home.stateVersion`

## Not managed by Nix

- SSH key for GitHub
- Language toolchains: Nix installs only the version managers, which start
  empty. Run once to download the actual toolchains (uv fetches Pythons on
  demand, so it needs no step here):

  ```sh
  rustup default stable     # Rust
  fnm install --lts         # Node
  ```

## Rebuild

```sh
sudo nixos-rebuild switch --flake path:/home/kiwi/nixos-config#m90q
```
