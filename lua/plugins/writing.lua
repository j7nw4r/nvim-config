return {
  -- Distraction-free writing mode
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>wz", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
    },
    opts = {
      window = {
        width = 80,
        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorline = false,
          foldcolumn = "0",
        },
      },
      plugins = {
        twilight = { enabled = true },
        gitsigns = { enabled = false },
      },
    },
  },

  -- Dims inactive paragraphs for focus
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    keys = {
      { "<leader>wt", "<cmd>Twilight<cr>", desc = "Twilight" },
    },
    opts = {
      dimming = { alpha = 0.25 },
      context = 10,
    },
  },
}
