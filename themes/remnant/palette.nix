{
  # Remnant Red theme

  name = "Remnant Red";
  slug = "remnant-red";

  wallpapers = {
    boot = ./boot.png;
    login = ./login.png;
    desktop = ./desktop.png;
  };

  palette = {
    base00 = "#201E1E"; # The main background color of the window
    base01 = "#302E2E"; # Used for status bars, line numbers, or subtle UI elements
    base02 = "#463939"; # Used for text selection or highlighting the current line
    base03 = "#826060"; # Used for comments, non-text characters, and subtle information
    base04 = "#968888"; # Used for status bar text or UI elements that need to contrast with 01
    base05 = "#DBC7C7"; # The main text color
    base06 = "#A80202"; # Rarely used, generally for slight emphasis over standard text
    base07 = "#FDF8F8"; # Used for strictly purely visual backgrounds or very light text
    base08 = "#CC241D"; # Variables, XML Tags, Markup Link Text, Lists
    base09 = "#FE8019"; # Integers, Boolean, Constants, XML Attributes
    base0A = "#FABD2F"; # Classes, Markup Bold, Search Text Background
    base0B = "#A19D17"; # Strings, Inherited Class, Markup Code, Git Diff (Inserted)
    base0C = "#02A7A8"; # Support, Regular Expressions, Escape Characters
    base0D = "#458588"; # Functions, Methods, Attribute IDs, Headings
    base0E = "#B16286"; # Keywords, Storage, Selector, Markup Link URL
    base0F = "#7C6F64"; # Deprecated, Opening/Closing Embedded Language Tags
  };
}
