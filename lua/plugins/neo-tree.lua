return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      {
        "s1n7ax/nvim-window-picker",
        version = "2.*",
        config = function()
          require("window-picker").setup({
            filter_rules = {
              include_current_win = false,
              autoselect_one = true,
              bo = {
                filetype = { "neo-tree", "neo-tree-popup", "notify" },
                buftype = { "terminal", "quickfix" },
              },
            },
          })
        end,
      },
    },
    cmd = "Neotree",
    keys = {
      { "<leader>ee", ":Neotree toggle<CR>", { desc = "NeoTree toggle" } },
      { "\\", ":Neotree toggle<CR>", { desc = "NeoTree toggle" } },
    },
    opts = {},
    config = function(_, opts)
      require("neo-tree").setup(opts)
    end,
  },
}