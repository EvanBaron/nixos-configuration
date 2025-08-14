# ============================================================================
# GTKGREET DISPLAY MANAGER MODULE
# ============================================================================

{ theme }:
{ pkgs, ... }:

{
  # ========================================================================
  # GREETD SERVICE CONFIGURATION
  # ========================================================================

  # Configure greetd to use gtkgreet with a custom Sway session
  # This creates a minimal Sway environment just for the login screen
  services.greetd = {
    enable = true;
    settings = {
      default_session =
        let
          swayConfig = pkgs.writeText "greetd-sway-config" ''
            # Launch gtkgreet with layer-shell support and custom CSS
            # The -l flag enables layer-shell mode for proper positioning
            # The -s flag specifies our custom CSS theme file
            exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -s /etc/greetd/gtkgreet.css; swaymsg exit"

            # Include the host's wallpaper configuration
            # This ensures the login screen shows the same wallpaper as the desktop
            include /etc/sway/config.d/wallpaper

            # Emergency power controls accessible during login
            # Super+Shift+E opens a power menu for shutdown/reboot
            bindsym Mod4+shift+e exec swaynag -t warning -m 'Power Options' -b 'Poweroff' 'systemctl poweroff' -b 'Reboot' 'systemctl reboot'
          '';
        in
        {
          command = "${pkgs.sway}/bin/sway --config ${swayConfig} --unsupported-gpu";
          user = "greeter";
        };
    };
  };

  # ========================================================================
  # GTKGREET VISUAL THEMING
  # ========================================================================

  environment.etc."greetd/gtkgreet.css".text = ''
    /* ====================================================================
     * GLOBAL STYLES
     * ====================================================================*/

    /* Apply consistent typography across all elements */
    * {
      font-family: "${theme.fonts.ui}";
      font-size: ${toString theme.fonts.size}pt;
    }

    /* ====================================================================
     * MAIN WINDOW
     * ====================================================================*/

    /* Main window background - transparent to show wallpaper */
    window {
      background-color: ${theme.colors.background};
      color: ${theme.colors.text.primary};
    }

    /* ====================================================================
     * LOGIN BOX CONTAINER
     * ====================================================================*/

    /* Central login box with modern rounded design */
    box#main_box {
      background-color: alpha(${theme.colors.background}, 0.9);
      border-radius: 12px;
      padding: 20px;
      border: 2px solid ${theme.colors.secondary};
      /* Subtle shadow for depth */
      box-shadow: 0 8px 32px alpha(${theme.colors.background}, 0.8);
    }

    /* ====================================================================
     * TIME AND DATE DISPLAY
     * ====================================================================*/

    /* Clock display at top of login box */
    label#clock {
      color: ${theme.colors.text.secondary};
      font-size: 14pt;
      font-weight: 500;
      margin-bottom: 10px;
    }

    /* Date display below clock */
    label#date {
      color: ${theme.colors.text.secondary};
      font-size: 12pt;
      margin-bottom: 20px;
      opacity: 0.8;
    }

    /* ====================================================================
     * INPUT FIELDS
     * ====================================================================*/

    /* Username and password input styling */
    entry {
      background-color: alpha(${theme.colors.background}, 0.8);
      color: ${theme.colors.text.primary};
      border: 2px solid ${theme.colors.secondary};
      border-radius: 6px;
      padding: 12px;
      margin: 8px 0;
      min-height: 20px;
      /* Smooth transitions for interactions */
      transition: all 0.2s ease;
    }

    /* Input field focus state with themed glow */
    entry:focus {
      border-color: ${theme.colors.primary};
      background-color: alpha(${theme.colors.background}, 0.9);
      box-shadow: 0 0 10px alpha(${theme.colors.primary}, 0.3);
      outline: none;
    }

    /* Placeholder text styling */
    entry:placeholder {
      color: alpha(${theme.colors.text.secondary}, 0.6);
    }

    /* ====================================================================
     * BUTTONS
     * ====================================================================*/

    /* Primary button styling (Login button) */
    button {
      background-color: ${theme.colors.primary};
      color: ${theme.colors.background};
      border: none;
      border-radius: 8px;
      padding: 12px 24px;
      margin: 8px 4px;
      font-weight: 600;
      min-height: 20px;
      /* Smooth hover transitions */
      transition: all 0.2s ease;
    }

    /* Button hover state */
    button:hover {
      background-color: alpha(${theme.colors.primary}, 0.85);
      transform: translateY(-1px);
      box-shadow: 0 4px 12px alpha(${theme.colors.primary}, 0.3);
    }

    /* Button pressed state */
    button:active {
      background-color: alpha(${theme.colors.primary}, 0.7);
      transform: translateY(0px);
      box-shadow: 0 2px 4px alpha(${theme.colors.primary}, 0.2);
    }

    /* Disabled button state */
    button:disabled {
      background-color: alpha(${theme.colors.secondary}, 0.5);
      color: alpha(${theme.colors.text.secondary}, 0.5);
      cursor: not-allowed;
    }

    /* ====================================================================
     * SESSION SELECTION
     * ====================================================================*/

    /* Session dropdown menu */
    combobox {
      background-color: alpha(${theme.colors.background}, 0.8);
      color: ${theme.colors.text.primary};
      border: 2px solid ${theme.colors.secondary};
      border-radius: 6px;
      padding: 8px;
      margin: 4px 0;
      transition: all 0.2s ease;
    }

    /* Combobox focus state */
    combobox:focus {
      border-color: ${theme.colors.primary};
      box-shadow: 0 0 5px alpha(${theme.colors.primary}, 0.3);
      outline: none;
    }

    /* Dropdown arrow styling */
    combobox arrow {
      color: ${theme.colors.text.secondary};
      min-height: 16px;
      min-width: 16px;
    }

    /* Dropdown menu items */
    combobox menu {
      background-color: ${theme.colors.background};
      border: 1px solid ${theme.colors.secondary};
      border-radius: 4px;
    }

    combobox menuitem {
      padding: 8px 12px;
      color: ${theme.colors.text.primary};
    }

    combobox menuitem:hover {
      background-color: alpha(${theme.colors.primary}, 0.1);
      color: ${theme.colors.primary};
    }

    /* ====================================================================
     * LABELS AND TEXT
     * ====================================================================*/

    /* General label styling */
    label {
      color: ${theme.colors.text.primary};
      margin: 4px 0;
    }

    /* Welcome greeting text */
    label#greeting {
      color: ${theme.colors.primary};
      font-size: 18pt;
      font-weight: 700;
      margin-bottom: 20px;
      text-align: center;
    }

    /* Error message styling */
    label#error {
      color: ${theme.colors.urgent};
      font-weight: 600;
      margin: 8px 0;
      padding: 8px;
      background-color: alpha(${theme.colors.urgent}, 0.1);
      border-radius: 4px;
    }

    /* ====================================================================
     * RESPONSIVE DESIGN
     * ====================================================================*/

    /* Ensure login box adapts to different screen sizes */
    @media (max-width: 768px) {
      box#main_box {
        margin: 20px;
        padding: 16px;
      }

      label#greeting {
        font-size: 16pt;
      }

      button {
        padding: 10px 20px;
      }
    }
  '';

  # ========================================================================
  # SESSION CONFIGURATION
  # ========================================================================

  environment.etc."greetd/environments".text = ''
    sway
    bash
    zsh
  '';

  # ========================================================================
  # SECURITY CONFIGURATION
  # ========================================================================

  users.users.greeter = {
    isSystemUser = true;
    group = "greeter";
    home = "/var/lib/greeter";
    createHome = false;
  };

  users.groups.greeter = {

  };
}
