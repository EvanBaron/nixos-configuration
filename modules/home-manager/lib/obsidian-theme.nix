{ lib }:

{
  hexToRgb =
    hex:
    let
      r = builtins.substring 0 2 hex;
      g = builtins.substring 2 2 hex;
      b = builtins.substring 4 2 hex;

      toDecimal =
        h:
        let
          chars = lib.strings.stringToCharacters h;
          values = map (
            c:
            if c == "0" then
              0
            else if c == "1" then
              1
            else if c == "2" then
              2
            else if c == "3" then
              3
            else if c == "4" then
              4
            else if c == "5" then
              5
            else if c == "6" then
              6
            else if c == "7" then
              7
            else if c == "8" then
              8
            else if c == "9" then
              9
            else if c == "a" || c == "A" then
              10
            else if c == "b" || c == "B" then
              11
            else if c == "c" || c == "C" then
              12
            else if c == "d" || c == "D" then
              13
            else if c == "e" || c == "E" then
              14
            else
              15
          ) chars;
        in
        builtins.elemAt values 0 * 16 + builtins.elemAt values 1;
    in
    "${toString (toDecimal r)},${toString (toDecimal g)},${toString (toDecimal b)}";

  # Generate complete Obsidian theme CSS from color palette
  generateThemeCSS = colors: hexToRgb: ''
    :root
    {
        /* Background colors - dark shades */
        --dark0-hard_x:     ${hexToRgb colors.base00};
        --dark0-hard:       #${colors.base00};
        --dark0_x:          ${hexToRgb colors.base00};
        --dark0:            #${colors.base00};
        --dark0-soft_x:     ${hexToRgb colors.base01};
        --dark0-soft:       #${colors.base01};
        --dark1_x:          ${hexToRgb colors.base01};
        --dark1:            #${colors.base01};
        --dark2_x:          ${hexToRgb colors.base02};
        --dark2:            #${colors.base02};
        --dark3_x:          ${hexToRgb colors.base03};
        --dark3:            #${colors.base03};
        --dark4_x:          ${hexToRgb colors.base0F};
        --dark4:            #${colors.base0F};
        --gray_x:           ${hexToRgb colors.base04};
        --gray:             #${colors.base04};

        /* Foreground colors - light shades */
        --light0-hard_x:    ${hexToRgb colors.base07};
        --light0-hard:      #${colors.base07};
        --light0_x:         ${hexToRgb colors.base05};
        --light0:           #${colors.base05};
        --light0-soft_x:    ${hexToRgb colors.base05};
        --light0-soft:      #${colors.base05};
        --light1_x:         ${hexToRgb colors.base05};
        --light1:           #${colors.base05};
        --light2_x:         ${hexToRgb colors.base04};
        --light2:           #${colors.base04};
        --light3_x:         ${hexToRgb colors.base03};
        --light3:           #${colors.base03};
        --light4_x:         ${hexToRgb colors.base04};
        --light4:           #${colors.base04};

        /* Bright accent colors */
        --bright-red_x:     ${hexToRgb colors.base08};
        --bright-red:       #${colors.base08};
        --bright-green_x:   ${hexToRgb colors.base0B};
        --bright-green:     #${colors.base0B};
        --bright-yellow_x:  ${hexToRgb colors.base0A};
        --bright-yellow:    #${colors.base0A};
        --bright-blue_x:    ${hexToRgb colors.base0D};
        --bright-blue:      #${colors.base0D};
        --bright-purple_x:  ${hexToRgb colors.base0E};
        --bright-purple:    #${colors.base0E};
        --bright-aqua_x:    ${hexToRgb colors.base06};
        --bright-aqua:      #${colors.base06};
        --bright-orange_x:  ${hexToRgb colors.base09};
        --bright-orange:    #${colors.base09};

        /* Neutral accent colors */
        --neutral-red_x:    ${hexToRgb colors.base08};
        --neutral-red:      #${colors.base08};
        --neutral-green_x:  ${hexToRgb colors.base0B};
        --neutral-green:    #${colors.base0B};
        --neutral-yellow_x: ${hexToRgb colors.base0A};
        --neutral-yellow:   #${colors.base0A};
        --neutral-blue_x:   ${hexToRgb colors.base0D};
        --neutral-blue:     #${colors.base0D};
        --neutral-purple_x: ${hexToRgb colors.base0E};
        --neutral-purple:   #${colors.base0E};
        --neutral-aqua_x:   ${hexToRgb colors.base06};
        --neutral-aqua:     #${colors.base06};
        --neutral-orange_x: ${hexToRgb colors.base09};
        --neutral-orange:   #${colors.base09};

        /* Faded accent colors */
        --faded-red_x:      ${hexToRgb colors.base08};
        --faded-red:        #${colors.base08};
        --faded-green_x:    ${hexToRgb colors.base0B};
        --faded-green:      #${colors.base0B};
        --faded-yellow_x:   ${hexToRgb colors.base0A};
        --faded-yellow:     #${colors.base0A};
        --faded-blue_x:     ${hexToRgb colors.base0D};
        --faded-blue:       #${colors.base0D};
        --faded-purple_x:   ${hexToRgb colors.base0E};
        --faded-purple:     #${colors.base0E};
        --faded-aqua_x:     ${hexToRgb colors.base0C};
        --faded-aqua:       #${colors.base0C};
        --faded-orange_x:   ${hexToRgb colors.base09};
        --faded-orange:     #${colors.base09};
    }

    body
    {
        --link-decoration:                none;
        --link-decoration-hover:          none;
        --link-external-decoration:       none;
        --link-external-decoration-hover: none;

        --tag-decoration:                 none;
        --tag-decoration-hover:           underline;
        --tag-padding-x:                  .5em;
        --tag-padding-y:                  .2em;
        --tag-radius:                     .5em;

        --tab-font-weight:                600;
        --bold-weight:                    600;

        --checkbox-radius:                0;

        --embed-border-left: 6px double var(--interactive-accent);
    }

    .theme-dark
    {
        --color-red-rgb:                 var(--neutral-red_x);
        --color-red:                     var(--neutral-red);
        --color-purple-rgb:              var(--neutral-purple_x);
        --color-purple:                  var(--neutral-purple);
        --color-green-rgb:               var(--neutral-green_x);
        --color-green:                   var(--neutral-green);
        --color-cyan-rgb:                var(--neutral-aqua_x);
        --color-cyan:                    var(--neutral-aqua);
        --color-blue-rgb:                var(--neutral-blue_x);
        --color-blue:                    var(--neutral-blue);
        --color-yellow-rgb:              var(--neutral-yellow_x);
        --color-yellow:                  var(--neutral-yellow);
        --color-orange-rgb:              var(--neutral-orange_x);
        --color-orange:                  var(--neutral-orange);
        --color-pink-rgb:                var(--bright-purple_x);
        --color-pink:                    var(--bright-purple);

        --background-primary:            var(--dark0);
        --background-primary-alt:        var(--dark0);
        --background-secondary:          var(--dark0-hard);
        --background-secondary-alt:      var(--dark1);
        --background-modifier-border:    var(--dark1);

        --cursor-line-background:        rgba(var(--dark1_x), 0.5);

        --text-normal:                   var(--light0);
        --text-faint:                    var(--light1);
        --text-muted:                    var(--light2);

        --link-url:                      var(--neutral-aqua);

        --h1-color:                      var(--neutral-red);
        --h2-color:                      var(--neutral-yellow);
        --h3-color:                      var(--neutral-green);
        --h4-color:                      var(--neutral-aqua);
        --h5-color:                      var(--neutral-blue);
        --h6-color:                      var(--neutral-purple);

        --text-highlight-bg:             var(--neutral-yellow);
        --text-highlight-fg:             var(--dark0-hard);

        --text-accent:                   var(--neutral-aqua);
        --text-accent-hover:             var(--bright-aqua);

        --tag-color:                     var(--bright-aqua);
        --tag-background:                var(--dark2);
        --tag-background-hover:          var(--dark1);

        --titlebar-text-color-focused:   var(--bright-aqua);

        --inline-title-color:            var(--bright-yellow);

        --bold-color:                    var(--neutral-yellow);
        --italic-color:                  var(--neutral-yellow);

        --checkbox-color:                var(--light4);
        --checkbox-color-hover:          var(--light4);
        --checkbox-border-color:         var(--light4);
        --checkbox-border-color-hover:   var(--light4);
        --checklist-done-color:          rgba(var(--light2_x), 0.5);

        --table-header-background:       rgba(var(--dark0_x), 0.2);
        --table-header-background-hover: var(--dark2);
        --table-row-even-background:     rgba(var(--dark2_x), 0.2);
        --table-row-odd-background:      rgba(var(--dark2_x), 0.4);
        --table-row-background-hover:    var(--dark2);

        --text-selection:                rgba(var(--neutral-aqua_x), 0.4);
        --flashing-background:           rgba(var(--neutral-aqua_x), 0.3);

        --code-normal:                   var(--bright-blue);
        --code-background:               var(--dark1);

        --mermaid-note:                  var(--neutral-blue);
        --mermaid-actor:                 var(--dark2);
        --mermaid-loopline:              var(--neutral-blue);
        --mermaid-exclude:               var(--dark4);
        --mermaid-seqnum:                var(--dark0);

        --icon-color-hover:              var(--bright-aqua);
        --icon-color-focused:            var(--bright-blue);

        --nav-item-color-hover:          var(--bright-aqua);
        --nav-item-color-active:         var(--bright-aqua);
        --nav-file-tag:                  rgba(var(--neutral-yellow_x), 0.9);

        --graph-line:                    var(--dark2);
        --graph-node:                    var(--light3);
        --graph-node-tag:                var(--neutral-red);
        --graph-node-attachment:         var(--neutral-green);

        --calendar-hover:                var(--bright-aqua);
        --calendar-background-hover:     var(--dark1);
        --calendar-week:                 var(--neutral-orange);
        --calendar-today:                var(--neutral-aqua);

        --dataview-key:                  var(--text-faint);
        --dataview-key-background:       rgba(var(--faded-aqua_x), 0.5);
        --dataview-value:                var(--text-faint);
        --dataview-value-background:     rgba(var(--neutral-green_x), 0.3);

        --tab-text-color-focused-active:         var(--neutral-yellow);
        --tab-text-color-focused-active-current: var(--bright-aqua);
    }

    .theme-light
    {
        --color-red-rgb:                 var(--neutral-red_x);
        --color-red:                     var(--neutral-red);
        --color-purple-rgb:              var(--neutral-purple_x);
        --color-purple:                  var(--neutral-purple);
        --color-green-rgb:               var(--neutral-green_x);
        --color-green:                   var(--neutral-green);
        --color-cyan-rgb:                var(--neutral-aqua_x);
        --color-cyan:                    var(--neutral-aqua);
        --color-blue-rgb:                var(--neutral-blue_x);
        --color-blue:                    var(--neutral-blue);
        --color-yellow-rgb:              var(--neutral-yellow_x);
        --color-yellow:                  var(--neutral-yellow);
        --color-orange-rgb:              var(--neutral-orange_x);
        --color-orange:                  var(--neutral-orange);
        --color-pink-rgb:                var(--bright-purple_x);
        --color-pink:                    var(--bright-purple);

        --background-primary:            var(--light0-hard);
        --background-primary-alt:        var(--light0-hard);
        --background-secondary:          var(--light1);
        --background-secondary-alt:      var(--light1);
        --background-modifier-border:    var(--light2);

        --cursor-line-background:        rgba(var(--light1_x), 0.5);

        --text-normal:                   var(--dark0);
        --text-faint:                    var(--dark3);
        --text-muted:                    var(--dark2);

        --link-url:                      var(--neutral-aqua);

        --h1-color:                      var(--neutral-red);
        --h2-color:                      var(--neutral-yellow);
        --h3-color:                      var(--neutral-green);
        --h4-color:                      var(--neutral-aqua);
        --h5-color:                      var(--neutral-blue);
        --h6-color:                      var(--neutral-purple);

        --text-highlight-bg:             var(--neutral-yellow);
        --text-highlight-fg:             var(--light0-hard);

        --text-accent:                   var(--neutral-aqua);
        --text-accent-hover:             var(--bright-aqua);

        --tag-color:                     var(--bright-aqua);
        --tag-background:                var(--light2);
        --tag-background-hover:          var(--light1);

        --titlebar-text-color-focused:   var(--bright-aqua);

        --inline-title-color:            var(--bright-yellow);

        --bold-color:                    var(--neutral-yellow);
        --italic-color:                  var(--neutral-yellow);

        --checkbox-color:                var(--dark4);
        --checkbox-color-hover:          var(--dark4);
        --checkbox-border-color:         var(--dark4);
        --checkbox-border-color-hover:   var(--dark4);
        --checklist-done-color:          rgba(var(--dark2_x), 0.5);

        --table-header-background:       rgba(var(--light0_x), 0.2);
        --table-header-background-hover: var(--light2);
        --table-row-even-background:     rgba(var(--light2_x), 0.2);
        --table-row-odd-background:      rgba(var(--light2_x), 0.4);
        --table-row-background-hover:    var(--light2);

        --text-selection:                rgba(var(--neutral-aqua_x), 0.4);
        --flashing-background:           rgba(var(--neutral-aqua_x), 0.3);

        --code-normal:                   var(--bright-blue);
        --code-background:               var(--light1);

        --mermaid-note:                  var(--neutral-blue);
        --mermaid-actor:                 var(--light2);
        --mermaid-loopline:              var(--neutral-blue);
        --mermaid-exclude:               var(--light4);
        --mermaid-seqnum:                var(--light0);

        --icon-color-hover:              var(--bright-aqua);
        --icon-color-focused:            var(--bright-blue);

        --nav-item-color-hover:          var(--bright-aqua);
        --nav-item-color-active:         var(--bright-aqua);
        --nav-file-tag:                  rgba(var(--neutral-yellow_x), 0.9);

        --graph-line:                    var(--light2);
        --graph-node:                    var(--dark3);
        --graph-node-tag:                var(--neutral-red);
        --graph-node-attachment:         var(--neutral-green);

        --calendar-hover:                var(--bright-aqua);
        --calendar-background-hover:     var(--light1);
        --calendar-week:                 var(--neutral-orange);
        --calendar-today:                var(--neutral-aqua);

        --dataview-key:                  var(--text-faint);
        --dataview-key-background:       rgba(var(--faded-aqua_x), 0.5);
        --dataview-value:                var(--text-faint);
        --dataview-value-background:     rgba(var(--neutral-green_x), 0.3);

        --tab-text-color-focused-active:         var(--neutral-yellow);
        --tab-text-color-focused-active-current: var(--bright-aqua);
    }

    /* Table styling */
    thead { border-bottom: 2px solid var(--background-modifier-border) !important; }
    th { font-weight: 600 !important; border: 1px solid var(--background-secondary) !important; }
    td {
        border-left: 1px solid var(--background-secondary) !important;
        border-right: 1px solid var(--background-secondary) !important;
        border-bottom: 1px solid var(--background-secondary) !important;
    }
    .markdown-rendered tbody tr:nth-child(even) { background-color: var(--table-row-even-background) !important; }
    .markdown-rendered tbody tr:nth-child(odd) { background-color: var(--table-row-odd-background) !important; }
    .markdown-rendered tbody tr:nth-child(even):hover,
    .markdown-rendered tbody tr:nth-child(odd):hover { background-color: var(--table-row-background-hover) !important; }

    /* Text highlighting */
    .markdown-rendered mark {
        background-color: var(--text-highlight-bg);
        color: var(--text-highlight-fg);
    }
    .markdown-rendered mark a { color: var(--red) !important; font-weight: 600; }
    .search-result-file-matched-text { color: var(--text-highlight-fg) !important; }

    /* Tags and hashtags */
    .cm-hashtag-begin:hover, .cm-hashtag-end:hover {
        color: var(--text-accent);
        text-decoration: underline;
    }

    /* Checkboxes */
    input[type=checkbox] { border: 1px solid var(--checkbox-color); }
    input[type=checkbox]:checked {
        background-color: var(--checkbox-color);
        box-shadow: inset 0 0 0 2px var(--background-primary);
    }
    input[type=checkbox]:checked:after { display: none; }

    /* Code blocks */
    code[class*="language-"], pre[class*="language-"] { line-height: var(--line-height-tight) !important; }
    .cm-url { color: var(--link-url) !important; }
    .cm-url:hover { color: var(--text-accent-color) !important; }
    .cm-highlight { color: var(--text-highlight-fg) !important; }
    .cm-inline-code {
        border-radius: var(--radius-s);
        font-size: var(--code-size);
        padding: 0.1em 0.25em;
    }
    .cm-line .cm-strong { color: var(--bold-color) !important; }

    /* Mermaid diagrams */
    .mermaid .note { fill: var(--mermaid-note) !important; }
    .mermaid .actor { fill: var(--mermaid-actor) !important; }
    .mermaid .loopLine { stroke: var(--mermaid-loopline) !important; }
    .mermaid .loopText>tspan, .mermaid .entityLabel { fill: var(--neutral-red) !important; }
    .mermaid .exclude-range { fill: var(--mermaid-exclude) !important; }
    .mermaid .sequenceNumber { fill: var(--mermaid-seqnum) !important; }

    /* Calendar */
    .calendar .week-num { color: var(--calendar-week) !important; }
    .calendar .today { color: var(--calendar-today) !important; }
    .calendar .week-num:hover, .calendar .day:hover {
        color: var(--calendar-hover) !important;
        background-color: var(--calendar-background-hover) !important;
    }

    /* Misc */
    .markdown-embed-title { color: var(--yellow); font-weight: 600 !important; }
    .cm-active { background-color: var(--cursor-line-background) !important; }
    .nav-file-tag { color: var(--nav-file-tag) !important; }
    .is-flashing { background-color: var(--flashing-background) !important; }

    /* Dataview plugin */
    .dataview.inline-field-key {
        border-top-left-radius: var(--radius-s);
        border-bottom-left-radius: var(--radius-s);
        padding-left: 4px;
        font-family: var(--font-monospace);
        font-size: var(--font-smaller);
        color: var(--dataview-key) !important;
        background-color: var(--dataview-key-background) !important;
    }
    .dataview.inline-field-value {
        border-top-right-radius: var(--radius-s);
        border-bottom-right-radius: var(--radius-s);
        padding-right: 4px;
        font-family: var(--font-monospace);
        font-size: var(--font-smaller);
        color: var(--dataview-value) !important;
        background-color: var(--dataview-value-background) !important;
    }

    .suggestion-highlight { color: var(--bright-aqua); }

    /* Callouts */
    body {
        --callout-border-width: 1px;
        --callout-border-opacity: 0.4;
        --callout-default: var(--neutral-blue_x);
        --callout-note: var(--neutral-blue_x);
        --callout-summary: var(--neutral-aqua_x);
        --callout-info: var(--neutral-blue_x);
        --callout-todo: var(--neutral-blue_x);
        --callout-important: var(--neutral-aqua_x);
        --callout-tip: var(--neutral-aqua_x);
        --callout-success: var(--neutral-green_x);
        --callout-question: var(--neutral-yellow_x);
        --callout-warning: var(--neutral-orange_x);
        --callout-fail: var(--neutral-red_x);
        --callout-error: var(--neutral-red_x);
        --callout-bug: var(--neutral-red_x);
        --callout-example: var(--neutral-purple_x);
        --callout-quote: var(--gray_x);
    }
    .callout { background-color: rgba(var(--callout-color), 0.2); }
  '';
}
