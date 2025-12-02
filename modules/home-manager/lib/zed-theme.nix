{ colorScheme, username }:

builtins.toJSON {
  name = colorScheme.name;
  author = username;
  themes = [
    {
      name = colorScheme.name;
      appearance = "dark";
      style = {
        # UI Colors
        background = "#${colorScheme.palette.base00}";
        border = "#${colorScheme.palette.base02}";
        elevated_surface.background = "#${colorScheme.palette.base00}";
        surface.background = "#${colorScheme.palette.base00}";
        element.background = "#${colorScheme.palette.base01}";
        element.hover = "#${colorScheme.palette.base02}";
        element.active = null;
        element.selected = "#${colorScheme.palette.base02}";
        element.disabled = null;
        drop_target.background = "#${colorScheme.palette.base02}";
        ghost_element.background = null;
        ghost_element.hover = "#${colorScheme.palette.base01}";
        ghost_element.active = null;
        ghost_element.selected = "#${colorScheme.palette.base02}";
        ghost_element.disabled = null;
        text = "#${colorScheme.palette.base05}";
        status_bar.background = "#${colorScheme.palette.base00}";
        title_bar.background = "#${colorScheme.palette.base00}";
        toolbar.background = "#${colorScheme.palette.base00}";
        tab_bar.background = "#${colorScheme.palette.base00}";
        tab.inactive_background = "#${colorScheme.palette.base01}";
        tab.active_background = "#${colorScheme.palette.base00}";
        search.match_background = "#${colorScheme.palette.base02}";
        panel.background = "#${colorScheme.palette.base00}";
        panel.focused_border = "#${colorScheme.palette.base02}";
        pane.focused_border = null;
        scrollbar.thumb.background = "#${colorScheme.palette.base02}";
        scrollbar.thumb.hover_background = "#${colorScheme.palette.base03}";
        scrollbar.thumb.border = "#${colorScheme.palette.base02}6f";
        scrollbar.track.background = "#${colorScheme.palette.base00}";
        scrollbar.track.border = null;
        editor.foreground = "#${colorScheme.palette.base05}";
        editor.background = "#${colorScheme.palette.base00}";
        editor.gutter.background = "#${colorScheme.palette.base00}";
        editor.subheader.background = "#${colorScheme.palette.base00}";
        editor.active_line.background = "#${colorScheme.palette.base01}";
        editor.highlighted_line.background = null;
        editor.line_number = "#${colorScheme.palette.base03}";
        editor.active_line_number = "#${colorScheme.palette.base06}";
        editor.invisible = null;
        editor.wrap_guide = "#${colorScheme.palette.base01}";
        editor.active_wrap_guide = "#${colorScheme.palette.base03}";
        editor.document_highlight.read_background = "#${colorScheme.palette.base01}";
        editor.document_highlight.write_background = "#${colorScheme.palette.base01}";
        terminal.background = "#${colorScheme.palette.base00}";
        terminal.foreground = null;
        terminal.bright_foreground = null;
        terminal.dim_foreground = null;
        terminal.ansi.black = "#${colorScheme.palette.base00}";
        terminal.ansi.bright_black = "#${colorScheme.palette.base03}";
        terminal.ansi.dim_black = null;
        terminal.ansi.red = "#${colorScheme.palette.base08}";
        terminal.ansi.bright_red = "#${colorScheme.palette.base08}";
        terminal.ansi.dim_red = null;
        terminal.ansi.green = "#${colorScheme.palette.base0B}";
        terminal.ansi.bright_green = "#${colorScheme.palette.base0B}";
        terminal.ansi.dim_green = null;
        terminal.ansi.yellow = "#${colorScheme.palette.base0A}";
        terminal.ansi.bright_yellow = "#${colorScheme.palette.base0A}";
        terminal.ansi.dim_yellow = null;
        terminal.ansi.blue = "#${colorScheme.palette.base0D}";
        terminal.ansi.bright_blue = "#${colorScheme.palette.base0D}";
        terminal.ansi.dim_blue = null;
        terminal.ansi.magenta = "#${colorScheme.palette.base0E}";
        terminal.ansi.bright_magenta = "#${colorScheme.palette.base0E}";
        terminal.ansi.dim_magenta = null;
        terminal.ansi.cyan = "#${colorScheme.palette.base0C}";
        terminal.ansi.bright_cyan = "#${colorScheme.palette.base0C}";
        terminal.ansi.dim_cyan = null;
        terminal.ansi.white = "#${colorScheme.palette.base05}";
        terminal.ansi.bright_white = "#${colorScheme.palette.base05}";
        terminal.ansi.dim_white = null;
        link_text.hover = "#${colorScheme.palette.base0C}";
        conflict = "#${colorScheme.palette.base0A}";
        created = "#${colorScheme.palette.base0B}";
        deleted = "#${colorScheme.palette.base08}";
        error = "#${colorScheme.palette.base08}";
        hidden = "#${colorScheme.palette.base03}";
        hint = "#${colorScheme.palette.base05}";
        ignored = "#${colorScheme.palette.base03}";
        info = "#${colorScheme.palette.base0C}";
        modified = "#${colorScheme.palette.base06}";
        predictive = "#${colorScheme.palette.base03}";
        renamed = "#${colorScheme.palette.base0A}";
        success = "#${colorScheme.palette.base0B}";
        unreachable = "#${colorScheme.palette.base0A}";
        warning = "#${colorScheme.palette.base0A}";
        players = [
          {
            cursor = "#${colorScheme.palette.base05}";
            selection = "#${colorScheme.palette.base02}";
            background = null;
          }
        ];
        # Syntax Highlighting
        syntax = {
          attribute = {
            color = "#${colorScheme.palette.base0D}";
            font_style = null;
            font_weight = null;
          };
          boolean = {
            color = "#${colorScheme.palette.base09}";
            font_style = null;
            font_weight = null;
          };
          comment = {
            color = "#${colorScheme.palette.base03}";
            font_style = "italic";
            font_weight = null;
          };
          "comment.doc" = {
            color = "#${colorScheme.palette.base03}";
            font_style = "italic";
            font_weight = null;
          };
          constant = {
            color = "#${colorScheme.palette.base09}";
            font_style = null;
            font_weight = null;
          };
          constructor = {
            color = "#${colorScheme.palette.base0D}";
            font_style = null;
            font_weight = null;
          };
          emphasis = {
            color = "#${colorScheme.palette.base08}";
            font_style = "italic";
            font_weight = null;
          };
          "emphasis.strong" = {
            color = "#${colorScheme.palette.base08}";
            font_style = null;
            font_weight = 700;
          };
          function = {
            color = "#${colorScheme.palette.base0D}";
            font_style = null;
            font_weight = null;
          };
          keyword = {
            color = "#${colorScheme.palette.base0E}";
            font_style = null;
            font_weight = null;
          };
          label = {
            color = "#${colorScheme.palette.base0A}";
            font_style = null;
            font_weight = null;
          };
          "link_text" = {
            color = "#${colorScheme.palette.base08}";
            font_style = null;
            font_weight = null;
          };
          "link_uri" = {
            color = "#${colorScheme.palette.base08}";
            font_style = null;
            font_weight = null;
          };
          number = {
            color = "#${colorScheme.palette.base09}";
            font_style = null;
            font_weight = null;
          };
          operator = {
            color = "#${colorScheme.palette.base05}";
            font_style = null;
            font_weight = null;
          };
          punctuation = {
            color = "#${colorScheme.palette.base05}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.bracket" = {
            color = "#${colorScheme.palette.base04}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.delimiter" = {
            color = "#${colorScheme.palette.base05}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.list_marker" = {
            color = "#${colorScheme.palette.base03}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.special" = {
            color = "#${colorScheme.palette.base08}";
            font_style = null;
            font_weight = null;
          };
          string = {
            color = "#${colorScheme.palette.base0B}";
            font_style = null;
            font_weight = null;
          };
          "string.escape" = {
            color = "#${colorScheme.palette.base0C}";
            font_style = null;
            font_weight = null;
          };
          "string.regex" = {
            color = "#${colorScheme.palette.base0C}";
            font_style = null;
            font_weight = null;
          };
          "string.special" = {
            color = "#${colorScheme.palette.base0B}";
            font_style = null;
            font_weight = null;
          };
          "string.special.symbol" = {
            color = "#${colorScheme.palette.base0B}";
            font_style = null;
            font_weight = null;
          };
          tag = {
            color = "#${colorScheme.palette.base08}";
            font_style = null;
            font_weight = null;
          };
          "text.literal" = {
            color = "#${colorScheme.palette.base0B}";
            font_style = null;
            font_weight = null;
          };
          title = {
            color = "#${colorScheme.palette.base0A}";
            font_style = null;
            font_weight = null;
          };
          type = {
            color = "#${colorScheme.palette.base0A}";
            font_style = null;
            font_weight = null;
          };
          variable = {
            color = "#${colorScheme.palette.base05}";
            font_style = null;
            font_weight = null;
          };
          "variable.special" = {
            color = "#${colorScheme.palette.base08}";
            font_style = "italic";
            font_weight = null;
          };
          property = {
            color = "#${colorScheme.palette.base05}";
            font_style = null;
            font_weight = null;
          };
        };
      };
    }
  ];
}
