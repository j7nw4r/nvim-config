# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Neovim Configuration Architecture

This is a modern Neovim configuration using lazy.nvim as the plugin manager. The configuration is organized with a modular structure:

- `init.lua` - Main entry point that bootstraps lazy.nvim, sets leader keys, loads core configs, and sets up plugin management
- `lua/options.lua` - Core Neovim options and settings (indentation, visual preferences, search, folding, performance). Also enables `exrc` for project-local `.nvim.lua` files.
- `lua/keymaps.lua` - Global key mappings and shortcuts
- `lua/cmake.lua` - Asynchronous CMake driver (configure, build, ctest, run) used by the `<leader>C` maps
- `lua/plugins/` - Modular plugin configurations, each file returns a table of plugin specs

### Plugin Structure

Each plugin file in `lua/plugins/` follows the lazy.nvim plugin specification format:
- `lsp.lua` - LSP setup with Mason for server management; configures rust-analyzer, lua_ls, sqlls, postgres_lsp, pyright/ty/ruff, gopls, clangd, sourcekit (Swift), ltex, and fsautocomplete (F#). C# (Roslyn) is set up separately in `roslyn.lua`.
- `roslyn.lua` - Roslyn-based C# language server (seblyng/roslyn.nvim). Not in the official Mason registry, so mason setup adds the Crashdummyy registry; install once with `:MasonInstall roslyn`. Requires Neovim >= 0.12.
- `completion.lua` - nvim-cmp with LuaSnip, LSP completion, path/buffer completion
- `dadbod.lua` - Database queries, a database sidebar, and SQL completion through nvim-cmp
- `conform.lua` - Code formatting with format-on-save (stylua, ruff, rustfmt, gofmt, sqlfluff)
- `telescope.lua` - Fuzzy finder with fzf-native extension for files, grep, help, etc.
- `treesitter.lua` - Syntax highlighting, text objects, incremental selection
- `neo-tree.lua` - File explorer
- `oil.lua` - Buffer-based file manager
- `trouble.lua` - Diagnostics viewer and quickfix list manager
- `lazydev.lua` - Lua/Neovim API type hints for development
- `writing.lua` - Zen mode and Twilight for distraction-free writing
- `render-markdown.lua` - In-buffer markdown rendering
- `ui.lua` - UI enhancements: lualine (theme `auto`), gitsigns, autopairs, surround, commenting, indent guides, which-key. The colorscheme itself lives in `colors/ghostty.lua` and is applied at the end of `init.lua`.

### Key Configuration Details

- **Leader key**: Space (` `)
- **Plugin manager**: lazy.nvim with automatic plugin updates enabled
- **LSP servers**: Automatically installs rust_analyzer, lua_ls, sqlls, pyright, ruff, gopls, ltex via Mason; ty also configured
- **Colorscheme**: `ghostty` (custom, in `colors/ghostty.lua`) - matches the default Ghostty terminal palette (One Dark bg + Tomorrow-Night ANSI colors). Re-sync instructions are in the file header.
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

**C/C++/CMake** (`<leader>C` group):
- `<leader>Cg` - configure, `<leader>Cb` - build, `<leader>CB` - build one target (picker)
- `<leader>Ct` - ctest all, `<leader>CT` - ctest matching a regex, `<leader>Cc` - clean target
- `<leader>Cr` - pick and run a build artifact, `<leader>Co` - output buffer, `<leader>Cx` - stop the job
- `<leader>Cm` - make, `<leader>CM` - make clean
- `<leader>Ch` - switch source/header, `<leader>Ci` - toggle inlay hints, `<leader>Cy` - clangd symbol info (these three appear only when clangd attaches)
- LSP: clangd (clang-tidy, background index at low priority, `--header-insertion=never`); debugging via codelldb
- Formatting: conform runs `clang-format-11` when it is installed, otherwise `clang-format`. Azure repositories gate CI on version 11, and newer LLVM defaults produce a different result.

### The CMake driver (`lua/cmake.lua`)

The `<leader>C` maps call this module instead of shelling out with `:!`, because a vcpkg manifest restore can run for a long time and `:!` blocks the editor.

- Every command runs through `vim.system`, streams into a `cmake://output` scratch buffer, and fills the quickfix list on exit. The quickfix opens by itself when the command fails.
- `M.root()` returns the git root when that directory holds a CMakeLists.txt, and otherwise the nearest CMakeLists.txt ancestor. A monorepo such as azure-sdk-for-cpp configures from the top even though intermediate directories hold no CMakeLists.txt.
- Configure always passes `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` and writes to `<root>/build/`. clangd searches parent directories and their `build/` subdirectory, so it finds the compilation database with no symlink and no `.clangd` file.
- When the root holds a `vcpkg.json`, configure adds `-DCMAKE_TOOLCHAIN_FILE=<vcpkg>/scripts/buildsystems/vcpkg.cmake`. It looks at `$VCPKG_ROOT`, then `vcpkg` on PATH, then `~/vcpkg`.
- Ninja is used when it is installed.

Projects tune it with `vim.g.cmake_configure_args` (a table of extra `-D` flags), `vim.g.cmake_build_dir`, and `vim.g.cmake_generator`.

### Project-local configuration (`exrc`)

`vim.opt.exrc` is on in `options.lua`. Neovim reads a `.nvim.lua` in the current directory and asks to trust it once. Use it for build flags a single repository needs, and add the file to that repository's `.git/info/exclude` so it stays out of git.

`~/Dev/azure-sdk-for-cpp/.nvim.lua` is the worked example: its CMakePresets.json carries only Windows and Linux presets, so the macOS checkout sets `BUILD_TESTING`, `BUILD_SAMPLES`, `BUILD_TRANSPORT_CURL`, and `WARNINGS_AS_ERRORS=OFF` by hand. The last one matters because Apple Clang 21 added `-Wunnecessary-virtual-specifier`, which fires inside azure-core-amqp and stops a `-Werror` build; CI runs older compilers and keeps the flag on.

**.NET (C# and F#)**:
- C# uses the Roslyn server (`roslyn.lua`); run `:MasonInstall roslyn` once (the Crashdummyy registry is added in mason setup).
- F# uses `fsautocomplete` (auto-installed via mason-lspconfig). `.fs`/`.fsx`/`.fsi` are mapped to the `fsharp` filetype in `options.lua` because Neovim defaults `.fs` to `forth`.
- Treesitter parsers `c_sharp` and `fsharp` provide highlighting/indentation.
- Debugging uses `netcoredbg` (adapter type `coreclr`, auto-installed via mason-nvim-dap); launch/attach configs are in `dap.lua` under `dap.configurations.cs`/`.fsharp`.

**SQL/PostgreSQL** (`<leader>s` group):
- `<leader>sr` - run SQL file, `<leader>sp` - open psql, `<leader>sd` - pg_dump
- LSP: sqlls with lint rules

Dadbod adds database queries and schema browsing. The database sidebar also uses the `<leader>q` group. Its plugins load when a database command runs or an SQL buffer opens.

- `|` (Shift plus backslash) or `<leader>qu` opens or closes the database sidebar.
- `<leader>qa` adds a connection. The UI saves connections and queries under Neovim's data directory in `dadbod-ui/`.
- `<leader>qf` finds the current query buffer in the sidebar.
- Run `:DBUI` to browse connections, schemas, tables, and saved queries. Press `?` in the sidebar for its mappings.
- In a query buffer that the UI creates, `:w` executes the query. Press `<leader>W` to save a query for later use.
- SQL, MySQL, and PL/SQL buffers use database completion alongside the existing LSP, snippet, path, and buffer sources.

Dadbod uses database command-line clients. Install `psql` for PostgreSQL or `sqlite3` for SQLite. Use `:DBUIAddConnection` or export `DBUI_URL` before starting Neovim. `DBUI_NAME` sets the connection name. For an SQL file outside the UI, set `b:db` to its database URL or export `DATABASE_URL`. Keep connection URLs out of this repository.

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
