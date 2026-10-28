{
  color,
  lib,
  pkgs,
  ...
}:

let
  supportDir = "Library/Application Support/Tern";
  base = color.scheme;

  # Tern rewrites settings.json itself (its Settings page, window sizes), so it
  # can't be a read-only symlink: activation deep-merges these keys into it.
  # They win over changes made in Tern; keybinds are replaced whole, so a
  # binding dropped here is dropped there too.
  settings = {
    theme = "Dark";
    theme_dark = "dark-universe";
    theme_light = "dark-universe";
    font_family = "Kode Mono";
    ui_font_size = 13;
    cursor = {
      shape = "underline";
      programs = true;
    };
    material = "Solid";
    snap_text = true;
    status_bar = true;
    copy_on_select = true;
    link_target = "Browser";
    start_folder = "~/dev";
    global_hotkey = "ctrl+alt+space";

    # Plain fish with starship, as in Ghostty
    shell = "fish";
    native_prompt = false;
    native_completion = false;
    command_lenses = false;

    # `claude` opens as Tern's ACP chat; its TUI runs in Ghostty
    agent_command = "tern acp claude";
    agents = {
      auto_acp = true;
      keep_tui = [ ];
      own_tools = [ "claude" ];
    };

    # Keep the gh token and .env files off Stencil's cloud machines
    cloud = {
      github = false;
      include = [ ];
    };

    # Tern's tmux preset on zellij's Ctrl a prefix, plus zellij's Alt keys
    keymap = "tmux";
    keymap_prefix = "ctrl+a";
    keybinds = {
      "alt+h" = [
        "focus_pane:left"
        "previous_tab"
      ];
      "alt+l" = [
        "focus_pane:right"
        "next_tab"
      ];
      "alt+j" = "focus_pane:down";
      "alt+k" = "focus_pane:up";
      "alt+n" = "split_right";
      "alt+i" = "move_tab_left";
      "alt+o" = "move_tab_right";
      "alt+f" = "pip";
      "ctrl+a>h" = "focus_pane:left";
      "ctrl+a>j" = "focus_pane:down";
      "ctrl+a>k" = "focus_pane:up";
      "ctrl+a>l" = "focus_pane:right";
      "ctrl+a>[" = "scroll_page_up";
      "ctrl+a>]" = "open_scrollback";
      "ctrl+a>t" = "focus_tabs";
      "ctrl+a>?" = "palette";
      # Left to Claude Code's external editor
      "ctrl+g" = [ ];
    };
  };

  settingsFile = pkgs.writeText "tern-settings.json" (builtins.toJSON settings);
  emptySettings = pkgs.writeText "tern-settings-empty.json" "{}";

  # Colors from the same scheme as Ghostty (base00..base0F are ANSI 0..15);
  # dark-universe.json holds the rest, UI surfaces shifted off the background
  theme = lib.recursiveUpdate (lib.importJSON ./dark-universe.json) {
    name = "dark-universe";
    vars = {
      crater = base.base08;
      moonlight = base.base07;
      glow = base.base06;
      ice = base.base04;
      success = base.base02;
      error = base.base01;
      warning = base.base03;
    };
    colors = {
      selectedBg = base.base08;
      statusLineBg = base.base00;
      statusLineSep = base.base08;
      thinkingXhigh = base.base0F;
      pythonMode = base.base0B;
    };
    terminal = {
      background = base.base00;
      foreground = base.base07;
      chrome = base.base00;
      ansi = lib.genList (i: base."base0${lib.toHexString i}") 16;
    };
  };
in

{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.activation.ternSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ternSettings="$HOME/${supportDir}/settings.json"
      ternCurrent=${emptySettings}
      if [ -s "$ternSettings" ]; then
        ternCurrent="$ternSettings"
      fi
      ternTmp=$(mktemp)
      if ${lib.getExe pkgs.jq} -s '.[1] as $nix | (.[0] * $nix) | .keybinds = $nix.keybinds' \
        "$ternCurrent" ${settingsFile} > "$ternTmp"; then
        run mkdir -p "$HOME/${supportDir}"
        run install -m 0644 "$ternTmp" "$ternSettings"
      else
        warnEcho "Tern: could not merge settings into $ternSettings, left as it is"
      fi
      rm -f "$ternTmp"
    '';

    # Tern hands fish its shell integration through XDG_DATA_DIRS, which
    # nix-darwin's preinit replaces before fish reads vendor_conf.d. Without
    # the integration's prompt marks, Tern holds back typing in the tabs it
    # opens, so source it here when it was skipped.
    programs.fish.interactiveShellInit = ''
      if set -q KITTY_FISH_XDG_DATA_DIR
          and test -r "$KITTY_FISH_XDG_DATA_DIR/fish/vendor_conf.d/kitty-shell-integration.fish"
          source "$KITTY_FISH_XDG_DATA_DIR/fish/vendor_conf.d/kitty-shell-integration.fish"
      end
    '';

    # Agent blocks (⇧⌘A) start their agent from a non-interactive login fish,
    # which skips the interactive init exporting the github MCP's token (see
    # shells.nix)
    programs.fish.loginShellInit = ''
      if set -q TERN_PANE; and not status is-interactive; and command -q gh
          set -gx GITHUB_PERSONAL_ACCESS_TOKEN (gh auth token 2>/dev/null)
      end
    '';

    # zjstatus-style status segments, the calisia layout and the ⌃⌘C Claude tab
    home.file."${supportDir}/plugins/zellij-feel/plugin.toml" = {
      source = ./plugins/zellij-feel/plugin.toml;
      force = true;
    };
    home.file."${supportDir}/plugins/zellij-feel/window.luau" = {
      source = ./plugins/zellij-feel/window.luau;
      force = true;
    };

    # Tern and omp both load their own themes from here
    home.file.".omp/agent/themes/dark-universe.json" = {
      text = builtins.toJSON theme;
      force = true;
    };
  };
}
