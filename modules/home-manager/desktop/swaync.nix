{ config, ... }:

{
  services.swaync = {
    enable = true;

    settings = {
      positionX = "right";
      positionY = "top";
      control-center-margin-top = 8;
      control-center-margin-bottom = 8;
      control-center-margin-right = 8;
      control-center-margin-left = 8;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 10;
      timeout-low = 5;
      timeout-critical = 0;
      fit-to-screen = true;
      control-center-width = 500;
      control-center-height = 600;
      notification-window-width = 500;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
    };

    style = ''
      @define-color foreground #${config.colorScheme.palette.base05};
      @define-color background #${config.colorScheme.palette.base00};
      @define-color background-alpha #${config.colorScheme.palette.base00};
      @define-color accent #${config.colorScheme.palette.base06};
      @define-color current-line #${config.colorScheme.palette.base01};
      @define-color comment #${config.colorScheme.palette.base03};
      @define-color red #${config.colorScheme.palette.base08};
      @define-color yellow #${config.colorScheme.palette.base0A};

      /* Notification Rows */
      .notification-row {
        transition: all 200ms ease;
        outline: none;
        margin-bottom: 4px;
        margin-right: 13px;
        margin-top: 8px;
      }

      .control-center .notification-row:focus,
      .control-center .notification-row:hover {
        opacity: 1;
        background: transparent;
      }

      .notification-row:focus .notification,
      .notification-row:hover .notification {
        box-shadow: 0 1px 3px 1px rgba(0, 0, 0, 0.5);
        border: 0px solid @accent;
        background: @current-line;
      }

      .control-center .notification {
        box-shadow: none;
      }

      .control-center .notification-row {
        opacity: 0.5;
        margin: -5px;
      }

      /* Main Notification Body */
      .notification {
        transition: all 200ms ease;
        margin: 12px 7px 0px 7px;
        box-shadow: 0 1px 3px 1px rgba(0, 0, 0, 0.5);
        padding: 0;
      }

      /* Urgency Colors */
      .low {
        background: @background;
        padding: 6px;
      }

      .normal {
        background: @background;
        padding: 6px
      }

      .critical {
        background: @red;
        padding: 6px;
      }

      .notification-content {
        background: transparent;
        padding: 6px;
      }

      /* Close Button */
      .close-button {
        background: @current-line;
        color: @foreground;
        text-shadow: none;
        padding: 0;
        margin-top: 17px;
        margin-right: 10px;
        box-shadow: none;
        border: none;
        min-width: 24px;
        min-height: 24px;
      }

      .close-button:hover {
        box-shadow: none;
        background: @comment;
        transition: all 0.15s ease-in-out;
        border: none;
      }

      /* Actions */
      .notification-default-action,
      .notification-action {
        padding: 4px;
        margin: 0;
        box-shadow: none;
        background: @current-line;
        border: 2px solid @accent;
        color: @foreground;
      }

      .notification-default-action:hover,
      .notification-action:hover {
        -gtk-icon-effect: none;
        background: @current-line;
      }


      .notification-default-action:not(:only-child) {
        border-bottom-left-radius: 0px;
        border-bottom-right-radius: 0px;
      }

      .notification-action {
        border-top: none;
        border-right: none;
      }

      .notification-action:first-child {
        border-bottom-left-radius: 8px;
      }

      .notification-action:last-child {
        border-bottom-right-radius: 8px;
        border-right: 1px solid @accent;
      }

      /* Text Elements */
      .summary {
        font-size: 16px;
        font-weight: bold;
        background: transparent;
        color: @foreground;
        text-shadow: none;
      }

      .time {
        font-size: 16px;
        font-weight: bold;
        background: transparent;
        color: @foreground;
        text-shadow: none;
        margin-right: 18px;
      }

      .body {
        font-size: 15px;
        font-weight: normal;
        background: transparent;
        color: @foreground;
        text-shadow: none;
      }

      /* Control Center / DND / Clear All */
      .top-action-title {
        color: @foreground;
        text-shadow: none;
      }

      .control-center-clear-all {
        color: @foreground;
        text-shadow: none;
        background: @background;
        border: 2px solid @accent;
        box-shadow: none;
      }

      .control-center-clear-all:hover {
        background: @background;
      }

      .control-center-dnd {
        background: @background;
        border: 1px solid @accent;
        box-shadow: none;
      }

      .control-center-dnd:checked {
        background: @accent;
      }

      .control-center-dnd slider {
        background: @background;
      }

      /* Main Window Styling */
      .control-center {
        background: @background-alpha;
        background-clip: border-box;
        padding: 4px;
        box-shadow: 0 0 0 1px rgba(0, 0, 0, 0.3), 0 1px 3px 1px rgba(0, 0, 0, 0.7), 0 2px 6px 2px rgba(0, 0, 0, 0.3);
        color: @foreground;
        border: 2px solid @accent;
      }

      .control-center-list {
        background: transparent;
      }

      .floating-notifications {
        background: transparent;
      }

      .blank-window {
        background: transparent;
      }

      /* Widgets */
      .widget-title {
        margin: 8px;
        font-size: 1.5rem;
      }

      .widget-title > button {
        font-size: initial;
        color: @foreground;
        text-shadow: none;
        background: @background;
        border: 2px solid @accent;
        box-shadow: none;
      }

      .widget-title > button:hover {
        background: @background;
      }

      .widget-dnd {
        margin: 8px;
        font-size: 1.1rem;
      }

      .widget-dnd > switch {
        font-size: initial;
        background: @background;
        border: 1px solid @accent;
        box-shadow: none;
      }

      .widget-dnd > switch:checked {
        background: @accent;
      }

      .widget-dnd > switch slider {
        background: @background;
        border: 1px solid @foreground;
      }

      .widget-label {
        margin: 8px;
      }

      .widget-label > label {
        font-size: 1.1rem;
      }

      .widget-mpris-player {
        padding: 8px;
        margin: 8px;
        background-color: @background;
        border: 2px solid @accent;
        color: @foreground;
      }

      .widget-mpris-title {
        font-weight: bold;
        font-size: 1.25rem;
      }

      .widget-mpris-subtitle {
        font-size: 1.1rem;
      }
    '';
  };
}
