{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # LSP support
      nvim-lspconfig

      # Autocompletion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline

      # Snippets
      luasnip
      cmp_luasnip
      friendly-snippets # Pre-built snippets for various languages

      # File explorer
      nvim-tree-lua
      nvim-web-devicons # Icons for nvim-tree and other plugins

      # Fuzzy finder
      telescope-nvim
      telescope-fzf-native-nvim

      # Syntax highlighting
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects

      # Git integration
      gitsigns-nvim

      # Status line
      lualine-nvim

      # Auto pairs
      nvim-autopairs

      # Comment toggling
      comment-nvim

      # Indent guides
      indent-blankline-nvim

      # Which-key (shows keybind hints)
      which-key-nvim

      # Better terminal
      toggleterm-nvim
    ];

    extraPackages = with pkgs; [
      # Language servers
      clang-tools # clangd
      nil # Nix LSP
      lua-language-server
      nodePackages.typescript-language-server
      python3Packages.python-lsp-server
      rust-analyzer

      # Formatters
      nixpkgs-fmt
      black # Python formatter
      rustfmt

      # Other tools
      ripgrep # Better grep for telescope
      fd # Better find for telescope
      tree-sitter # For treesitter
    ];

    extraConfig = ''
      " Set leader key
      let mapleader = " "

      " Appearance
      set termguicolors

      " Line numbers
      set number
      set relativenumber

      " Indentation
      set tabstop=4
      set shiftwidth=4
      set expandtab
      set smartindent
      set autoindent

      " Search
      set ignorecase
      set smartcase
      set hlsearch
      set incsearch

      " Splits
      set splitright
      set splitbelow

      " Performance
      set updatetime=300
      set timeoutlen=500

      " Enable mouse support
      set mouse=a

      " Better backspace
      set backspace=indent,eol,start

      " Clipboard integration
      set clipboard+=unnamedplus

      " Undo settings
      set undofile
      set undodir=~/.config/nvim/undo

      " LSP configuration
      lua << EOF
      local lspconfig = require('lspconfig')

      -- Setup language servers
      local servers = {
        'clangd',
        'nil_ls',         -- Nix
        'lua_ls',         -- Lua
        'ts_ls',          -- TypeScript/JavaScript
        'pylsp',          -- Python
        'rust_analyzer'   -- Rust
      }

      -- Common on_attach function for all LSP servers
      local on_attach = function(client, bufnr)
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function()
          vim.lsp.buf.format { async = true }
        end, opts)
      end

      -- Setup each server
      for _, server in ipairs(servers) do
        local config = {
          on_attach = on_attach,
          capabilities = require('cmp_nvim_lsp').default_capabilities()
        }

        -- Special config for lua_ls
        if server == 'lua_ls' then
          config.settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              diagnostics = { globals = {'vim'} },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            }
          }
        end

        lspconfig[server].setup(config)
      end

      -- Global mappings for diagnostics
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

      -- Treesitter configuration
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        indent = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
        },
      })

      -- Completion configuration
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      -- Load friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        })
      })

      -- Command line completion
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })

      -- Telescope configuration
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git" },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      })
      require('telescope').load_extension('fzf')

      -- GitSigns configuration
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        }
      })

      -- Lualine configuration
      require('lualine').setup({
        options = {
          theme = 'auto',
          component_separators = '|',
          section_separators = "",
        }
      })

      -- NvimTree configuration
      require("nvim-tree").setup({
        view = {
          width = 30,
          side = 'left',
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      })

      -- Autopairs configuration
      require('nvim-autopairs').setup({})

      -- Comment configuration
      require('Comment').setup()

      -- Indent blankline configuration
      require('ibl').setup({
        indent = { char = "│" },
        scope = { enabled = false },
      })

      -- Which-key configuration
      require('which-key').setup()

      -- ToggleTerm configuration
      require('toggleterm').setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = true,
        direction = 'horizontal',
      })
      EOF

      " Key mappings
      " File operations
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
      nnoremap <leader>fr <cmd>Telescope oldfiles<cr>

      " NvimTree keymaps
      nnoremap <leader>e :NvimTreeToggle<CR>
      nnoremap <leader>n :NvimTreeFocus<CR>

      " Buffer navigation
      nnoremap <leader>bn :bnext<CR>
      nnoremap <leader>bp :bprevious<CR>
      nnoremap <leader>bd :bdelete<CR>

      " Window navigation
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      " Clear search highlighting
      nnoremap <leader>/ :nohlsearch<CR>

      " Save and quit shortcuts
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>
      nnoremap <leader>x :x<CR>

      " Git shortcuts (GitSigns)
      nnoremap <leader>gp :Gitsigns preview_hunk<CR>
      nnoremap <leader>gt :Gitsigns toggle_current_line_blame<CR>
      nnoremap <leader>gn :Gitsigns next_hunk<CR>
      nnoremap <leader>gN :Gitsigns prev_hunk<CR>
    '';
  };
}
