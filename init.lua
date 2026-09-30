--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

-- NOTE: For more options, you can see `:help option-list

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim. Schedule the setting after `UIEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    vim.o.clipboard = 'unnamedplus'
  end,
})

vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Set indent
vim.o.tabstop = 4 -- A Tab character looks like 4 spaces
vim.o.expandtab = true -- Pressing tab will insert spaces
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a tab character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting.

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 6

-- Change completion behavior to not insert or auto select any completion alternative
vim.o.completeopt = 'menuone,popup,noselect'

-- Virtual Line for diagnostics but only on current line instead of all lines.
-- vim.diagnostic.config {
--   virtual_lines = {
--     current_line = true,
--   },
-- }

-- Set mark on each command line prompt in terminal
vim.api.nvim_create_autocmd('TermOpen', {
  command = 'setlocal signcolumn=auto',
})
local ns = vim.api.nvim_create_namespace 'my.terminal.prompt'
vim.api.nvim_create_autocmd('TermRequest', {
  callback = function(args)
    if string.match(args.data.sequence, '^\027]133;A') then
      local lnum = args.data.cursor[1]
      vim.api.nvim_buf_set_extmark(args.buf, ns, lnum - 1, 0, {
        sign_text = '▶',
        sign_hl_group = 'SpecialChar',
      })
    end
  end,
})

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

vim.keymap.set('n', '<C-s>', '<Cmd>w<CR>', { desc = 'Save buffer to file' })
vim.keymap.set('i', '<C-s>', '<Cmd>w<CR>', { desc = 'Save buffer to file' })
vim.keymap.set('n', '<C-S-s>', '<Cmd>wall<CR>', { desc = 'Save all modified buffers' })
vim.keymap.set('i', '<C-S-s>', '<Cmd>wall<CR>', { desc = 'Save all modified buffers' })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Delete current buffer
vim.keymap.set('n', '<C-x>', '<Cmd>bdelete<CR>', { desc = 'Delete buffer' })

-- Show confirmation menu when certain commands fail. e.g. q, w, e ...
vim.o.confirm = true

-- Exit vim unless unsaved modified buffers exist.
-- This config assumes option 'confirm' is set
-- which will prompt for action on unsaved modified buffer.
vim.keymap.set('n', '<C-S-X>', '<Cmd>qall<CR>', { desc = 'Exit vim, confirm for unsaved buffer' })

