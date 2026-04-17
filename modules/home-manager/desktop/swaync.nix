{ config, ... }:

let
  palette = config.colorScheme.palette;
  # Helper to ensure colors have a single # prefix
  fixColor = c: if (builtins.substring 0 1 c) == "#" then c else "#${c}";

  bg = fixColor palette.base00;
  bgAlt = fixColor palette.base01;
  fg = fixColor palette.base05;
  fgAlt = fixColor palette.base04;
  accent = fixColor palette.base06;
  urgent = fixColor palette.base08;
  border = fixColor palette.base02;
in
{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      control-center-positionX = "right";
      control-center-positionY = "top";
      layer = "overlay";
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
      control-center-margin-left = 10;
      notification-icon-size = 48;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 5;
      timeout-low = 2;
      timeout-critical = 0;
      fit-to-screen = false;
      layer-shell = true;
      control-center-width = 400;
      control-center-height = 600;
      notification-window-width = 400;
      keyboard-shortcuts = true;
      image-visibility = "always";
      transition-time = 200;
      hide-on-clear = false;
      pause-level-low = false;
      cssPriority = "user";
    };
    style = ''
      @define-color bg ${bg};
      @define-color bg-alt ${bgAlt};
      @define-color fg ${fg};
      @define-color fg-alt ${fgAlt};
      @define-color accent ${accent};
      @define-color urgent ${urgent};
      @define-color border ${border};

      * {
        font-family: "Fira Sans", sans-serif;
        font-weight: 500;
      }

      .notificationwindow,
      .blank-window {
        background: transparent;
      }

      .notification-row {
        outline: none;
      }

      .notification-row:focus,
      .notification-row:hover {
        background: @bg-alt;
      }

      .notification {
        border-radius: 12px;
        margin: 6px 12px;
        box-shadow: 0 0 10px 0 rgba(0,0,0,0.4);
        padding: 0;
        background: @bg;
        border: 1px solid @border;
      }

      .notification-content {
        background: transparent;
        padding: 12px;
        border-radius: 12px;
      }

      .close-button {
        background: @bg-alt;
        color: @fg;
        text-shadow: none;
        padding: 0;
        border-radius: 100%;
        margin-top: 8px;
        margin-right: 8px;
        box-shadow: none;
        border: none;
        min-width: 20px;
        min-height: 20px;
      }

      .close-button:hover {
        box-shadow: none;
        background: @urgent;
        transition: all 0.15s ease;
      }

      .notification-default-action,
      .notification-action {
        padding: 4px;
        margin: 0;
        box-shadow: none;
        background: transparent;
        border: none;
        color: @fg;
        transition: all 0.15s ease;
      }

      .notification-default-action:hover,
      .notification-action:hover {
        -gtk-icon-effect: none;
        background: @bg-alt;
      }

      .notification-default-action {
        border-radius: 12px;
      }

      .notification-action {
        border-radius: 8px;
        border: 1px solid @border;
        margin: 8px;
      }

      .summary {
        font-size: 15px;
        font-weight: 700;
        background: transparent;
        color: @fg;
        text-shadow: none;
      }

      .time {
        font-size: 12px;
        font-weight: 500;
        background: transparent;
        color: @fg-alt;
        text-shadow: none;
        margin-right: 18px;
      }

      .body {
        font-size: 13px;
        font-weight: 500;
        background: transparent;
        color: @fg-alt;
        text-shadow: none;
      }

      .control-center {
        background: @bg;
        border-radius: 12px;
        border: 1px solid @border;
        box-shadow: 0 0 10px 0 rgba(0,0,0,0.4);
        margin: 12px;
      }

      .control-center-list {
        background: transparent;
      }

      .control-center-list-placeholder {
        opacity: 0.5;
      }

      .floating-notifications {
        background: transparent;
      }

      .blank-window {
        background: transparent;
      }

      .widget-title {
        color: @accent;
        background: @bg;
        padding: 12px;
        margin: 8px;
        font-size: 1.5rem;
        border-radius: 12px;
      }

      .widget-title > button {
        font-size: 1rem;
        color: @fg;
        text-shadow: none;
        background: @bg-alt;
        box-shadow: none;
        border-radius: 8px;
        border: 1px solid @border;
        padding: 4px 12px;
      }

      .widget-title > button:hover {
        background: @urgent;
      }

      .widget-dnd {
        background: @bg;
        padding: 8px;
        margin: 8px;
        border-radius: 12px;
        color: @accent;
      }

      .widget-dnd > switch {
        font-size: 1rem;
        border-radius: 12px;
        background: @bg-alt;
        border: 1px solid @border;
      }

      .widget-dnd > switch:checked {
        background: @accent;
        border: 1px solid @accent;
      }

      .widget-dnd > switch slider {
        background: @fg;
        border-radius: 12px;
      }

      .widget-label {
        margin: 8px;
      }

      .widget-label > label {
        font-size: 1rem;
        color: @fg;
      }

      .widget-mpris {
        color: @fg;
        background: @bg-alt;
        padding: 12px;
        margin: 8px;
        border-radius: 12px;
      }

      .widget-mpris-player {
        padding: 8px;
        margin: 4px;
      }

      .widget-mpris-title {
        font-weight: 700;
        font-size: 1.1rem;
      }

      .widget-mpris-subtitle {
        font-size: 0.9rem;
      }
    '';
  };
}
