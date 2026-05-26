-- Roslyn-based C# language server (the server VS Code uses).
--
-- Unlike the servers in lsp.lua, Roslyn is NOT in the official mason-org
-- registry and is NOT managed by mason-lspconfig. This plugin ships its own
-- `lsp/roslyn.lua` and calls `vim.lsp.enable("roslyn")` on load, so we do not
-- enable it ourselves; lsp.lua only merges nvim-cmp capabilities into it via
-- `vim.lsp.config("roslyn", ...)`.
--
-- The server binary comes from the Crashdummyy Mason registry (added in
-- lsp.lua's mason setup). One-time install after first launch:
--     :MasonInstall roslyn
-- The plugin resolves the Mason-installed binary automatically.
--
-- Requires Neovim >= 0.12 (the plugin refuses to load below that).
return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {},
  },
}
