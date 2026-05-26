-- nvim-treesitter `main` branch: parsers + queries only. Highlighting,
-- indentation, and folding are enabled here via FileType autocmds using
-- Neovim's built-in vim.treesitter.* API.

local ensure_installed = {
  "bash",
  "c",
  "c_sharp",
  "cmake",
  "cpp",
  "css",
  "diff",
  "fsharp",
  "go",
  "gomod",
  "gosum",
  "gowork",
  "html",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "rust",
  "sql",
  "toml",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

-- Filetypes that should opt into treesitter indent. Parser name == filetype
-- for everything we install, except `vimdoc` (filetype is `help`) and
-- `c_sharp` (filetype is `cs`); those filetypes are appended explicitly.
local indent_filetypes = vim.list_extend(vim.deepcopy(ensure_installed), { "help", "cs" })

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(ensure_installed)

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
          if vim.tbl_contains(indent_filetypes, vim.bo[args.buf].filetype) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    -- If you hit ftplugin keymap conflicts (e.g. `[m`/`]m` overridden by a
    -- builtin filetype plugin), uncomment to disable them globally:
    -- init = function() vim.g.no_plugin_maps = true end,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      local function map_select(lhs, capture, group, desc)
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(capture, group or "textobjects")
        end, { desc = desc })
      end

      map_select("aa", "@parameter.outer", nil, "a parameter")
      map_select("ia", "@parameter.inner", nil, "inner parameter")
      map_select("af", "@function.outer", nil, "a function")
      map_select("if", "@function.inner", nil, "inner function")
      map_select("ac", "@class.outer", nil, "a class")
      map_select("ic", "@class.inner", nil, "inner class")
      map_select("ai", "@conditional.outer", nil, "a conditional")
      map_select("ii", "@conditional.inner", nil, "inner conditional")
      map_select("al", "@loop.outer", nil, "a loop")
      map_select("il", "@loop.inner", nil, "inner loop")
      map_select("at", "@comment.outer", nil, "a comment")

      local function map_move(lhs, fn, capture, group, desc)
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          move[fn](capture, group or "textobjects")
        end, { desc = desc })
      end

      map_move("]m", "goto_next_start", "@function.outer", nil, "Next function start")
      map_move("]]", "goto_next_start", "@class.outer", nil, "Next class start")
      map_move("]o", "goto_next_start", { "@loop.inner", "@loop.outer" }, nil, "Next loop start")
      map_move("]s", "goto_next_start", "@local.scope", "locals", "Next scope")
      map_move("]z", "goto_next_start", "@fold", "folds", "Next fold")

      map_move("]M", "goto_next_end", "@function.outer", nil, "Next function end")
      map_move("][", "goto_next_end", "@class.outer", nil, "Next class end")

      map_move("[m", "goto_previous_start", "@function.outer", nil, "Prev function start")
      map_move("[[", "goto_previous_start", "@class.outer", nil, "Prev class start")

      map_move("[M", "goto_previous_end", "@function.outer", nil, "Prev function end")
      map_move("[]", "goto_previous_end", "@class.outer", nil, "Prev class end")

      -- Conditional motions use ]c/[c (not ]d/[d, which lsp.lua binds to
      -- diagnostic navigation).
      map_move("]c", "goto_next", "@conditional.outer", nil, "Next conditional")
      map_move("[c", "goto_previous", "@conditional.outer", nil, "Prev conditional")

      vim.keymap.set("n", "<leader>a", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap next parameter" })
      vim.keymap.set("n", "<leader>A", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap previous parameter" })
    end,
  },
}
