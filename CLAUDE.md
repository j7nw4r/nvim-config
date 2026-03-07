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
- `lsp.lua` - LSP setup with Mason for server management, rust-analyzer and lua_ls configuration
- `completion.lua` - nvim-cmp with LuaSnip, LSP completion, path/buffer completion
- `telescope.lua` - Fuzzy finder with fzf-native extension for files, grep, help, etc.
- `treesitter.lua` - Syntax highlighting, text objects, incremental selection
- `neo-tree.lua` - File explorer
- `ui.lua` - UI enhancements including colorscheme (tokyonight), lualine, gitsigns, autopairs, surround, commenting, indent guides, which-key

### Key Configuration Details

- **Leader key**: Space (` `)
- **Plugin manager**: lazy.nvim with automatic plugin updates enabled
- **LSP servers**: Automatically installs rust-analyzer and lua_ls via Mason
- **Colorscheme**: tokyonight-night
- **File explorer**: neo-tree (toggle with `<leader>ee`)
- **Fuzzy finder**: Telescope with fzf-native
- **Completion**: nvim-cmp with LSP, snippets, path, and buffer sources

### Language Support

Primary focus on **Rust development** with dedicated cargo keybindings:
- `<leader>cb` - cargo build
- `<leader>cr` - cargo run  
- `<leader>ct` - cargo test
- `<leader>cc` - cargo check
- `<leader>cl` - cargo clippy

Also configured for Lua development (Neovim configuration editing).

### Important Keybindings

- **File operations**: `<leader>w` (save), `<leader>q` (quit), `<leader>x` (save and quit)
- **Telescope**: `<leader>ff` (find files), `<leader>fg` (live grep), `<leader>fb` (buffers)
- **LSP**: `gd` (definition), `gr` (references), `K` (hover), `<leader>rn` (rename), `<leader>ca` (code action)
- **Window management**: `<C-h/j/k/l>` (navigation), `<C-arrows>` (resize)
- **Diagnostics**: `]d`/`[d` (next/prev diagnostic), `<leader>e` (show diagnostic)

### Development Workflow

This configuration is optimized for:
1. Rust development with full LSP support and cargo integration
2. Modern editing experience with completion, snippets, and text objects
3. Efficient file navigation with Telescope fuzzy finding
4. Git integration with gitsigns and status line indicators
5. Extensible plugin architecture using lazy.nvim

When working with this configuration, plugins are automatically managed and LSP servers are auto-installed via Mason. The configuration prioritizes performance with lazy loading and optimized runtime path settings.