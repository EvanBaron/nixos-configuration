# ============================================================================
# MONOLITH THEME - Olive/Yellow-Green Color Scheme
# ============================================================================
#

{
  colors = {
    # ------------------------------------------------------------------------
    # Base Color Palette
    # These are the fundamental colors extracted from the wallpaper
    # ------------------------------------------------------------------------
    background = "#1D2021"; # Dark charcoal base for all backgrounds
    primary = "#878313"; # Bright olive green for accents and focus
    secondary = "#4E4A06"; # Darker olive for secondary elements
    urgent = "#CC241D"; # Standard red for alerts and urgent states

    # ------------------------------------------------------------------------
    # Text Color Mappings
    # Semantic color assignments for different text contexts
    # ------------------------------------------------------------------------
    text = {
      primary = "#878313"; # Main text color (bright olive)
      secondary = "#4E4A06"; # Muted text (darker olive)
      onPrimary = "#1D2021"; # Dark text on bright olive backgrounds
      onBackground = "#878313"; # Bright text on dark backgrounds
    };

    # ------------------------------------------------------------------------
    # Window Border Colors
    # Used for Sway window decorations based on focus state
    # ------------------------------------------------------------------------
    border = {
      focused = "#878313"; # Active window borders (bright olive)
      inactive = "#4E4A06"; # Inactive but visible window borders
      unfocused = "#1D2021"; # Completely unfocused windows (blend in)
      urgent = "#CC241D"; # Windows requiring attention (red)
    };

    # ------------------------------------------------------------------------
    # Workspace Indicator Colors
    # Status bar workspace button styling
    # ------------------------------------------------------------------------
    workspace = {
      focused = {
        background = "#878313"; # Current workspace background
        foreground = "#1D2021"; # Current workspace text
      };
      active = {
        background = "#4E4A06"; # Active but not current workspace
        foreground = "#878313"; # Active workspace text
      };
      inactive = {
        background = "#1D2021"; # Inactive workspace background
        foreground = "#4E4A06"; # Inactive workspace text
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
      foreground = "#4E4A06"; # Default text color
      selected = {
        background = "#878313"; # Selected item background
        foreground = "#1D2021"; # Selected item text
      };
      highlight = {
        background = "#878313"; # Search match highlighting
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

  name = "Monolith Olive";
  description = "Warm olive and yellow-green theme matching monolith wallpaper";
  author = "Generated from wallpaper color analysis";
  host = "monolith";
}
