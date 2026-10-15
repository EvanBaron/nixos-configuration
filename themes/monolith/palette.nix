{
  # Monolith Olive theme

  name = "Monolith Olive";
  slug = "monolith-olive";

  wallpapers = {
    boot = ./boot.png;
    login = ./login.png;
    desktop = ./desktop.png;
  };

  palette = {
    base00 = "#21211D"; # The main background color of the window
    base01 = "#30302E"; # Used for status bars, line numbers, or subtle UI elements
    base02 = "#464539"; # Used for text selection or highlighting the current line
    base03 = "#7A8260"; # Used for comments, non-text characters, and subtle information
    base04 = "#929688"; # Used for status bar text or UI elements that need to contrast with 01
    base05 = "#D7DBC7"; # The main text color
    base06 = "#A19D17"; # Rarely used, generally for slight emphasis over standard text
    base07 = "#FDFDF8"; # Used for strictly purely visual backgrounds or very light text
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
    fgAlt = "#AFB3A2"; # Secondary text: descriptions, sublabels, field labels
    fgMuted = "#939A7C"; # Tertiary text: placeholders, counts, timestamps (not on base02)
    accent = "#A19D17"; # UI accent, as ink or fill (base06 when it already passes)
    borderStrong = "#7A8260"; # Control outlines, 3:1 on base00/base01
    critical = "#EA746F"; # Critical state text and destructive hover
  };
}
