{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  nvimBin = lib.getExe' inputs.self.packages.${pkgs.stdenv.system}.nvim "nvim";
  zellijConfigDir = "${config.home.homeDirectory}/.config/zellij";
in

{
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
  };

  # Smart session launcher: attach if one session exists, fzf-pick if
  # several, start fresh if none.
  # Adapted from: https://github.com/savonarola/homedir/blob/eeaa1e485f0c2965a1e230b5f35c1651a4532701/.tools/zellij.sh
  home.packages = [
    (pkgs.writeShellScriptBin "zj" ''
      sessions=$(${lib.getExe' pkgs.zellij "zellij"} list-sessions | sed 's/\x1B\[[0-9;]*m//g')
      count=$(echo "$sessions" | wc -l)

      if [ -z "$sessions" ]; then
        exec ${lib.getExe' pkgs.zellij "zellij"}
      elif [ "$count" -eq 1 ]; then
        session_name=$(echo "$sessions" | cut -d ' ' -f1)
        exec ${lib.getExe' pkgs.zellij "zellij"} attach "$session_name"
      else
        if command -v fzf >/dev/null; then
          session=$(echo "$sessions" | ${lib.getExe pkgs.fzf} --height 40% --reverse)
          if [ -n "$session" ]; then
            session_name=$(echo "$session" | cut -d ' ' -f1)
            exec ${lib.getExe' pkgs.zellij "zellij"} attach "$session_name"
          fi
        else
          echo "Multiple sessions exist. Use 'zellij attach <session>'"
          echo "$sessions"
          exit 1
        fi
      fi
    '')
  ];

  xdg.configFile."zellij/config.kdl".text = ''
    // tmux to zellij
    // pane == tab
    // Window == pane

    // If you'd like to override the default keybindings completely, be sure to change "keybinds" to "keybinds clear-defaults=true"
    keybinds {
        normal {
            // uncomment this and adjust key if using copy_on_select=false
        }
        locked {
            bind "Ctrl g" { SwitchToMode "Normal"; }
        }

        resize {
            bind "Ctrl n" { SwitchToMode "Normal"; }
            bind "h" "Left" { Resize "Increase Left"; }
            bind "j" "Down" { Resize "Increase Down"; }
            bind "k" "Up" { Resize "Increase Up"; }
            bind "l" "Right" { Resize "Increase Right"; }
            bind "H" { Resize "Decrease Left"; }
            bind "J" { Resize "Decrease Down"; }
            bind "K" { Resize "Decrease Up"; }
            bind "L" { Resize "Decrease Right"; }
            bind "=" "+" { Resize "Increase"; }
            bind "-" { Resize "Decrease"; }
        }
        pane {
            bind "Ctrl p" { SwitchToMode "Normal"; }
            bind "h" "Left" { MoveFocus "Left"; }
            bind "l" "Right" { MoveFocus "Right"; }
            bind "j" "Down" { MoveFocus "Down"; }
            bind "k" "Up" { MoveFocus "Up"; }
            bind "p" { SwitchFocus; }
            bind "n" { NewPane; SwitchToMode "Normal"; }
            bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
            bind "c" { NewPane "Right"; SwitchToMode "Normal"; }
            bind "x" { CloseFocus; SwitchToMode "Normal"; }
            bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
            bind "z" { TogglePaneFrames; SwitchToMode "Normal"; }
            bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
            bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
            bind "r" { SwitchToMode "RenamePane"; PaneNameInput 0;}
        }
        move {
            bind "Ctrl h" { SwitchToMode "Normal"; }
            bind "n" "Tab" { MovePane; }
            bind "p" { MovePaneBackwards; }
            bind "h" "Left" { MovePane "Left"; }
            bind "j" "Down" { MovePane "Down"; }
            bind "k" "Up" { MovePane "Up"; }
            bind "l" "Right" { MovePane "Right"; }
        }
        tab {
            bind "Ctrl t" { SwitchToMode "Normal"; }
            bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
            bind "h" "Left" "Up" "k" { GoToPreviousTab; }
            bind "l" "Right" "Down" "j" { GoToNextTab; }
            bind "n" { NewTab; SwitchToMode "Normal"; }
            bind "x" { CloseTab; SwitchToMode "Normal"; }
            bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
            bind "b" { BreakPane; SwitchToMode "Normal"; }
            bind "]" { BreakPaneRight; SwitchToMode "Normal"; }
            bind "[" { BreakPaneLeft; SwitchToMode "Normal"; }
            bind "1" { GoToTab 1; SwitchToMode "Normal"; }
            bind "2" { GoToTab 2; SwitchToMode "Normal"; }
            bind "3" { GoToTab 3; SwitchToMode "Normal"; }
            bind "4" { GoToTab 4; SwitchToMode "Normal"; }
            bind "5" { GoToTab 5; SwitchToMode "Normal"; }
            bind "6" { GoToTab 6; SwitchToMode "Normal"; }
            bind "7" { GoToTab 7; SwitchToMode "Normal"; }
            bind "8" { GoToTab 8; SwitchToMode "Normal"; }
            bind "9" { GoToTab 9; SwitchToMode "Normal"; }
            bind "Tab" { ToggleTab; }
        }
        scroll {
            bind "Ctrl s" { SwitchToMode "Normal"; }
            bind "e" { EditScrollback; SwitchToMode "Normal"; }
            bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
            bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
            bind "j" "Down" { ScrollDown; }
            bind "k" "Up" { ScrollUp; }
            bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
            bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
            bind "d" { HalfPageScrollDown; }
            bind "u" { HalfPageScrollUp; }
            // uncomment this and adjust key if using copy_on_select=false
            bind "Alt c" { Copy; }
        }
        search {
            bind "Ctrl s" { SwitchToMode "Normal"; }
            bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
            bind "j" "Down" { ScrollDown; }
            bind "k" "Up" { ScrollUp; }
            bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
            bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
            bind "d" { HalfPageScrollDown; }
            bind "u" { HalfPageScrollUp; }
            bind "n" { Search "down"; }
            bind "p" { Search "up"; }
            bind "c" { SearchToggleOption "CaseSensitivity"; }
            bind "w" { SearchToggleOption "Wrap"; }
            bind "o" { SearchToggleOption "WholeWord"; }
        }
        entersearch {
            bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
            bind "Enter" { SwitchToMode "Search"; }
        }
        renametab {
            bind "Ctrl c" { SwitchToMode "Normal"; }
            bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
        }
        renamepane {
            bind "Ctrl c" { SwitchToMode "Normal"; }
            bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
        }
        session {
            bind "Ctrl o" { SwitchToMode "Normal"; }
            bind "Ctrl s" { SwitchToMode "Scroll"; }
            bind "d" { Detach; }
            bind "w" {
                LaunchOrFocusPlugin "session-manager" {
                    floating true
                    move_to_focused_tab true
                };
                SwitchToMode "Normal"
            }
            bind "p" {
                LaunchOrFocusPlugin "plugin-manager" {
                    floating true
                    move_to_focused_tab true
                };
                SwitchToMode "Normal"
            }
        }
        tmux clear-defaults=true {
            bind "Ctrl a" { Write 2; SwitchToMode "Normal"; }
            bind "[" { SwitchToMode "Scroll"; }
            bind "]" { EditScrollback; SwitchToMode "Normal"; }

            bind "\"" { NewPane "Down"; SwitchToMode "Normal"; }
            bind "%" { NewPane "Right"; SwitchToMode "Normal"; }
            bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
            bind "c" { NewTab; SwitchToMode "Normal"; }
            bind "," { SwitchToMode "RenameTab"; }
            bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
            bind "n" { GoToNextTab; SwitchToMode "Normal"; }
            bind "Left" { MoveFocus "Left"; SwitchToMode "Normal"; }
            bind "Right" { MoveFocus "Right"; SwitchToMode "Normal"; }
            bind "Down" { MoveFocus "Down"; SwitchToMode "Normal"; }
            bind "Up" { MoveFocus "Up"; SwitchToMode "Normal"; }
            bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
            bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
            bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
            bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
            bind "o" { FocusNextPane; }
            bind "d" { Detach; }
            bind "Space" { NextSwapLayout; }
            bind "x" { CloseFocus; SwitchToMode "Normal"; }
        }
        shared_except "locked" {
            bind "Ctrl g" { SwitchToMode "Locked"; }
            bind "Ctrl q" { Quit; }
            bind "Alt n" { NewPane; }
            bind "Alt i" { MoveTab "Left"; }
            bind "Alt o" { MoveTab "Right"; }
            bind "Alt h" "Alt Left" { MoveFocusOrTab "Left"; }
            bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
            bind "Alt j" "Alt Down" { MoveFocus "Down"; }
            bind "Alt k" "Alt Up" { MoveFocus "Up"; }
            bind "Alt =" "Alt +" { Resize "Increase"; }
            bind "Alt -" { Resize "Decrease"; }
            bind "Alt [" { PreviousSwapLayout; }
            bind "Alt ]" { NextSwapLayout; }

            bind "Ctrl y" {
                LaunchOrFocusPlugin "https://github.com/karimould/zellij-forgot/releases/latest/download/zellij_forgot.wasm" {
                    floating true
                    move_to_focused_tab true
                }
            }

            // quickly searching and switching between tabs
            bind "Ctrl u" {
                LaunchOrFocusPlugin "https://github.com/rvcas/room/releases/latest/download/room.wasm" {
                    floating true
                    ignore_case true
                    quick_jump true
                }
            }
        }

        shared_except "normal" "locked" {
            bind "Enter" "Esc" { SwitchToMode "Normal"; }
        }
        shared_except "pane" "locked" {
            bind "Ctrl p" { SwitchToMode "Pane"; }
        }
        shared_except "resize" "locked" {
            bind "Ctrl n" { SwitchToMode "Resize"; }
        }
        shared_except "scroll" "locked" {
            bind "Ctrl s" { SwitchToMode "Scroll"; }
        }
        shared_except "session" "locked" {
            bind "Ctrl o" { SwitchToMode "Session"; }
        }
        shared_except "tab" "locked" {
            bind "Ctrl t" { SwitchToMode "Tab"; }
        }
        shared_except "move" "locked" {
            bind "Ctrl h" { SwitchToMode "Move"; }
        }
        shared_except "tmux" "locked" {
            bind "Ctrl a" { SwitchToMode "Tmux"; }
        }
    }

    plugins {
        tab-bar location="zellij:tab-bar"
        status-bar location="zellij:status-bar"
        strider location="zellij:strider"
        compact-bar location="zellij:compact-bar"
        session-manager location="zellij:session-manager"
        welcome-screen location="zellij:session-manager" {
            welcome_screen true
        }
        filepicker location="zellij:strider" {
            cwd "/"
        }

        configuration location="zellij:configuration"
        plugin-manager location="zellij:plugin-manager"

        zjstatus location="https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" {
            // -- Catppuccin Macchiato --
            color_rosewater "#f4dbd6"
            color_flamingo "#f0c6c6"
            color_pink "#f5bde6"
            color_mauve "#c6a0f6"
            color_red "#ed8796"
            color_maroon "#ee99a0"
            color_peach "#faf4ed"
            color_yellow "#eed49f"
            color_green "#a6da95"
            color_teal "#8bd5ca"
            color_sky "#91d7e3"
            color_sapphire "#7dc4e4"
            color_blue "#8aadf4"
            color_lavender "#b7bdf8"
            color_text "#cad3f5"
            color_subtext1 "#b8c0e0"
            color_subtext0 "#a5adcb"
            color_overlay2 "#939ab7"
            color_overlay1 "#8087a2"
            color_overlay0 "#6e738d"
            color_surface2 "#5b6078"
            color_surface1 "#494d64"
            color_surface0 "#363a4f"
            color_base "#24273a"
            color_mantle "#1e2030"
            color_crust "#181926"

            hide_frame_for_single_pane "false"
            mode_normal "#[bg=$green,fg=$crust,bold] NORMAL#[bg=$surface0,fg=$green]"
            mode_tmux "#[bg=$mauve,fg=$crust,bold] TMUX#[bg=$surface0,fg=$mauve]"
            mode_locked "#[bg=$red,fg=$crust,bold] LOCKED  #[bg=$surface0,fg=$red]"
            mode_pane "#[bg=$teal,fg=$crust,bold] PANE#[bg=$surface0,fg=teal]"
            mode_tab "#[bg=$teal,fg=$crust,bold] TAB#[bg=$surface0,fg=$teal]"
            mode_scroll "#[bg=$flamingo,fg=$crust,bold] SCROLL#[bg=$surface0,fg=$flamingo]"
            mode_enter_search "#[bg=$flamingo,fg=$crust,bold] ENT-SEARCH#[bg=$surface0,fg=$flamingo]"
            mode_search "#[bg=$flamingo,fg=$crust,bold] SEARCHARCH#[bg=$surface0,fg=$flamingo]"
            mode_resize "#[bg=$yellow,fg=$crust,bold] RESIZE#[bg=$surface0,fg=$yellow]"
            mode_rename_tab "#[bg=$yellow,fg=$crust,bold] RENAME-TAB#[bg=$surface0,fg=$yellow]"
            mode_rename_pane "#[bg=$yellow,fg=$crust,bold] RENAME-PANE#[bg=$surface0,fg=$yellow]"
            mode_move "#[bg=$yellow,fg=$crust,bold] MOVE#[bg=$surface0,fg=$yellow]"
            mode_session "#[bg=$crust,fg=$crust,bold] SESSION#[bg=$surface0,fg=$crust]"
            mode_prompt "#[bg=$crust,fg=$crust,bold] PROMPT#[bg=$surface0,fg=$crust]"

            border_char "─"
            border_format "#[bg=$surface0]{char}"
            border_position "top"

            datetime        "{format}"
            datetime_format "%A, %d %b %Y %H:%M"
            datetime_timezone "Asia/Jakarta"

            tab_normal "#[bg=$surface0,fg=$blue]#[bg=$blue,fg=$crust,bold]{index} #[bg=$surface1,fg=$blue,bold] {name}{floating_indicator}#[bg=$surface0,fg=$surface1]"
            tab_normal_fullscreen "#[bg=$surface0,fg=$blue]#[bg=$blue,fg=$crust,bold]{index} #[bg=$surface1,fg=$blue,bold] {name}{fullscreen_indicator}#[bg=$surface0,fg=$surface1]"
            tab_normal_sync "#[bg=$surface0,fg=$blue]#[bg=$blue,fg=$crust,bold]{index} #[bg=$surface1,fg=$blue,bold] {name}{sync_indicator}#[bg=$surface0,fg=$surface1]"
            tab_active "#[bg=$surface0,fg=$peach]#[bg=$peach,fg=$crust,bold]{index} #[bg=$surface1,fg=$peach,bold] {name}{floating_indicator}#[bg=$surface0,fg=$surface1]"
            tab_active_fullscreen "#[bg=$surface0,fg=$peach]#[bg=$peach,fg=$crust,bold]{index} #[bg=$surface1,fg=$peach,bold] {name}{fullscreen_indicator}#[bg=$surface0,fg=$surface1]"
            tab_active_sync "#[bg=$surface0,fg=$peach]#[bg=$peach,fg=$crust,bold]{index} #[bg=$surface1,fg=$peach,bold] {name}{sync_indicator}#[bg=$surface0,fg=$surface1]"
            tab_separator "#[bg=$surface0] "
            tab_sync_indicator " "
            tab_fullscreen_indicator " 󰊓"
            tab_floating_indicator " 󰹙"

            notification_format_unread "#[bg=surface0,fg=$yellow]#[bg=$yellow,fg=$crust] #[bg=$surface1,fg=$yellow] {message}#[bg=$surface0,fg=$yellow]"
            notification_format_no_notifications ""
            notification_show_interval "10"

            command_host_command "uname -n"
            command_host_format "{stdout}"
            command_host_interval "3600"
            command_host_rendermode "static"

            command_user_command "whoami"
            command_user_format "{stdout}"
            command_user_interval "10"
            command_user_rendermode "static"

            format_left "#[bg=$surface0,fg=$sapphire]#[bg=$sapphire,fg=$crust,bold] {session} #[bg=$surface0] {mode} #[bg=$surface0,fg=$crust]{tabs}"
            format_right "#[bg=$surface0,fg=$maroon]#[bg=$surface0]#[bg=$surface1,fg=$maroon,bold] {command_user}@{command_host}#[bg=$surface0,fg=$surface1] #[bg=$surface0,fg=$maroon]#[bg=$maroon,fg=$crust]󰃭 #[bg=$surface1,fg=$maroon,bold] {datetime}#[bg=$surface0,fg=$surface1]"
            format_space "#[bg=$surface0]"
            format_hide_on_overlength "true"
            format_precedence "lrc"

        }
    }

    load_plugins {
        "https://github.com/karimould/zellij-forgot/releases/latest/download/zellij_forgot.wasm" {}
    }

    // Choose what to do when zellij receives SIGTERM, SIGINT, SIGQUIT or SIGHUP
    // eg. when terminal window with an active zellij session is closed
    // Options:
    //   - detach (Default)
    //   - quit
    //
    on_force_close "detach"

    //  Send a request for a simplified ui (without arrow fonts) to plugins
    //  Options:
    //    - true
    //    - false (Default)
    //
    simplified_ui true

    // Choose the path to the default shell that zellij will use for opening new panes
    // Default: $SHELL
    //
    default_shell "fish"

    // Toggle between having pane frames around the panes
    // Options:
    //   - true (default)
    //   - false
    //
    pane_frames false

    // Toggle between having Zellij lay out panes according to a predefined set of layouts whenever possible
    // Options:
    //   - true (default)
    //   - false
    //
    auto_layout true

    // Whether sessions should be serialized to the cache folder (including their tabs/panes, cwds and running commands) so that they can later be resurrected
    // Options:
    //   - true (default)
    //   - false
    //
    session_serialization true

    // Whether pane viewports are serialized along with the session, default is false
    // Options:
    //   - true
    //   - false (default)
    serialize_pane_viewport true

    // Scrollback lines to serialize along with the pane viewport when serializing sessions, 0
    // defaults to the scrollback size. If this number is higher than the scrollback size, it will
    // also default to the scrollback size. This does nothing if `serialize_pane_viewport` is not true.
    //
    scrollback_lines_to_serialize 10000

    // Define color themes for Zellij
    // For more examples, see: https://github.com/zellij-org/zellij/tree/main/example/themes
    // Once these themes are defined, one of them should to be selected in the "theme" section of this file
    //
    themes {
    }

    ui {
        pane_frames {
            hide_session_name true
            rounded_corners false
        }
    }

    // Choose the theme that is specified in the themes section.
    // Default: default
    //
    theme "cyberdream"

    // The name of the default layout to load on startup
    // Default: "default"
    //
    default_layout "calisia"

    // Choose the mode that zellij uses when starting up.
    // Default: normal
    //
    default_mode "normal"

    // Toggle enabling the mouse mode.
    // On certain configurations, or terminals this could
    // potentially interfere with copying text.
    // Options:
    //   - true (default)
    //   - false
    //
    mouse_mode true

    // Configure the scroll back buffer size
    // This is the number of lines zellij stores for each pane in the scroll back
    // buffer. Excess number of lines are discarded in a FIFO fashion.
    // Valid values: positive integers
    // Default value: 10000
    //
    scroll_buffer_size 10000

    // Choose the destination for copied text
    // Allows using the primary selection buffer (on x11/wayland) instead of the system clipboard.
    // Does not apply when using copy_command.
    // Options:
    //   - system (default)
    //   - primary
    //
    copy_clipboard "system"

    // Enable or disable automatic copy (and clear) of selection when releasing mouse
    // Default: true
    //
    copy_on_select true

    // Path to the default editor to use to edit pane scrollbuffer
    // Default: $EDITOR or $VISUAL
    //
    scrollback_editor "${nvimBin}"

    // When attaching to an existing session with other users,
    // should the session be mirrored (true)
    // or should each user have their own cursor (false)
    // Default: false
    //
    mirror_session false

    // The folder in which Zellij will look for layouts
    //
    layout_dir "${zellijConfigDir}/layouts"

    // The folder in which Zellij will look for themes
    //
    theme_dir "${zellijConfigDir}/themes"

    // Enable or disable the rendering of styled and colored underlines (undercurl).
    // May need to be disabled for certain unsupported terminals
    // Default: true
    //
    styled_underlines true

    // Enable or disable writing of session metadata to disk (if disabled, other sessions might not know
    // metadata info on this session)
    // Default: false
    //
    disable_session_metadata false

    // Whether to show release notes on first version run
    show_release_notes true
    show_startup_tips false
  '';

  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
        default_tab_template {
            pane size=2 borderless=true {
                plugin location="https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" {
                    format_left   "{mode} #[fg=#89B4FA,bold]{session}"
                    format_center "{tabs}"
                    format_right  "{command_git_branch} {datetime}"
                    format_space  ""

                    border_enabled  "false"
                    border_char     "─"
                    border_format   "#[fg=#6C7086]{char}"
                    border_position "top"

                    hide_frame_for_single_pane "true"

                    mode_normal  "#[bg=blue] "
                    mode_tmux    "#[bg=#ffc387] "

                    tab_normal   "#[fg=#6C7086] {name} "
                    tab_active   "#[fg=#9399B2,bold,italic] {name} "

                    command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                    command_git_branch_format      "#[fg=blue] {stdout} "
                    command_git_branch_interval    "10"
                    command_git_branch_rendermode  "static"

                    datetime        "#[fg=#6C7086,bold] {format} "
                    datetime_format "%A, %d %b %Y %H:%M"
                    datetime_timezone "Asia/Jakarta"
                }
            }

            children

            pane size=2 borderless=true {
              plugin location="status-bar"
            }
        }
    }
  '';

  xdg.configFile."zellij/layouts/calisia.kdl".text = ''
    layout {
      default_tab_template {
        pane size=2 borderless=true {
          plugin location="zjstatus"
        }

        children

        pane size=2 borderless=true {
          plugin location="status-bar" {
            classic false
          }
        }
      }

      tab {
        pane split_direction="vertical" {
            pane
            pane split_direction="horizontal" {
                pane
                pane
            }
        }
    }
    }
  '';

  xdg.configFile."zellij/layouts/experimental.kdl".text = ''
    layout {
        default_tab_template {
            children
            pane size=1 borderless=true {
                plugin location="https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" {
                    format_left   "{mode} #[fg=#89B4FA,bold]{session}"
                    format_center "{tabs}"
                    format_right  "{command_git_branch} {datetime}"
                    format_space  ""

                    border_enabled  "false"
                    border_char     "─"
                    border_format   "#[fg=#6C7086]{char}"
                    border_position "top"

                    hide_frame_for_single_pane "true"

                    mode_normal  "#[bg=blue] "
                    mode_tmux    "#[bg=#ffc387] "

                    tab_normal   "#[fg=#6C7086] {name} "
                    tab_active   "#[fg=#9399B2,bold,italic] {name} "

                    command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                    command_git_branch_format      "#[fg=blue] {stdout} "
                    command_git_branch_interval    "10"
                    command_git_branch_rendermode  "static"

                    datetime        "#[fg=#6C7086,bold] {format} "
                    datetime_format "%A, %d %b %Y %H:%M"
                    datetime_timezone "Asia/Jakarta"
                }
            }
        }
    }
  '';

  xdg.configFile."zellij/layouts/multiple_tabs_layout.kdl".text = ''
    layout {
        default_tab_template {
            pane size=1 borderless=true {
                plugin location="zellij:tab-bar"
            }
            children
            pane size=2 borderless=true {
                plugin location="zellij:status-bar"
            }
        }
        tab split_direction="Vertical" {
            pane split_direction="Vertical" {
                pane size="50%"
                pane size="50%"
            }
        }
        tab
        tab split_direction="Vertical" {
            pane split_direction="Vertical" {
                pane size="50%"
                pane size="50%"
            }
        }
        tab split_direction="Vertical" {
            pane split_direction="Vertical" {
                pane size="50%"
                pane size="50%" split_direction="Horizontal" {
                    pane size="50%"
                    pane size="50%"
                }
            }
        }
        tab
        tab
        tab
        tab split_direction="Vertical" {
            pane split_direction="Vertical" {
                pane size="20%" {
                    plugin location="zellij:strider"
                }
                pane size="80%" split_direction="Horizontal" {
                    pane size="50%"
                    pane size="50%"
                }
            }
        }
        tab split_direction="Vertical" {
            pane split_direction="Vertical" {
                pane size="40%"
                pane size="60%" split_direction="Horizontal" {
                    pane size="50%"
                    pane size="50%"
                }
            }
        }
    }
  '';

  xdg.configFile."zellij/layouts/slanted.kdl".text = ''
    layout {
        tab {
            pane split_direction="vertical" {
                pane
            }
        }

        default_tab_template {

            pane size=1 borderless=true {
                plugin location="https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" {
                    format_left  "#[fg=black,bg=blue,bold]{session}  #[fg=blue,bg=#181825]{tabs}"
                    format_right "{datetime}"
                    format_space "#[bg=#181825]"

                    hide_frame_for_single_pane "true"

                    mode_normal  "#[bg=blue] "

                    tab_normal              "#[fg=#181825,bg=#4C4C59] #[fg=#000000,bg=#4C4C59]{index}  {name} #[fg=#4C4C59,bg=#181825]"
                    tab_normal_fullscreen   "#[fg=#6C7086,bg=#181825] {index} {name} [] "
                    tab_normal_sync         "#[fg=#6C7086,bg=#181825] {index} {name} <> "
                    tab_active              "#[fg=#181825,bg=#ffffff,bold,italic] {index}  {name} #[fg=#ffffff,bg=#181825]"
                    tab_active_fullscreen   "#[fg=#9399B2,bg=#181825,bold,italic] {index} {name} [] "
                    tab_active_sync         "#[fg=#9399B2,bg=#181825,bold,italic] {index} {name} <> "


                    datetime          "#[fg=#6C7086,bg=#b1bbfa,bold] {format} "
                    datetime_format   "%d/%m/%Y %H:%M"
                    datetime_timezone "Asia/Jakarta"

                    command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                    command_git_branch_format      "#[fg=blue] {stdout} "
                    command_git_branch_interval    "10"
                    command_git_branch_rendermode  "static"
                }
            }

            children
        }
    }
  '';

  xdg.configFile."zellij/layouts/slanted_widescreen.kdl".text = ''
    layout {
        tab {
            pane split_direction="vertical" {
                pane
                pane split_direction="horizontal" {
                    pane
                    pane
                }
            }
        }

        default_tab_template {
            pane size=1 borderless=true {
                plugin location="https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" {
                    format_left  "#[fg=black,bg=blue,bold]{session}  #[fg=blue,bg=#181825]{tabs}"
                    format_right "{datetime}"
                    format_space "#[bg=#181825]"

                    hide_frame_for_single_pane "true"

                    mode_normal  "#[bg=blue] "

                    tab_normal              "#[fg=#181825,bg=#4C4C59] #[fg=#000000,bg=#4C4C59]{index}  {name} #[fg=#4C4C59,bg=#181825]"
                    tab_normal_fullscreen   "#[fg=#6C7086,bg=#181825] {index} {name} [] "
                    tab_normal_sync         "#[fg=#6C7086,bg=#181825] {index} {name} <> "
                    tab_active              "#[fg=#181825,bg=#ffffff,bold,italic] {index}  {name} #[fg=#ffffff,bg=#181825]"
                    tab_active_fullscreen   "#[fg=#9399B2,bg=#181825,bold,italic] {index} {name} [] "
                    tab_active_sync         "#[fg=#9399B2,bg=#181825,bold,italic] {index} {name} <> "

                    datetime          "#[fg=#6C7086,bg=#b1bbfa,bold] {format} "
                    datetime_format   "%d/%m/%Y %H:%M"
                    datetime_timezone "Asia/Jakarta"

                    command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                    command_git_branch_format      "#[fg=blue] {stdout} "
                    command_git_branch_interval    "10"
                    command_git_branch_rendermode  "static"
                }
            }
            children
        }
    }
  '';

  xdg.configFile."zellij/themes/cyberdream.kdl".text = ''
    themes {
        cyberdream {
            bg "#16181a"
            fg "#ffffff"
            black "#7b8496"
            red "#ff6e5e"
            green "#5eff6c"
            yellow "#f1ff5e"
            blue "#5ea1ff"
            magenta "#bd5eff"
            cyan "#5ef1ff"
            white "#ffffff"
            orange "#ffbd5e"
        }
    }
  '';

  xdg.configFile."zellij/themes/cyberdream-light.kdl".text = ''
    themes {
        cyberdream {
            bg "#ffffff"
            fg "#16181a"
            black "#7b8496"
            red "#d11500"
            green "#008b0c"
            yellow "#997b00"
            blue "#0057d1"
            magenta "#a018ff"
            cyan "#008c99"
            white "#16181a"
            orange "#d17c00"
        }
    }
  '';

  # Reference snippets (not auto-loaded) — copy the body into the zjstatus
  # declaration above if you want to swap palettes.
  xdg.configFile."zellij/themes/zjstatus/catppuccin.kdl".text = ''
    // Catppuccin theme for the `zjstatus` plugin (v0.17.0+)
    // https://github.com/merikan/.dotfiles/blob/main/config/zellij/themes/zjstatus/catppuccin.kdl

    // Usage:
    //  1. Copy the content to the body of the zjstatus declaration in your config or layout file, see `config.kdl`
    //  2. Uncomment the color palette you want to use. Default is Mocha

    {
        // -- Catppuccin Mocha --
        color_rosewater "#f5e0dc"
        color_flamingo "#f2cdcd"
        color_pink "#f5c2e7"
        color_mauve "#cba6f7"
        color_red "#f38ba8"
        color_maroon "#eba0ac"
        color_peach "#fab387"
        color_yellow "#f9e2af"
        color_green "#a6e3a1"
        color_teal "#94e2d5"
        color_sky "#89dceb"
        color_sapphire "#74c7ec"
        color_blue "#89b4fa"
        color_lavender "#b4befe"
        color_text "#cdd6f4"
        color_subtext1 "#bac2de"
        color_subtext0 "#a6adc8"
        color_overlay2 "#9399b2"
        color_overlay1 "#7f849c"
        color_overlay0 "#6c7086"
        color_surface2 "#585b70"
        color_surface1 "#45475a"
        color_surface0 "#313244"
        color_base "#1e1e2e"
        color_mantle "#181825"
        color_crust "#11111b"

        format_left   "#[bg=$surface0,fg=$sapphire]#[bg=$sapphire,fg=$crust,bold] {session} #[bg=$surface0] {mode}#[bg=$surface0] {tabs}"
        format_center "{notifications}"
        format_right  "#[bg=$surface0,fg=$flamingo]#[fg=$crust,bg=$flamingo] #[bg=$surface1,fg=$flamingo,bold] {command_user}@{command_host}#[bg=$surface0,fg=$surface1]#[bg=$surface0,fg=$maroon]#[bg=$maroon,fg=$crust]󰃭 #[bg=$surface1,fg=$maroon,bold] {datetime}#[bg=$surface0,fg=$surface1]"
        format_space  "#[bg=$surface0]"
        format_hide_on_overlength "true"
        format_precedence "lrc"

        border_enabled  "false"
        border_char     "─"
        border_format   "#[bg=$surface0]{char}"
        border_position "top"

        hide_frame_for_single_pane "true"

        mode_normal        "#[bg=$green,fg=$crust,bold] NORMAL#[bg=$surface0,fg=$green]"
        mode_tmux          "#[bg=$mauve,fg=$crust,bold] TMUX#[bg=$surface0,fg=$mauve]"
        mode_locked        "#[bg=$red,fg=$crust,bold] LOCKED#[bg=$surface0,fg=$red]"
        mode_pane          "#[bg=$teal,fg=$crust,bold] PANE#[bg=$surface0,fg=teal]"
        mode_tab           "#[bg=$teal,fg=$crust,bold] TAB#[bg=$surface0,fg=$teal]"
        mode_scroll        "#[bg=$flamingo,fg=$crust,bold] SCROLL#[bg=$surface0,fg=$flamingo]"
        mode_enter_search  "#[bg=$flamingo,fg=$crust,bold] ENT-SEARCH#[bg=$surface0,fg=$flamingo]"
        mode_search        "#[bg=$flamingo,fg=$crust,bold] SEARCHARCH#[bg=$surface0,fg=$flamingo]"
        mode_resize        "#[bg=$yellow,fg=$crust,bold] RESIZE#[bg=$surface0,fg=$yellow]"
        mode_rename_tab    "#[bg=$yellow,fg=$crust,bold] RENAME-TAB#[bg=$surface0,fg=$yellow]"
        mode_rename_pane   "#[bg=$yellow,fg=$crust,bold] RENAME-PANE#[bg=$surface0,fg=$yellow]"
        mode_move          "#[bg=$yellow,fg=$crust,bold] MOVE#[bg=$surface0,fg=$yellow]"
        mode_session       "#[bg=$pink,fg=$crust,bold] SESSION#[bg=$surface0,fg=$pink]"
        mode_prompt        "#[bg=$pink,fg=$crust,bold] PROMPT#[bg=$surface0,fg=$pink]"

        tab_normal              "#[bg=$surface0,fg=$blue]#[bg=$blue,fg=$crust,bold]{index} #[bg=$surface1,fg=$blue,bold] {name}{floating_indicator}#[bg=$surface0,fg=$surface1]"
        tab_normal_fullscreen   "#[bg=$surface0,fg=$blue]#[bg=$blue,fg=$crust,bold]{index} #[bg=$surface1,fg=$blue,bold] {name}{fullscreen_indicator}#[bg=$surface0,fg=$surface1]"
        tab_normal_sync         "#[bg=$surface0,fg=$blue]#[bg=$blue,fg=$crust,bold]{index} #[bg=$surface1,fg=$blue,bold] {name}{sync_indicator}#[bg=$surface0,fg=$surface1]"
        tab_active              "#[bg=$surface0,fg=$peach]#[bg=$peach,fg=$crust,bold]{index} #[bg=$surface1,fg=$peach,bold] {name}{floating_indicator}#[bg=$surface0,fg=$surface1]"
        tab_active_fullscreen   "#[bg=$surface0,fg=$peach]#[bg=$peach,fg=$crust,bold]{index} #[bg=$surface1,fg=$peach,bold] {name}{fullscreen_indicator}#[bg=$surface0,fg=$surface1]"
        tab_active_sync         "#[bg=$surface0,fg=$peach]#[bg=$peach,fg=$crust,bold]{index} #[bg=$surface1,fg=$peach,bold] {name}{sync_indicator}#[bg=$surface0,fg=$surface1]"
        tab_separator           "#[bg=$surface0] "

        tab_sync_indicator       " "
        tab_fullscreen_indicator " 󰊓"
        tab_floating_indicator   " 󰹙"

        notification_format_unread "#[bg=surface0,fg=$yellow]#[bg=$yellow,fg=$crust] #[bg=$surface1,fg=$yellow] {message}#[bg=$surface0,fg=$yellow]"
        notification_format_no_notifications ""
        notification_show_interval "10"

        command_host_command    "uname -n"
        command_host_format     "{stdout}"
        command_host_interval   "0"
        command_host_rendermode "static"

        command_user_command    "whoami"
        command_user_format     "{stdout}"
        command_user_interval   "10"
        command_user_rendermode "static"

        datetime          "{format}"
        datetime_format   "%Y-%m-%d 󰅐 %H:%M"
        datetime_timezone "Asia/Jakarta"
    }
  '';

  xdg.configFile."zellij/themes/zjstatus/gruvbox.kdl".text = ''
    // Gruvbox Dark theme  for the `zjstatus` plugin
    // https://github.com/merikan/.dotfiles/blob/main/config/zellij/themes/zjstatus/gruvbox.kdl

    // Usage:
    //  1. Copy the content to the body of the zjstatus declaration in your config or layout file, see `config.kdl`
    //  2. Uncomment the color palette you want to use. Default is Dark mode

    {
        // -- Gruvbox Dark mode
        color_bg0 "#282828"
        color_bg1 "#3c3836"
        color_bg2 "#504945"
        color_bg3 "#665c54"
        color_bg4 "#7c6f64"
        color_fg0 "#fbf1c7"
        color_fg1 "#ebdbb2"
        color_fg2 "#d5c4a1"
        color_fg3 "#bdae93"
        color_fg4 "#a89984"
        color_red "#fb4934"
        color_green "#b8bb26"
        color_yellow "#fabd2f"
        color_blue "#83a598"
        color_purple "#d3869b"
        color_aqua "#8ec07c"
        color_gray "#a89984"
        color_orange "#fe8019"
        color_neutral_red "#cc241d"
        color_neutral_green "#98971a"
        color_neutral_yellow "#d79921"
        color_neutral_blue "#458588"
        color_neutral_purple "#b16286"
        color_neutral_aqua "#689d6a"
        color_neutral_gray "#928374"
        color_neutral_orange "#d65d0e"

        format_left   "#[bg=$bg2,fg=$fg3] {session} {mode}#[bg=$bg1]{tabs}"
        format_center "{notifications}"
        format_right  "#[bg=$bg1,fg=$bg2]#[bg=$bg2,fg=$fg4] {command_user}@{command_host} #[bg=$bg2,fg=$fg3]#[bg=$fg3,fg=$bg1] {datetime} "
        format_space  "#[bg=$bg1,fg=$fg1]"
        format_hide_on_overlength "true"
        format_precedence "lrc"

        border_enabled  "true"
        border_char     "─"
        border_format   "#[fg=$bg1]{char}"
        border_position "top"

        hide_frame_for_single_pane "true"

        mode_normal        "#[bg=$bg3,fg=$bg2]#[bg=$bg3,fg=$fg3,bold] NORMAL#[bg=$bg1,fg=$bg3]"
        mode_tmux          "#[bg=$green,fg=$bg2]#[bg=$green,fg=$bg0,bold] TMUX#[bg=$bg1,fg=$green]"
        mode_locked        "#[bg=$red,fg=$bg2]#[bg=$red,fg=$bg0,bold] LOCKED#[bg=$bg1,fg=$red]"
        mode_pane          "#[bg=$aqua,fg=$bg2]#[bg=$aqua,fg=$bg0,bold] PANE#[bg=$bg1,fg=$aqua]"
        mode_tab           "#[bg=$aqua,fg=$bg2]#[bg=$aqua,fg=$bg0,bold] TAB#[bg=$bg1,fg=$aqua]"
        mode_scroll        "#[bg=$blue,fg=$bg2]#[bg=$blue,fg=$bg0,bold] SCROLL#[bg=$bg1,fg=$blue]"
        mode_enter_search  "#[bg=$blue,fg=$bg2]#[bg=$blue,fg=$bg0,bold] ENT-SEARCH#[bg=$bg1,fg=$blue]"
        mode_search        "#[bg=$blue,fg=$bg2]#[bg=$blue,fg=$bg0,bold] SEARCH#[bg=$bg1,fg=$blue]"
        mode_resize        "#[bg=$yellow,fg=$bg2]#[bg=$yellow,fg=$bg0,bold] RESIZE#[bg=$bg1,fg=$yellow]"
        mode_rename_tab    "#[bg=$yellow,fg=$bg2]#[bg=$yellow,fg=$bg0,bold] RESIZE#[bg=$bg1,fg=$yellow]"
        mode_rename_pane   "#[bg=$yellow,fg=$bg2]#[bg=$yellow,fg=$bg0,bold] RESIZE#[bg=$bg1,fg=$yellow]"
        mode_move          "#[bg=$yellow,fg=$bg2]#[bg=$yellow,fg=$bg0,bold] MOVE#[bg=$bg1,fg=$yellow]"
        mode_session       "#[bg=$purple,fg=$bg2]#[bg=$purple,fg=$bg0,bold] MOVE#[bg=$bg1,fg=$purple]"
        mode_prompt        "#[bg=$purple,fg=$bg2]#[bg=$purple,fg=$bg0,bold] PROMPT#[bg=$bg1,fg=$purple]"

        tab_normal              "#[bg=$bg2,fg=$bg1]#[bg=$bg2,fg=$fg1] {index} #[bg=$bg2,fg=$fg1,bold] {name} {floating_indicator}#[bg=$bg1,fg=$bg2]"
        tab_normal_fullscreen   "#[bg=$bg2,fg=$bg1]#[bg=$bg2,fg=$fg1] {index} #[bg=$bg2,fg=$fg1,bold] {name} {fullscreen_indicator}#[bg=$bg1,fg=$bg2]"
        tab_normal_sync         "#[bg=$bg2,fg=$bg1]#[bg=$bg2,fg=$fg1] {index} #[bg=$bg2,fg=$fg1,bold] {name} {sync_indicator}#[bg=$bg1,fg=$bg2]"
        tab_active              "#[bg=$yellow,fg=$bg1]#[bg=$yellow,fg=$bg2] {index} #[bg=$yellow,fg=$bg2,bold] {name} {floating_indicator}#[bg=$bg1,fg=$yellow]"
        tab_active_fullscreen   "#[bg=$yellow,fg=$bg1]#[bg=$yellow,fg=$bg2] {index} #[bg=$yellow,fg=$bg2,bold] {name} {fullscreen_indicator}#[bg=$bg1,fg=$yellow]"
        tab_active_sync         "#[bg=$yellow,fg=$bg1]#[bg=$yellow,fg=$bg2] {index} #[bg=$yellow,fg=$bg2,bold] {name} {sync_indicator}#[bg=$bg1,fg=$yellow]"
        tab_separator           "#[bg=$bg1,fg=$fg1]"

        tab_sync_indicator       ""
        tab_fullscreen_indicator "󰊓"
        tab_floating_indicator   "󰹙"

        notification_format_unread "#[bg=$orange,fg=$bg1]#[bg=$orange,fg=$bg1] {message} #[bg=$bg1,fg=$orange]"
        notification_format_no_notifications ""
        notification_show_interval "10"

        command_host_command    "uname -n"
        command_host_format     "{stdout}"
        command_host_interval   "0"
        command_host_rendermode "static"

        command_user_command    "whoami"
        command_user_format     "{stdout}"
        command_user_interval   "0"
        command_user_rendermode "static"

        datetime          "{format}"
        datetime_format   "%Y-%m-%d %H:%M"
        datetime_timezone "Asia/Jakarta"
    }
  '';
}
