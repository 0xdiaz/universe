<div align="center">
    <h1>Diaz's Universe ❄️</h1>
    <br>
    <div align="center">
        <a href="https://nixos.org">
            <img src="https://img.shields.io/badge/NixOS-Unstable-blue?style=for-the-badge&logo=NixOS&logoColor=white&label=Nixpkgs&labelColor=303446&color=6CB6EB">
        </a>
        <a href="https://github.com/0xdiaz/universe/blob/main/LICENSE">
            <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&colorA=313244&colorB=EF9F76&logo=unlicense&logoColor=EF9F76&"/>
        </a>
    </div>
    <br>
</div>

This is my personal system configuration using [Nix](https://nixos.org/) with
[**flakes**](https://nixos.wiki/wiki/Flakes), [**flake-parts**](https://flake.parts/),
[**home-manager**](https://github.com/nix-community/home-manager), and
[**nix-darwin**](https://github.com/LnL7/nix-darwin) for macOS.

Forked from [r17x/universe](https://github.com/r17x/universe) — see
[Acknowledgement](#acknowledgement) below.

## What's inside

- Declarative macOS system config (nix-darwin) and user environment (home-manager)
- Custom development shells for OCaml, Rust, Node.js, Bun, Go, and more
- AI-enhanced Neovim configuration (nixvim)
- Custom overlays and packages

## Structure

```
flake.nix                          # Entry point — uses flake-parts + ez-configs
nix/
  default.nix                      # Main flake module imports and configuration
  devShells.nix                    # Development environments (Node, Go, OCaml, Rust, Bun)
  nvim.nix/                        # Neovim configuration (nixvim)
  colors.nix / icons.nix           # Shared color scheme and icon definitions
  configurations/
    darwin/diaz.nix                # macOS host config (aarch64-darwin)
    home/diaz.nix                  # Home-manager config
  modules/
    cross/                         # Platform-agnostic (nix settings, Fish shell)
    darwin/                        # macOS modules (system, homebrew, network, GPG, etc.)
    home/                          # User modules (git, shells, terminal, tmux, packages, etc.)
    flake/                         # Flake-level (universe CLI, rebuild scripts, pkgs-by-name)
  overlays/                        # Custom overlays (OCaml packages, Node packages, macOS apps, vim)
  packages/                        # Custom per-system packages (discovered via pkgs-by-name)
```

## Usage

### Install Nix

```console
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### Rebuild

```console
sudo darwin-rebuild switch --flake .#diaz
```

### Development environment

```console
nix develop github:0xdiaz/universe#<DEVELOPMENT_ENVIRONMENT_NAME>
```

> [!NOTE]
> `DEVELOPMENT_ENVIRONMENT_NAME` is only available from the [devShells definitions](./nix/devShells.nix)

#### with `direnv`

```console
echo "use flake github:0xdiaz/universe#<DEVELOPMENT_ENVIRONMENT_NAME>" > .envrc
direnv allow
```

## `Alias` command list

* `drb` - darwin rebuild — build this config.
* `drs` - darwin rebuild and switch to the built version.
* `lenv` - list build versions, useful for switching/rollback.
* `senv <VERSION>` - switch to a specific version.

## Resources

* [home-manager-options](https://home-manager-options.extranix.com/?query=&release=master)

## Acknowledgement

* [**r17x/universe**](https://github.com/r17x/universe) — the repo this is forked from.
* [**malob/nixpkgs**](https://github.com/malob/nixpkgs) ~ [malob](https://github.com/malob) Nix system configs.
* [**srid/nixos-flake**](https://github.com/srid/nixos-flake) ~ for flake-parts inspiration.