--  See `:help lua-guide-autocommands`
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  spec = {
    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
    { 'numToStr/Comment.nvim', opts = {} }, -- "gc" to comment visual regions/lines

    { -- Useful plugin to show you pending keybinds.
      'folke/which-key.nvim',
      event = 'VeryLazy',
      config = function() -- This is the function that runs, AFTER loading
        require('which-key').setup()

        -- Document existing key chains
        require('which-key').add {
          { '<leader>c', group = '[C]ode' },
          { '<leader>d', group = '[D]ocument' },
          { '<leader>r', group = '[R]ename' },
          { '<leader>s', group = '[S]earch' },
          { '<leader>t', group = '[T]oggle' },
          { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
          { '<leader>w', group = '[W]orkspace' },
        }
      end,
    },

    { -- Fuzzy Finder (files, lsp, etc)
      'nvim-telescope/telescope.nvim',
      version = '*',
      dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        { 'nvim-telescope/telescope-ui-select.nvim' },
        { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font }, -- Useful for getting pretty icons, but requires a Nerd Font
      },
      config = function()
        require('telescope').setup {
          defaults = {
            layout_config = {
              horizontal = {
                height = 0.99,
                width = 0.99,
              },
            },
          },
          -- pickers = {}
          extensions = {},
        }

        -- Enable telescope extensions, if they are installed
        pcall(require('telescope').load_extension, 'fzf')

        -- See `:help telescope.builtin`
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
        vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
        vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
        vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
        vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

        -- Shortcut for searching your neovim configuration files
        vim.keymap.set('n', '<leader>sn', function()
          builtin.find_files { cwd = vim.fn.stdpath 'config' }
        end, { desc = '[S]earch [N]eovim files' })
      end,
    },

    { -- LSP Configuration & Plugins
      'neovim/nvim-lspconfig',
      dependencies = {
        -- Automatically install LSPs and related tools to stdpath for neovim
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',

        -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
        -- used for completion, annotations and signatures of Neovim apis
        { 'folke/neodev.nvim', opts = {} },
      },
      config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
          callback = function(event)
            -- NOTE: Remember that lua is a real programming language, and as such it is possible
            -- to define small helper and utility functions so you don't have to repeat yourself
            -- many times.
            --
            -- In this case, we create a function that lets us more easily define mappings specific
            -- for LSP related items. It sets the mode, buffer and description for us each time.
            local map = function(keys, func, desc)
              vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
            end

            -- Jump to the definition of the word under your cursor.
            --  This is where a variable was first declared, or where a function is defined, etc.
            --  To jump back, press <C-t>.
            map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

            -- Find references for the word under your cursor.
            map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

            -- Jump to the implementation of the word under your cursor.
            --  Useful when your language has ways of declaring types without an actual implementation.
            map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

            -- Jump to the type of the word under your cursor.
            --  Useful when you're not sure what type a variable is and you want to see
            --  the definition of its *type*, not where it was *defined*.
            map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

            -- Fuzzy find all the symbols in your current document.
            --  Symbols are things like variables, functions, types, etc.
            map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

            -- Fuzzy find all the symbols in your current workspace
            --  Similar to document symbols, except searches over your whole project.
            map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

            -- Rename the variable under your cursor
            --  Most Language Servers support renaming across files, etc.
            map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

            -- Execute a code action, usually your cursor needs to be on top of an error
            -- or a suggestion from your LSP for this to activate.
            map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

            -- Opens a popup that displays documentation about the word under your cursor
            --  See `:help K` for why this keymap
            map('K', vim.lsp.buf.hover, 'Hover Documentation')

            -- WARN: This is not Goto Definition, this is Goto Declaration.
            --  For example, in C this would take you to the header
            map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

            -- The following two autocommands are used to highlight references of the
            -- word under your cursor when your cursor rests there for a little while.
            --    See `:help CursorHold` for information about when this is executed
            --
            -- When you move your cursor, the highlights will be cleared (the second autocommand).
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client.server_capabilities.documentHighlightProvider then
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                callback = vim.lsp.buf.document_highlight,
              })

              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                callback = vim.lsp.buf.clear_references,
              })
            end
          end,
        })

        -- LSP servers and clients are able to communicate to each other what features they support.
        --  By default, Neovim doesn't support everything that is in the LSP Specification.
        --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
        --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
        -- local capabilities = vim.lsp.protocol.make_client_capabilities()
        -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

        -- Enable the following language servers
        --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
        --
        --  Add any additional override configuration in the following tables. Available keys are:
        --  - cmd (table): Override the default command used to start the server
        --  - filetypes (table): Override the default list of associated filetypes for the server
        --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        --  - settings (table): Override the default settings passed when initializing the server.
        --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        local servers = {
          -- clangd = {},
          gopls = {},
          -- pyright = {},
          rust_analyzer = {},
          -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
          --
          -- Some languages (like typescript) have entire language plugins that can be useful:
          --    https://github.com/pmizio/typescript-tools.nvim
          --
          -- But for many setups, the LSP (`tsserver`) will work just fine
          -- tsserver = {},
          --

          lua_ls = {
            -- cmd = {...},
            -- filetypes { ...},
            -- capabilities = {},
            settings = {
              Lua = {
                completion = {
                  callSnippet = 'Replace',
                },
                -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                -- diagnostics = { disable = { 'missing-fields' } },
              },
            },
          },
        }

        -- Ensure the servers and tools above are installed
        --  To check the current status of installed tools and/or manually install
        --  other tools, you can run
        --    :Mason
        --
        --  You can press `g?` for help in this menu
        require('mason').setup()

        -- You can add other tools here that you want Mason to install
        -- for you, so that they are available from within Neovim.
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
          'stylua', -- Used to format lua code
        })
        require('mason-tool-installer').setup { ensure_installed = ensure_installed }

        require('mason-lspconfig').setup {
          handlers = {
            function(server_name)
              local server = servers[server_name] or {}
              -- This handles overriding only values explicitly passed
              -- by the server configuration above. Useful when disabling
              -- certain features of an LSP (for example, turning off formatting for tsserver)
              server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
              require('lspconfig')[server_name].setup(server)
            end,
          },
        }
      end,
    },

    { -- Autoformat
      'stevearc/conform.nvim',
      opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = true, cpp = true }
          return {
            timeout_ms = 500,
            lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
          }
        end,
        formatters_by_ft = {
          -- You can use a sub-list to tell conform to run *until* a formatter
          -- is found.
          javascript = {
            stop_after_first = true,
            formatters = { 'dprint', 'prettierd', 'prettier' },
          },
        },
      },
    },

    { -- Autocompletion
      'saghen/blink.cmp',
      version = '1.*',
      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        {
          keymap = { preset = 'default' },

          appearance = {
            -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono',
          },

          -- (Default) Only show the documentation popup when manually triggered
          completion = { documentation = { auto_show = false } },

          -- Default list of enabled providers defined so that you can extend it
          -- elsewhere in your config, without redefining it, due to `opts_extend`
          sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
          },

          -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
          -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
          -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
          --
          -- See the fuzzy documentation for more information
          fuzzy = { implementation = 'prefer_rust_with_warning' },
        },
        opts_extend = { 'sources.default' },
      },
    },

    {
      'folke/tokyonight.nvim',
      priority = 1000, -- make sure to load this before all the other start plugins
      init = function()
        vim.cmd.colorscheme 'tokyonight-night'
        -- You can configure highlights by doing something like
        vim.cmd.hi 'Comment gui=none'
      end,
    },

    -- Highlight todo, notes, etc in comments
    { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

    { -- Collection of various small independent plugins/modules
      'echasnovski/mini.nvim',
      config = function()
        -- Better Around/Inside textobjects
        --
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [']quote
        --  - ci'  - [C]hange [I]nside [']quote
        require('mini.ai').setup { n_lines = 500 }

        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        require('mini.surround').setup()

        local statusline = require 'mini.statusline'
        statusline.setup { use_icons = vim.g.have_nerd_font }

        -- You can configure sections in the statusline by overriding their
        -- default behavior. For example, here we set the section for
        -- cursor location to LINE:COLUMN
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
          return '%2l:%-2v'
        end
      end,
    },

    { 'tpope/vim-fugitive' }, -- Git integration

    { -- Highlight, edit, and navigate code
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      build = ':TSUpdate',
      opts = {
        ensure_installed = { 'rust', 'go', 'odin', 'bash', 'c', 'html', 'lua', 'markdown', 'vim', 'vimdoc' },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
          enable = true,
          -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          --  If you are experiencing weird indenting issues, add the language to
          --  the list of additional_vim_regex_highlighting and disabled languages for indent.
          additional_vim_regex_highlighting = { 'ruby' },
        },
        indent = { enable = true, disable = { 'ruby' } },
      },
    },
    require 'kickstart.plugins.debug',
    require 'kickstart.plugins.indent_line',
    require 'kickstart.plugins.gitsigns',
  },
}
