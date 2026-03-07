return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
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