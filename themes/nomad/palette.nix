{
  # Nomad Teal theme

  name = "Nomad Teal";
  slug = "nomad-teal";

  wallpapers = {
    boot = ./boot.png;
    login = ./login.png;
    desktop = ./desktop.png;
  };

  palette = {
    base00 = "#1D2021"; # The main background color of the window
    base01 = "#2C3132"; # Used for status bars, line numbers, or subtle UI elements
    base02 = "#394546"; # Used for text selection or highlighting the current line
    base03 = "#607E82"; # Used for comments, non-text characters, and subtle information
    base04 = "#889396"; # Used for status bar text or UI elements that need to contrast with 01
    base05 = "#C7D6DB"; # The main text color
    base06 = "#02A7A8"; # Rarely used, generally for slight emphasis over standard text
    base07 = "#F8FDFD"; # Used for strictly purely visual backgrounds or very light text
    base08 = "#CC241D"; # Variables, XML Tags, Markup Link Text, Lists
    base09 = "#FE8019"; # Integers, Boolean, Constants, XML Attributes
    base0A = "#FABD2F"; # Classes, Markup Bold, Search Text Background
    base0B = "#A19D17"; # Strings, Inherited Class, Markup Code, Git Diff (Inserted)
    base0C = "#02A7A8"; # Support, Regular Expressions, Escape Characters
    base0D = "#458588"; # Functions, Methods, Attribute IDs, Headings
    base0E = "#B16286"; # Keywords, Storage, Selector, Markup Link URL
    base0F = "#7C6F64"; # Deprecated, Opening/Closing Embedded Language Tags
  };

  # UI roles derived from the palette so every text colour holds WCAG AA (4.5:1)
  # on base00, base01 and base02. See the "NixOS Desktop" design system.
  ui = {
    fgAlt = "#A4B1B5"; # Secondary text: descriptions, sublabels, field labels
    fgMuted = "#839CA0"; # Tertiary text: placeholders, counts, timestamps (not on base02)
    accent = "#02A7A8"; # UI accent, as ink or fill (base06 when it already passes)
    borderStrong = "#607E82"; # Control outlines, 3:1 on base00/base01
    critical = "#EA746F"; # Critical state text and destructive hover
  };
}
