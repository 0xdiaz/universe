# Diaz's Universe

Declarative system configuration for macOS (nix-darwin) and home-manager via Nix flakes.
Forked from [r17x/universe](https://github.com/r17x/universe).

## Quick Reference

- **Rebuild macOS**: `universe rebuild` or `sudo darwin-rebuild switch --flake .`
- **Format code**: `nix fmt` (uses `nixfmt-rfc-style`)
- **Check pre-commit**: `nix flake check` (runs deadnix, nixfmt-rfc-style, stylua, shellcheck, actionlint)
- **Dev shell**: `nix develop` (default shell with pre-commit hooks)
- **Manage services**: `universe service`

## Repository Structure

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
    cross/                         # Platform-agnostic (nix settings, nixpkgs config, Fish shell)
    darwin/                        # macOS modules (system, homebrew, network, GPG, etc.)
    home/                          # User modules (git, shells, terminal, tmux, packages, etc.)
    flake/                         # Flake-level (universe CLI, rebuild scripts, pkgs-by-name)
  overlays/                        # Custom overlays (OCaml packages, Node packages, macOS apps, vim)
  packages/                        # Custom per-system packages (discovered via pkgs-by-name)
```

## Architecture

- **flake-parts** composes the flake modularly via `nix/default.nix`
- **ez-configs** auto-discovers configurations and modules from directory conventions
- Global args (`self`, `inputs`, `icons`, `colors`, `color`, `crossModules`) flow to all modules
- Three nixpkgs channels available as `pkgs.branches.{stable, master, unstable}`
- Overlays are applied globally via `inputs.self.nixpkgs.overlays`

## Darwin Hosts

| Host | Description |
|------|-------------|
| `diaz` | Fish shell, homebrew, fonts, GPG (no aerospace/mouseless WM) |

## Nix Conventions

- Formatter: `nixfmt-rfc-style` (enforced by pre-commit)
- Dead code: checked by `deadnix` (excludes `nix/overlays/nodePackages/node2nix`)
- Module options use `lib.mkEnableOption` / `lib.mkOption` patterns
- Custom vim plugins use `vimPlugins_` prefix in flake inputs
- nixpkgs follows `nixpkgs-unstable`

## Secrets

No secrets/SOPS/GPG identity management is set up on this host yet — the shared
`sops-nix`-dependent activation scripts from upstream were removed for this host.
See `nix/configurations/home/diaz.nix` for what was stripped and why.

## Key Commands

```sh
# Development shells
nix develop .#ocaml          # OCaml 5.1
nix develop .#rust-wasm      # Rust + WASM
nix develop .#nodejs22       # Node.js 22
nix develop .#bun            # Bun runtime
nix develop .#go             # Go

# Process compose services
nix run .#ai                 # Ollama with deepseek-r1:1.5b
nix run .#mysql              # MariaDB instances on ports 3307-3309

# Universe CLI
universe rebuild             # darwin-rebuild switch
universe service             # Manage launchd/systemd services
```
