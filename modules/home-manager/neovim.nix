{ config, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPlugins = [ pkgs.vimPlugins.base16-nvim ];

    extraConfigLua = ''
      require('base16-colorscheme').setup({
        base00 = '#${config.colorScheme.palette.base00}',
        base01 = '#${config.colorScheme.palette.base01}',
        base02 = '#${config.colorScheme.palette.base02}',
        base03 = '#${config.colorScheme.palette.base03}',
        base04 = '#${config.colorScheme.palette.base04}',
        base05 = '#${config.colorScheme.palette.base05}',
        base06 = '#${config.colorScheme.palette.base06}',
        base07 = '#${config.colorScheme.palette.base07}',
        base08 = '#${config.colorScheme.palette.base08}',
        base09 = '#${config.colorScheme.palette.base09}',
        base0A = '#${config.colorScheme.palette.base0A}',
        base0B = '#${config.colorScheme.palette.base0B}',
        base0C = '#${config.colorScheme.palette.base0C}',
        base0D = '#${config.colorScheme.palette.base0D}',
        base0E = '#${config.colorScheme.palette.base0E}',
        base0F = '#${config.colorScheme.palette.base0F}'
      })
    '';

    opts = {
      # Line numbers
      number = true;
      relativenumber = true;

      # Indentation
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      smartindent = true;
      autoindent = true;

      # Search
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;

      # Splits
      splitright = true;
      splitbelow = true;

      # Performance & UI
      updatetime = 300;
      timeoutlen = 500;
      termguicolors = true;
      mouse = "a";

      # Undo
      undofile = true;
    };

    globals.mapleader = " ";

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true; # Wayland clipboard
    };

    plugins = {
      # Icons
      web-devicons.enable = true;

      # File Explorer
      nvim-tree = {
        enable = true;
        settings.view = {
          width = 30;
          side = "left";
        };
      };

      # Fuzzy Finder
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        # Keymaps can be defined directly here or in the global keymaps section
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
          "<leader>fr" = "oldfiles";
        };
        settings.defaults.file_ignore_patterns = [
          "node_modules"
          ".git"
        ];
      };

      # Syntax Highlighting
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      # Git Integration
      gitsigns = {
        enable = true;
        settings.signs = {
          add.text = "+";
          change.text = "~";
        };
      };

      # Status Line
      lualine.enable = true;

      # Auto Pairs & Comments
      nvim-autopairs.enable = true;
      comment.enable = true;

      # Indent Guides
      indent-blankline.enable = true;

      # Key Help
      which-key.enable = true;

      # Terminal
      toggleterm = {
        enable = true;
        settings = {
          size = 20;
          direction = "horizontal";
          open_mapping = "[[<c-\\>]]";
        };
      };

      # Language Server Protocol
      lsp = {
        enable = true;
        servers = {
          clangd.enable = true;
          nil_ls.enable = true; # Nix
          lua_ls.enable = true;
          ts_ls.enable = true; # TypeScript
          pylsp.enable = true; # Python
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
        };
        keymaps = {
          silent = true;
          lspBuf = {
            gd = "definition";
            gD = "declaration";
            K = "hover";
            gi = "implementation";
            gr = "references";
            "<space>rn" = "rename";
            "<space>ca" = "code_action";
            "<space>f" = "format";
          };
          diagnostic = {
            "<space>e" = "open_float";
            "[d" = "goto_prev";
            "]d" = "goto_next";
          };
        };
      };

      # Autocompletion
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          mapping = {
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" =
              "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() elseif require('luasnip').expand_or_jumpable() then require('luasnip').expand_or_jump() else fallback() end end, {'i', 's'})";
            "<S-Tab>" =
              "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() elseif require('luasnip').jumpable(-1) then require('luasnip').jump(-1) else fallback() end end, {'i', 's'})";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };

      # Snippets
      luasnip.enable = true;
      friendly-snippets.enable = true;
    };

    keymaps = [
      # Clear search highlighting
      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>nohlsearch<CR>";
        options.desc = "Clear search highlight";
      }
      # Save/Quit
      {
        mode = "n";
        key = "<leader>w";
        action = "<cmd>w<CR>";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>q<CR>";
      }
      {
        mode = "n";
        key = "<leader>x";
        action = "<cmd>x<CR>";
      }

      # NvimTree
      {
        mode = "n";
        key = "<leader>e";
        action = ":NvimTreeToggle<CR>";
      }
      {
        mode = "n";
        key = "<leader>n";
        action = ":NvimTreeFocus<CR>";
      }

      # Buffer Navigation
      {
        mode = "n";
        key = "<leader>bn";
        action = ":bnext<CR>";
      }
      {
        mode = "n";
        key = "<leader>bp";
        action = ":bprevious<CR>";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = ":bdelete<CR>";
      }

      # Window Navigation
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
      }
    ];

    extraPackages = with pkgs; [
      nixpkgs-fmt
      black
      ripgrep
      fd
    ];
  };
}
