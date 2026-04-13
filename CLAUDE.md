# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Neovim Configuration Architecture

This is a modern Neovim configuration using lazy.nvim as the plugin manager. The configuration is organized with a modular structure:

- `init.lua` - Main entry point that bootstraps lazy.nvim, sets leader keys, loads core configs, and sets up plugin management
- `lua/options.lua` - Core Neovim options and settings (indentation, visual preferences, search, folding, performance)
- `lua/keymaps.lua` - Global key mappings and shortcuts
- `lua/plugins/` - Modular plugin configurations, each file returns a table of plugin specs

### Plugin Structure

Each plugin file in `lua/plugins/` follows the lazy.nvim plugin specification format:
- `lsp.lua` - LSP setup with Mason for server management, multiple language servers (Rust, Python, Go, SQL, Lua, LTeX)
- `completion.lua` - nvim-cmp with LuaSnip, LSP completion, path/buffer completion
- `conform.lua` - Code formatting with format-on-save (stylua, ruff, rustfmt, gofmt, sqlfluff)
- `telescope.lua` - Fuzzy finder with fzf-native extension for files, grep, help, etc.
- `treesitter.lua` - Syntax highlighting, text objects, incremental selection
- `neo-tree.lua` - File explorer
- `oil.lua` - Buffer-based file manager
- `trouble.lua` - Diagnostics viewer and quickfix list manager
- `lazydev.lua` - Lua/Neovim API type hints for development
- `writing.lua` - Zen mode and Twilight for distraction-free writing
- `render-markdown.lua` - In-buffer markdown rendering
- `ui.lua` - UI enhancements including colorscheme (gruvbox), lualine, gitsigns, autopairs, surround, commenting, indent guides, which-key

### Key Configuration Details

- **Leader key**: Space (` `)
- **Plugin manager**: lazy.nvim with automatic plugin updates enabled
- **LSP servers**: Automatically installs rust_analyzer, lua_ls, sqlls, pyright, ruff, gopls, ltex via Mason; ty also configured
- **Colorscheme**: gruvbox
- **File explorer**: neo-tree (toggle with `<leader>ee` or `\`), oil.nvim as alternative
- **Fuzzy finder**: Telescope with fzf-native
- **Completion**: nvim-cmp with LSP, snippets, path, and buffer sources
- **Formatting**: conform.nvim with format-on-save

### Language Support

Multi-language configuration with dedicated keybindings per language:

**Rust** (`<leader>c` group):
- `<leader>cb` - cargo build, `<leader>cr` - cargo run, `<leader>ct` - cargo test
- `<leader>cc` - cargo check, `<leader>cl` - cargo clippy
- LSP: rust-analyzer with clippy on save, proc macro support

**Python** (`<leader>p` group):
- `<leader>pr` - run current file, `<leader>pt` - pytest, `<leader>pT` - pytest current file
- `<leader>py` - ty type check, `<leader>pl` - ruff lint, `<leader>pf` - ruff format
- LSP: pyright (strict type checking) + ruff (linting/formatting) + ty

**Go** (`<leader>G` group):
- `<leader>Gb` - go build, `<leader>Gr` - go run, `<leader>Gt` - go test
- `<leader>Gf` - gofmt, `<leader>Gl` - golangci-lint, `<leader>Gm` - go mod tidy
- LSP: gopls with staticcheck and gofumpt

**SQL/PostgreSQL** (`<leader>s` group):
- `<leader>sr` - run SQL file, `<leader>sp` - open psql, `<leader>sd` - pg_dump
- LSP: sqlls with lint rules

**Writing/Markdown**: LTeX grammar checking, zen mode, render-markdown

Also configured for Lua development (Neovim configuration editing) via lua_ls + lazydev.

### Important Keybindings

- **File operations**: `<leader>w` (save), `<leader>x` (save and quit)
- **Telescope**: `<leader>ff` (find files), `<leader>fg` (live grep), `<leader>fb` (buffers)
- **LSP**: `gd` (definition), `gr` (references), `K` (hover), `<leader>rn` (rename), `<leader>ca` (code action), `<leader>fm` (format)
- **Window management**: `<C-h/j/k/l>` (navigation), `<C-arrows>` (resize), `<leader>wv/wh` (split)
- **Diagnostics**: `]d`/`[d` (next/prev diagnostic), `<leader>e` (show diagnostic float)
- **Trouble**: `<leader>xx` (diagnostics), `<leader>xs` (symbols), `<leader>xq` (quickfix)
- **Git**: `<leader>gb` (blame line), `<leader>gB` (toggle inline blame)

### Development Workflow

This configuration is optimized for:
1. Multi-language development (Rust, Python, Go, SQL) with full LSP support
2. Automated code formatting via conform.nvim with format-on-save
3. Modern editing experience with completion, snippets, and text objects
4. Efficient file navigation with Telescope fuzzy finding and neo-tree/oil
5. Git integration with gitsigns and status line indicators
6. Distraction-free writing with zen mode and markdown rendering
7. Extensible plugin architecture using lazy.nvim

When working with this configuration, plugins are automatically managed and LSP servers are auto-installed via Mason. The configuration prioritizes performance with lazy loading and optimized runtime path settings.