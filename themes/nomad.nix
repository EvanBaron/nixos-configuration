# ============================================================================
# NOMAD THEME - Teal/Sage Color Scheme
# ============================================================================

{
  colors = {
    # ------------------------------------------------------------------------
    # Base Color Palette
    # These are the fundamental colors extracted from the wallpaper
    # ------------------------------------------------------------------------
    background = "#1D2021"; # Dark charcoal base for all backgrounds
    primary = "#009A9B"; # Vibrant teal for accents and focus
    secondary = "#84A698"; # Sage green for secondary elements
    urgent = "#CC241D"; # Standard red for alerts and urgent states

    # ------------------------------------------------------------------------
    # Text Color Mappings
    # Semantic color assignments for different text contexts
    # ------------------------------------------------------------------------
    text = {
      primary = "#009A9B"; # Main text color (vibrant teal)
      secondary = "#84A698"; # Muted text (sage green)
      onPrimary = "#1D2021"; # Dark text on bright teal backgrounds
      onBackground = "#009A9B"; # Bright text on dark backgrounds
    };

    # ------------------------------------------------------------------------
    # Window Border Colors
    # Used for Sway window decorations based on focus state
    # ------------------------------------------------------------------------
    border = {
      focused = "#009A9B"; # Active window borders (vibrant teal)
      inactive = "#84A698"; # Inactive but visible window borders
      unfocused = "#1D2021"; # Completely unfocused windows (blend in)
      urgent = "#CC241D"; # Windows requiring attention (red)
    };

    # ------------------------------------------------------------------------
    # Workspace Indicator Colors
    # Status bar workspace button styling (includes battery info)
    # ------------------------------------------------------------------------
    workspace = {
      focused = {
        background = "#009A9B"; # Current workspace background
        foreground = "#1D2021"; # Current workspace text
      };
      active = {
        background = "#84A698"; # Active but not current workspace
        foreground = "#1D2021"; # Active workspace text
      };
      inactive = {
        background = "#1D2021"; # Inactive workspace background
        foreground = "#84A698"; # Inactive workspace text
      };
      urgent = {
        background = "#CC241D"; # Urgent workspace background
        foreground = "#1D2021"; # Urgent workspace text
      };
    };

    # ------------------------------------------------------------------------
    # Application Launcher Colors
    # wmenu styling to match the overall theme
    # ------------------------------------------------------------------------
    menu = {
      background = "#1D2021"; # Launcher background
      foreground = "#84A698"; # Default text color
      selected = {
        background = "#009A9B"; # Selected item background
        foreground = "#1D2021"; # Selected item text
      };
      highlight = {
        background = "#009A9B"; # Search match highlighting
        foreground = "#1D2021"; # Highlight text color
      };
    };
  };

  # ========================================================================
  # TYPOGRAPHY CONFIGURATION
  # ========================================================================

  fonts = {
    ui = "Fira Code Nerd Font";
    size = 11;
  };

  # ========================================================================
  # THEME METADATA
  # ========================================================================

  name = "Nomad Teal";
  description = "Cool teal and sage theme matching nomad wallpaper";
  author = "Generated from wallpaper color analysis";
  host = "nomad";
}
