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
        border = "#${colorScheme.palette.base02}";
        "border.variant" = "#${colorScheme.palette.base02}";
        "border.focused" = "#${colorScheme.palette.base03}";
        "border.selected" = "#${colorScheme.palette.base03}";
        "border.transparent" = "#00000000";
        "border.disabled" = "#${colorScheme.palette.base02}";

        "elevated_surface.background" = "#${colorScheme.palette.base00}";
        "surface.background" = "#${colorScheme.palette.base00}";
        background = "#${colorScheme.palette.base00}";

        "element.background" = "#${colorScheme.palette.base00}";
        "element.hover" = "#${colorScheme.palette.base01}";
        "element.active" = "#${colorScheme.palette.base02}";
        "element.selected" = "#${colorScheme.palette.base02}";
        "element.disabled" = "#${colorScheme.palette.base00}";

        "drop_target.background" = "#${colorScheme.palette.base02}80";

        "ghost_element.background" = "#00000000";
        "ghost_element.hover" = "#${colorScheme.palette.base01}";
        "ghost_element.active" = "#${colorScheme.palette.base02}";
        "ghost_element.selected" = "#${colorScheme.palette.base02}";
        "ghost_element.disabled" = "#${colorScheme.palette.base00}";

        text = "#${colorScheme.palette.base05}";
        "text.muted" = "#${colorScheme.palette.base04}";
        "text.placeholder" = "#${colorScheme.palette.base03}";
        "text.disabled" = "#${colorScheme.palette.base03}";
        "text.accent" = "#${colorScheme.palette.base0D}";

        icon = "#${colorScheme.palette.base05}";
        "icon.muted" = "#${colorScheme.palette.base04}";
        "icon.disabled" = "#${colorScheme.palette.base03}";
        "icon.placeholder" = "#${colorScheme.palette.base03}";
        "icon.accent" = "#${colorScheme.palette.base0D}";

        "status_bar.background" = "#${colorScheme.palette.base00}";
        "title_bar.background" = "#${colorScheme.palette.base00}";
        "title_bar.inactive_background" = "#${colorScheme.palette.base00}";
        "toolbar.background" = "#${colorScheme.palette.base00}";
        "tab_bar.background" = "#${colorScheme.palette.base00}";

        "tab.inactive_background" = "#${colorScheme.palette.base00}";
        "tab.active_background" = "#${colorScheme.palette.base01}";

        "search.match_background" = "#${colorScheme.palette.base0A}66";
        "search.active_match_background" = "#${colorScheme.palette.base09}66";

        "panel.background" = "#${colorScheme.palette.base00}";
        "panel.focused_border" = "#${colorScheme.palette.base03}";
        "pane.focused_border" = "#${colorScheme.palette.base03}";

        "scrollbar.thumb.background" = "#${colorScheme.palette.base02}4c";
        "scrollbar.thumb.hover_background" = "#${colorScheme.palette.base02}";
        "scrollbar.thumb.border" = "#${colorScheme.palette.base02}";
        "scrollbar.track.background" = "#${colorScheme.palette.base00}";
        "scrollbar.track.border" = "#${colorScheme.palette.base01}";

        "editor.foreground" = "#${colorScheme.palette.base05}";
        "editor.background" = "#${colorScheme.palette.base00}";
        "editor.gutter.background" = "#${colorScheme.palette.base00}";
        "editor.subheader.background" = "#${colorScheme.palette.base01}";
        "editor.active_line.background" = "#${colorScheme.palette.base01}";
        "editor.highlighted_line.background" = "#${colorScheme.palette.base01}";

        "editor.line_number" = "#${colorScheme.palette.base03}";
        "editor.active_line_number" = "#${colorScheme.palette.base05}";
        "editor.hover_line_number" = "#${colorScheme.palette.base04}";
        "editor.invisible" = "#${colorScheme.palette.base03}";
        "editor.wrap_guide" = "#${colorScheme.palette.base01}";
        "editor.active_wrap_guide" = "#${colorScheme.palette.base02}";

        "editor.document_highlight.read_background" = "#${colorScheme.palette.base02}";
        "editor.document_highlight.write_background" = "#${colorScheme.palette.base02}";

        "terminal.background" = "#${colorScheme.palette.base00}";
        "terminal.foreground" = "#${colorScheme.palette.base05}";
        "terminal.bright_foreground" = "#${colorScheme.palette.base06}";
        "terminal.dim_foreground" = "#${colorScheme.palette.base03}";
        "terminal.ansi.black" = "#${colorScheme.palette.base00}";
        "terminal.ansi.bright_black" = "#${colorScheme.palette.base03}";
        "terminal.ansi.dim_black" = "#${colorScheme.palette.base00}";
        "terminal.ansi.red" = "#${colorScheme.palette.base08}";
        "terminal.ansi.bright_red" = "#${colorScheme.palette.base08}";
        "terminal.ansi.dim_red" = "#${colorScheme.palette.base08}";
        "terminal.ansi.green" = "#${colorScheme.palette.base0B}";
        "terminal.ansi.bright_green" = "#${colorScheme.palette.base0B}";
        "terminal.ansi.dim_green" = "#${colorScheme.palette.base0B}";
        "terminal.ansi.yellow" = "#${colorScheme.palette.base0A}";
        "terminal.ansi.bright_yellow" = "#${colorScheme.palette.base0A}";
        "terminal.ansi.dim_yellow" = "#${colorScheme.palette.base0A}";
        "terminal.ansi.blue" = "#${colorScheme.palette.base0D}";
        "terminal.ansi.bright_blue" = "#${colorScheme.palette.base0D}";
        "terminal.ansi.dim_blue" = "#${colorScheme.palette.base0D}";
        "terminal.ansi.magenta" = "#${colorScheme.palette.base0E}";
        "terminal.ansi.bright_magenta" = "#${colorScheme.palette.base0E}";
        "terminal.ansi.dim_magenta" = "#${colorScheme.palette.base0E}";
        "terminal.ansi.cyan" = "#${colorScheme.palette.base0C}";
        "terminal.ansi.bright_cyan" = "#${colorScheme.palette.base0C}";
        "terminal.ansi.dim_cyan" = "#${colorScheme.palette.base0C}";
        "terminal.ansi.white" = "#${colorScheme.palette.base05}";
        "terminal.ansi.bright_white" = "#${colorScheme.palette.base06}";
        "terminal.ansi.dim_white" = "#${colorScheme.palette.base04}";

        "link_text.hover" = "#${colorScheme.palette.base0D}";

        # Git / Version Control
        "version_control.added" = "#${colorScheme.palette.base0B}";
        "version_control.modified" = "#${colorScheme.palette.base06}";
        "version_control.word_added" = "#${colorScheme.palette.base0B}30";
        "version_control.word_deleted" = "#${colorScheme.palette.base08}30";
        "version_control.deleted" = "#${colorScheme.palette.base08}";
        "version_control.conflict_marker.ours" = "#${colorScheme.palette.base06}30";
        "version_control.conflict_marker.theirs" = "#${colorScheme.palette.base0D}30";

        # Status Colors
        conflict = "#${colorScheme.palette.base0E}";
        "conflict.background" = "#${colorScheme.palette.base0E}1a";
        "conflict.border" = "#${colorScheme.palette.base0E}";

        created = "#${colorScheme.palette.base0B}";
        "created.background" = "#${colorScheme.palette.base0B}1a";
        "created.border" = "#${colorScheme.palette.base0B}";

        deleted = "#${colorScheme.palette.base08}";
        "deleted.background" = "#${colorScheme.palette.base08}1a";
        "deleted.border" = "#${colorScheme.palette.base08}";

        error = "#${colorScheme.palette.base08}";
        "error.background" = "#${colorScheme.palette.base08}1a";
        "error.border" = "#${colorScheme.palette.base08}";

        hidden = "#${colorScheme.palette.base03}";
        "hidden.background" = "#${colorScheme.palette.base03}1a";
        "hidden.border" = "#${colorScheme.palette.base03}";

        hint = "#${colorScheme.palette.base0D}";
        "hint.background" = "#${colorScheme.palette.base0D}1a";
        "hint.border" = "#${colorScheme.palette.base0D}";

        ignored = "#${colorScheme.palette.base03}";
        "ignored.background" = "#${colorScheme.palette.base03}1a";
        "ignored.border" = "#${colorScheme.palette.base03}";

        info = "#${colorScheme.palette.base0D}";
        "info.background" = "#${colorScheme.palette.base0D}1a";
        "info.border" = "#${colorScheme.palette.base0D}";

        modified = "#${colorScheme.palette.base06}";
        "modified.background" = "#${colorScheme.palette.base06}1a";
        "modified.border" = "#${colorScheme.palette.base06}";

        predictive = "#${colorScheme.palette.base03}";
        "predictive.background" = "#${colorScheme.palette.base03}1a";
        "predictive.border" = "#${colorScheme.palette.base03}";

        renamed = "#${colorScheme.palette.base0D}";
        "renamed.background" = "#${colorScheme.palette.base0D}1a";
        "renamed.border" = "#${colorScheme.palette.base0D}";

        success = "#${colorScheme.palette.base0B}";
        "success.background" = "#${colorScheme.palette.base0B}1a";
        "success.border" = "#${colorScheme.palette.base0B}";

        unreachable = "#${colorScheme.palette.base03}";
        "unreachable.background" = "#${colorScheme.palette.base03}1a";
        "unreachable.border" = "#${colorScheme.palette.base03}";

        warning = "#${colorScheme.palette.base0A}";
        "warning.background" = "#${colorScheme.palette.base0A}1a";
        "warning.border" = "#${colorScheme.palette.base0A}";

        players = [
          {
            cursor = "#${colorScheme.palette.base05}";
            background = "#${colorScheme.palette.base05}";
            selection = "#${colorScheme.palette.base05}3d";
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
          embedded = {
            color = "#${colorScheme.palette.base05}";
            font_style = null;
            font_weight = null;
          };
          emphasis = {
            color = "#${colorScheme.palette.base0D}";
            font_style = null;
            font_weight = null;
          };
          "emphasis.strong" = {
            color = "#${colorScheme.palette.base09}";
            font_style = null;
            font_weight = 700;
          };
          enum = {
            color = "#${colorScheme.palette.base09}";
            font_style = null;
            font_weight = null;
          };
          function = {
            color = "#${colorScheme.palette.base0D}";
            font_style = null;
            font_weight = null;
          };
          hint = {
            color = "#${colorScheme.palette.base03}";
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
            color = "#${colorScheme.palette.base0D}";
            font_style = "italic";
            font_weight = null;
          };
          "link_uri" = {
            color = "#${colorScheme.palette.base0C}";
            font_style = null;
            font_weight = null;
          };
          namespace = {
            color = "#${colorScheme.palette.base05}";
            font_style = null;
            font_weight = null;
          };
          number = {
            color = "#${colorScheme.palette.base09}";
            font_style = null;
            font_weight = null;
          };
          operator = {
            color = "#${colorScheme.palette.base0C}";
            font_style = null;
            font_weight = null;
          };
          predictive = {
            color = "#${colorScheme.palette.base03}";
            font_style = "italic";
            font_weight = null;
          };
          preproc = {
            color = "#${colorScheme.palette.base05}";
            font_style = null;
            font_weight = null;
          };
          primary = {
            color = "#${colorScheme.palette.base05}";
            font_style = null;
            font_weight = null;
          };
          property = {
            color = "#${colorScheme.palette.base05}";
            font_style = null;
            font_weight = null;
          };
          punctuation = {
            color = "#${colorScheme.palette.base04}";
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
            color = "#${colorScheme.palette.base08}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.markup" = {
            color = "#${colorScheme.palette.base08}";
            font_style = null;
            font_weight = null;
          };
          "punctuation.special" = {
            color = "#${colorScheme.palette.base08}";
            font_style = null;
            font_weight = null;
          };
          selector = {
            color = "#${colorScheme.palette.base0D}";
            font_style = null;
            font_weight = null;
          };
          "selector.pseudo" = {
            color = "#${colorScheme.palette.base0D}";
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
            color = "#${colorScheme.palette.base0C}";
            font_style = null;
            font_weight = null;
          };
          "string.special.symbol" = {
            color = "#${colorScheme.palette.base0C}";
            font_style = null;
            font_weight = null;
          };
          tag = {
            color = "#${colorScheme.palette.base0D}";
            font_style = null;
            font_weight = null;
          };
          "text.literal" = {
            color = "#${colorScheme.palette.base0B}";
            font_style = null;
            font_weight = null;
          };
          title = {
            color = "#${colorScheme.palette.base0D}";
            font_style = null;
            font_weight = 400;
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
          variant = {
            color = "#${colorScheme.palette.base0D}";
            font_style = null;
            font_weight = null;
          };
        };
      };
    }
  ];
}
