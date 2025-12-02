{
  config,
  ...
}:

{
  programs.zen-browser = {
    enable = true;
    profiles.default.settings = {
      "devtools.debugger.remote-enabled" = true;
      "devtools.chrome.enabled" = true;
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    };
  };

  home.file.".zen/default/chrome/userChrome.css" = {
    text = ''
      :root {
        --bg: #${config.colorScheme.palette.base00};
        --fg: #${config.colorScheme.palette.base05};
        --ui-bg: #${config.colorScheme.palette.base01};
        --ui-fg: #${config.colorScheme.palette.base05};
        --sel-bg: #${config.colorScheme.palette.base02};
        --sel-fg: #${config.colorScheme.palette.base05};
        --red: #${config.colorScheme.palette.base08};
        --orange: #${config.colorScheme.palette.base09};
        --yellow: #${config.colorScheme.palette.base0A};
        --green: #${config.colorScheme.palette.base0B};
        --cyan: #${config.colorScheme.palette.base0C};
        --blue: #${config.colorScheme.palette.base0D};
        --magenta: #${config.colorScheme.palette.base0E};
        --brown: #${config.colorScheme.palette.base0F};
      }

      /* General UI */
      :root, window, #main-window, #navigator-toolbox {
        background-color: var(--bg) !important;
        color: var(--fg) !important;
      }

      /* Tabs */
      .tab-background {
        background-color: var(--ui-bg) !important;
      }
      .tab-background[selected="true"] {
        background-color: var(--sel-bg) !important;
      }
      .tab-text {
        color: var(--ui-fg) !important;
      }

      /* URL Bar */
      #urlbar, #searchbar {
        background-color: var(--ui-bg) !important;
        color: var(--ui-fg) !important;
        border: 1px solid var(--sel-bg) !important;
      }
      #urlbar[focused="true"], #searchbar[focused="true"] {
        border: 1px solid var(--sel-bg) !important;
      }

      /* Sidebar */
      #sidebar-box {
        background-color: var(--ui-bg) !important;
        color: var(--ui-fg) !important;
      }

      /* Scrollbars */
      scrollbar {
        -moz-appearance: none !important;
        background-color: var(--bg) !important;
        width: 10px !important;
      }
      thumb {
        -moz-appearance: none !important;
        background-color: var(--ui-bg) !important;
        border-radius: 5px !important;
      }
      thumb:hover {
        background-color: var(--sel-bg) !important;
      }

      /* Context Menus */
      menupopup, .menupopup-arrowscrollbox {
        -moz-appearance: none !important;
        background-color: var(--ui-bg) !important;
        color: var(--ui-fg) !important;
        border: 1px solid var(--sel-bg) !important;
      }
      menuitem, menu {
        -moz-appearance: none !important;
        color: var(--ui-fg) !important;
      }
      menuitem:hover, menu:hover {
        background-color: var(--sel-bg) !important;
      }

      /* Find Bar */
      .findbar-textbox {
        background-color: var(--ui-bg) !important;
        color: var(--ui-fg) !important;
      }
      .findbar-textbox:focus {
        border-color: var(--sel-bg) !important;
      }

      #sidebar-box,
      .sidebar-splitter,
      #appcontent,
      #tabbrowser-tabbox,
      browser[type="content-primary"],
      browser[type="content"] > html {
        border: none !important;
        box-shadow: none !important;
      }
    '';
  };
}
