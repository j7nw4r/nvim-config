return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: working tree vs HEAD" },
      {
        "<leader>gu",
        function()
          local upstream = vim.fn.systemlist("git rev-parse --abbrev-ref --symbolic-full-name @{u}")[1]
          if vim.v.shell_error ~= 0 or not upstream or upstream == "" then
            vim.notify("No upstream set for current branch", vim.log.levels.WARN)
            return
          end
          vim.cmd("DiffviewOpen " .. upstream .. "...HEAD")
        end,
        desc = "Diffview: unpushed changes (vs upstream)",
      },
      {
        "<leader>gU",
        function()
          local upstream = vim.fn.systemlist("git rev-parse --abbrev-ref --symbolic-full-name @{u}")[1]
          if vim.v.shell_error ~= 0 or not upstream or upstream == "" then
            vim.notify("No upstream set for current branch", vim.log.levels.WARN)
            return
          end
          vim.cmd("DiffviewOpen " .. upstream)
        end,
        desc = "Diffview: unpushed + uncommitted (flattened)",
      },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: branch file history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: current file history" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
        },
      },
    },
  },
}
