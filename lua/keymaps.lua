-- Helper function to set keymaps
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Clear highlights on search when pressing <Esc> in normal mode
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Diagnostic keymaps
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic Error messages" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic Quickfix list" })

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize with arrows
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Navigate buffers
map("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Stay in indent mode
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move text up and down
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Better movement for wrapped lines
map("n", "j", "gj", { desc = "Move down by visual line" })
map("n", "k", "gk", { desc = "Move up by visual line" })

-- Quit and save shortcuts
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>x", ":x<CR>", { desc = "Save and quit" })

-- Split windows
map("n", "<leader>wv", ":vsplit<CR>", { desc = "Split window vertically" })
map("n", "<leader>wh", ":split<CR>", { desc = "Split window horizontally" })
map("n", "<leader>we", "<C-w>=", { desc = "Make split windows equal size" })
map("n", "<leader>wx", ":close<CR>", { desc = "Close current split window" })

-- Terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- File explorer (will be configured with neo-tree)
map("n", "<leader>ee", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })
map("n", "\\", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })

-- Telescope (will be configured later)
map("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Find help tags" })

-- LSP (these will work once LSP is configured)
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
map("n", "K", vim.lsp.buf.hover, { desc = "Show hover information" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>f", vim.lsp.buf.format, { desc = "Format code" })

-- Rust-specific keymaps (cargo commands)
map("n", "<leader>cb", ":!cargo build<CR>", { desc = "Cargo build" })
map("n", "<leader>cr", ":!cargo run<CR>", { desc = "Cargo run" })
map("n", "<leader>ct", ":!cargo test<CR>", { desc = "Cargo test" })
map("n", "<leader>cc", ":!cargo check<CR>", { desc = "Cargo check" })
map("n", "<leader>cl", ":!cargo clippy<CR>", { desc = "Cargo clippy" })

-- PostgreSQL/SQL-specific keymaps
map("n", "<leader>se", ":!psql -U postgres -d %:r<CR>", { desc = "Execute SQL file with psql" })
map("n", "<leader>sp", ":!psql -U postgres<CR>", { desc = "Open psql prompt" })
map("n", "<leader>sd", ":!pg_dump -U postgres -d %:r > %:r_backup.sql<CR>", { desc = "Dump database to SQL file" })
map("n", "<leader>sr", ":!psql -U postgres -f %<CR>", { desc = "Run current SQL file" })
map("n", "<leader>sc", ":!createdb -U postgres ", { desc = "Create new database (enter name)" })