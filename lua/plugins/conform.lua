return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>fm",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format code",
      },
    },
    opts = {
      formatters = {
        -- azure-sdk-for-cpp gates its CI on clang-format-11, and the LLVM
        -- defaults have moved since. Prefer that exact binary when it is
        -- installed (`brew install clang-format@11`) and fall back to whatever
        -- clang-format is on PATH. Both read the repository .clang-format.
        clang_format = {
          command = vim.fn.executable("clang-format-11") == 1 and "clang-format-11" or "clang-format",
        },
      },
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        lua = { "stylua" },
        python = { "ruff_format", "ruff_organize_imports" },
        rust = { "rustfmt" },
        go = { "gofmt" },
        sql = { "sqlfluff" },
      },
      format_on_save = function(bufnr)
        -- The vendored nlohmann json header is excluded from the CI format
        -- pass. Reformatting it produces a large diff that CI then rejects.
        if vim.api.nvim_buf_get_name(bufnr):match("json%.hpp$") then
          return nil
        end
        return { timeout_ms = 2000, lsp_fallback = true }
      end,
    },
  },
}
