-- ghostty.lua: a Neovim colorscheme that matches the default Ghostty terminal theme.
--
-- The background and the 16 ANSI colors below are copied verbatim from Ghostty's
-- resolved defaults (`ghostty +show-config --default=true`). Ghostty's default is a
-- One Dark background (#282c34) paired with a Tomorrow-Night ANSI palette.
--
-- Ghostty does not define editor-chrome colors (cursor line, visual selection,
-- float backgrounds, comments). Those are DERIVED from One Dark's companion shades,
-- since Ghostty's background is One Dark's background. Each derived value is marked.
--
-- To re-sync if you ever set a custom Ghostty theme:
--   ghostty +show-config --default=true --docs=false | grep -E '^background|^foreground|^palette = (1?[0-9])='

local c = {
  -- From Ghostty (exact)
  bg       = "#282c34", -- background
  fg       = "#ffffff", -- foreground
  black    = "#1d1f21", -- palette 0
  red      = "#cc6666", -- palette 1
  green    = "#b5bd68", -- palette 2
  yellow   = "#f0c674", -- palette 3
  blue     = "#81a2be", -- palette 4
  magenta  = "#b294bb", -- palette 5
  cyan     = "#8abeb7", -- palette 6
  white    = "#c5c8c6", -- palette 7
  brblack  = "#666666", -- palette 8
  brred    = "#d54e53", -- palette 9
  brgreen  = "#b9ca4a", -- palette 10
  bryellow = "#e7c547", -- palette 11
  brblue   = "#7aa6da", -- palette 12
  brmagenta= "#c397d8", -- palette 13
  brcyan   = "#70c0b1", -- palette 14
  brwhite  = "#eaeaea", -- palette 15

  -- Derived (One Dark companions to #282c34; Ghostty doesn't specify these)
  bg_darker = "#21252b", -- floats, statusline, sidebars
  bg_light  = "#2c313a", -- CursorLine / CursorColumn
  sel       = "#3e4452", -- Visual selection
  comment   = "#5c6370", -- comments / line numbers
  border    = "#3e4452", -- window separators, float borders
}

-- Reset any previously loaded scheme.
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "ghostty"

local function hi(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

-- Editor UI -----------------------------------------------------------------
hi("Normal",        { fg = c.fg, bg = c.bg })
hi("NormalNC",      { fg = c.fg, bg = c.bg })
hi("NormalFloat",   { fg = c.fg, bg = c.bg_darker })
hi("FloatBorder",   { fg = c.border, bg = c.bg_darker })
hi("FloatTitle",    { fg = c.brblue, bg = c.bg_darker, bold = true })
hi("ColorColumn",   { bg = c.bg_light })
hi("Cursor",        { fg = c.bg, bg = c.fg })
hi("CursorLine",    { bg = c.bg_light })
hi("CursorColumn",  { bg = c.bg_light })
hi("CursorLineNr",  { fg = c.bryellow, bold = true })
hi("LineNr",        { fg = c.comment })
hi("SignColumn",    { bg = c.bg })
hi("VertSplit",     { fg = c.border })
hi("WinSeparator",  { fg = c.border })
hi("Folded",        { fg = c.comment, bg = c.bg_darker })
hi("FoldColumn",    { fg = c.comment, bg = c.bg })
hi("Visual",        { bg = c.sel })
hi("VisualNOS",     { bg = c.sel })
hi("Search",        { fg = c.bg, bg = c.yellow })
hi("IncSearch",     { fg = c.bg, bg = c.bryellow })
hi("CurSearch",     { fg = c.bg, bg = c.bryellow })
hi("MatchParen",    { fg = c.bryellow, bold = true })
hi("NonText",       { fg = c.brblack })
hi("Whitespace",    { fg = c.brblack })
hi("SpecialKey",    { fg = c.brblack })
hi("EndOfBuffer",   { fg = c.bg })
hi("Directory",     { fg = c.blue })
hi("Title",         { fg = c.brblue, bold = true })
hi("ErrorMsg",      { fg = c.brred })
hi("WarningMsg",    { fg = c.bryellow })
hi("ModeMsg",       { fg = c.green })
hi("MsgArea",       { fg = c.fg })
hi("Question",      { fg = c.green })
hi("MoreMsg",       { fg = c.green })

-- Statusline / tabline ------------------------------------------------------
hi("StatusLine",    { fg = c.white, bg = c.bg_darker })
hi("StatusLineNC",  { fg = c.comment, bg = c.bg_darker })
hi("TabLine",       { fg = c.comment, bg = c.bg_darker })
hi("TabLineSel",    { fg = c.fg, bg = c.bg })
hi("TabLineFill",   { bg = c.bg_darker })
hi("WildMenu",      { fg = c.bg, bg = c.blue })

-- Popup menu (completion) ---------------------------------------------------
hi("Pmenu",         { fg = c.fg, bg = c.bg_darker })
hi("PmenuSel",      { fg = c.bg, bg = c.blue, bold = true })
hi("PmenuSbar",     { bg = c.bg_light })
hi("PmenuThumb",    { bg = c.comment })

-- Syntax (legacy groups) ----------------------------------------------------
hi("Comment",        { fg = c.comment, italic = true })
hi("Constant",       { fg = c.cyan })
hi("String",         { fg = c.green })
hi("Character",      { fg = c.green })
hi("Number",         { fg = c.brred })
hi("Boolean",        { fg = c.brred })
hi("Float",          { fg = c.brred })
hi("Identifier",     { fg = c.red })
hi("Function",       { fg = c.blue })
hi("Statement",      { fg = c.magenta })
hi("Conditional",    { fg = c.magenta })
hi("Repeat",         { fg = c.magenta })
hi("Label",          { fg = c.magenta })
hi("Operator",       { fg = c.cyan })
hi("Keyword",        { fg = c.magenta })
hi("Exception",      { fg = c.magenta })
hi("PreProc",        { fg = c.yellow })
hi("Include",        { fg = c.magenta })
hi("Define",         { fg = c.magenta })
hi("Macro",          { fg = c.yellow })
hi("PreCondit",      { fg = c.yellow })
hi("Type",           { fg = c.yellow })
hi("StorageClass",   { fg = c.yellow })
hi("Structure",      { fg = c.yellow })
hi("Typedef",        { fg = c.yellow })
hi("Special",        { fg = c.cyan })
hi("SpecialChar",    { fg = c.cyan })
hi("Tag",            { fg = c.red })
hi("Delimiter",      { fg = c.white })
hi("SpecialComment", { fg = c.comment, bold = true })
hi("Debug",          { fg = c.brred })
hi("Underlined",     { fg = c.blue, underline = true })
hi("Ignore",         { fg = c.comment })
hi("Error",          { fg = c.brred })
hi("Todo",           { fg = c.bg, bg = c.bryellow, bold = true })

-- Diagnostics ---------------------------------------------------------------
hi("DiagnosticError", { fg = c.brred })
hi("DiagnosticWarn",  { fg = c.bryellow })
hi("DiagnosticInfo",  { fg = c.brblue })
hi("DiagnosticHint",  { fg = c.brcyan })
hi("DiagnosticOk",    { fg = c.brgreen })
hi("DiagnosticUnderlineError", { sp = c.brred, undercurl = true })
hi("DiagnosticUnderlineWarn",  { sp = c.bryellow, undercurl = true })
hi("DiagnosticUnderlineInfo",  { sp = c.brblue, undercurl = true })
hi("DiagnosticUnderlineHint",  { sp = c.brcyan, undercurl = true })

-- Diff / git ----------------------------------------------------------------
hi("DiffAdd",     { bg = "#2a3328" })
hi("DiffChange",  { bg = "#283139" })
hi("DiffDelete",  { fg = c.brred, bg = "#332727" })
hi("DiffText",    { bg = "#34414d" })
hi("Added",       { fg = c.green })
hi("Changed",     { fg = c.yellow })
hi("Removed",     { fg = c.red })
hi("GitSignsAdd",    { fg = c.green })
hi("GitSignsChange", { fg = c.yellow })
hi("GitSignsDelete", { fg = c.red })

-- Spell ---------------------------------------------------------------------
hi("SpellBad",   { sp = c.brred, undercurl = true })
hi("SpellCap",   { sp = c.bryellow, undercurl = true })
hi("SpellRare",  { sp = c.brmagenta, undercurl = true })
hi("SpellLocal", { sp = c.brcyan, undercurl = true })

-- Treesitter ----------------------------------------------------------------
hi("@comment",              { link = "Comment" })
hi("@comment.error",        { fg = c.bg, bg = c.brred })
hi("@comment.warning",      { fg = c.bg, bg = c.bryellow })
hi("@comment.todo",         { link = "Todo" })
hi("@comment.note",         { fg = c.bg, bg = c.brcyan })
hi("@constant",             { fg = c.cyan })
hi("@constant.builtin",     { fg = c.brred })
hi("@constant.macro",       { fg = c.yellow })
hi("@string",               { fg = c.green })
hi("@string.escape",        { fg = c.cyan })
hi("@string.special",       { fg = c.cyan })
hi("@string.regexp",        { fg = c.brcyan })
hi("@character",            { fg = c.green })
hi("@character.special",    { fg = c.cyan })
hi("@number",               { fg = c.brred })
hi("@boolean",              { fg = c.brred })
hi("@float",                { fg = c.brred })
hi("@function",             { fg = c.blue })
hi("@function.builtin",     { fg = c.cyan })
hi("@function.call",        { fg = c.blue })
hi("@function.macro",       { fg = c.yellow })
hi("@function.method",      { fg = c.blue })
hi("@function.method.call", { fg = c.blue })
hi("@constructor",          { fg = c.yellow })
hi("@parameter",            { fg = c.red })
hi("@keyword",              { fg = c.magenta })
hi("@keyword.function",     { fg = c.magenta })
hi("@keyword.operator",     { fg = c.magenta })
hi("@keyword.return",       { fg = c.magenta })
hi("@keyword.import",       { fg = c.magenta })
hi("@keyword.exception",    { fg = c.magenta })
hi("@conditional",          { fg = c.magenta })
hi("@repeat",               { fg = c.magenta })
hi("@operator",             { fg = c.cyan })
hi("@exception",            { fg = c.magenta })
hi("@variable",             { fg = c.fg })
hi("@variable.builtin",     { fg = c.brred })
hi("@variable.parameter",   { fg = c.red })
hi("@variable.member",      { fg = c.red })
hi("@property",             { fg = c.red })
hi("@field",                { fg = c.red })
hi("@type",                 { fg = c.yellow })
hi("@type.builtin",         { fg = c.yellow })
hi("@type.definition",      { fg = c.yellow })
hi("@attribute",            { fg = c.yellow })
hi("@namespace",            { fg = c.yellow })
hi("@module",               { fg = c.yellow })
hi("@punctuation.delimiter",{ fg = c.white })
hi("@punctuation.bracket",  { fg = c.white })
hi("@punctuation.special",  { fg = c.cyan })
hi("@tag",                  { fg = c.red })
hi("@tag.attribute",        { fg = c.yellow })
hi("@tag.delimiter",        { fg = c.white })
hi("@label",                { fg = c.magenta })
hi("@markup.heading",       { fg = c.brblue, bold = true })
hi("@markup.strong",        { bold = true })
hi("@markup.italic",        { italic = true })
hi("@markup.link",          { fg = c.blue, underline = true })
hi("@markup.link.url",      { fg = c.cyan, underline = true })
hi("@markup.raw",           { fg = c.green })
hi("@markup.list",          { fg = c.cyan })
hi("@markup.quote",         { fg = c.comment, italic = true })

-- LSP semantic tokens -------------------------------------------------------
hi("@lsp.type.namespace",   { link = "@namespace" })
hi("@lsp.type.type",        { link = "@type" })
hi("@lsp.type.class",       { link = "@type" })
hi("@lsp.type.enum",        { link = "@type" })
hi("@lsp.type.interface",   { link = "@type" })
hi("@lsp.type.struct",      { link = "@type" })
hi("@lsp.type.parameter",   { link = "@variable.parameter" })
hi("@lsp.type.variable",    { link = "@variable" })
hi("@lsp.type.property",    { link = "@property" })
hi("@lsp.type.function",    { link = "@function" })
hi("@lsp.type.method",      { link = "@function.method" })
hi("@lsp.type.keyword",     { link = "@keyword" })
hi("@lsp.type.comment",     { link = "@comment" })
hi("LspReferenceText",      { bg = c.sel })
hi("LspReferenceRead",      { bg = c.sel })
hi("LspReferenceWrite",     { bg = c.sel })
hi("LspInlayHint",          { fg = c.comment, bg = c.bg_darker })

-- Telescope -----------------------------------------------------------------
hi("TelescopeNormal",        { fg = c.fg, bg = c.bg_darker })
hi("TelescopeBorder",        { fg = c.border, bg = c.bg_darker })
hi("TelescopePromptNormal",  { fg = c.fg, bg = c.bg_light })
hi("TelescopePromptBorder",  { fg = c.bg_light, bg = c.bg_light })
hi("TelescopePromptTitle",   { fg = c.bg, bg = c.brred, bold = true })
hi("TelescopePreviewTitle",  { fg = c.bg, bg = c.brgreen, bold = true })
hi("TelescopeResultsTitle",  { fg = c.bg_darker, bg = c.bg_darker })
hi("TelescopeSelection",     { bg = c.sel })
hi("TelescopeMatching",      { fg = c.bryellow, bold = true })

-- which-key -----------------------------------------------------------------
hi("WhichKey",          { fg = c.brblue })
hi("WhichKeyGroup",     { fg = c.red })
hi("WhichKeyDesc",      { fg = c.fg })
hi("WhichKeySeparator", { fg = c.comment })
hi("WhichKeyFloat",     { bg = c.bg_darker })

-- Indent guides (built-in / indent-blankline) ------------------------------
hi("IblIndent",     { fg = c.bg_light })
hi("IblScope",      { fg = c.comment })
