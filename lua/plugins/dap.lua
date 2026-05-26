return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
      "williamboman/mason.nvim",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "netcoredbg" },
        automatic_installation = true,
        handlers = {},
      })

      dapui.setup()
      require("nvim-dap-virtual-text").setup({})

      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

      local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = codelldb_path,
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.cpp = {
        {
          name = "Launch (codelldb)",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Attach to process (codelldb)",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp

      -- .NET (C# and F#) via netcoredbg. Both languages run on coreclr, so the
      -- F# configs reuse the C# ones. Launch points at a built dll; the default
      -- guesses bin/Debug/net10.0/<dirname>.dll (run `dotnet build` first).
      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.exepath("netcoredbg"),
        args = { "--interpreter=vscode" },
      }

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch (netcoredbg)",
          request = "launch",
          program = function()
            local guess = vim.fn.getcwd() .. "/bin/Debug/net10.0/"
              .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ".dll"
            return vim.fn.input("Path to dll: ", guess, "file")
          end,
          cwd = "${workspaceFolder}",
        },
        {
          type = "coreclr",
          name = "Attach to process (netcoredbg)",
          request = "attach",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
      dap.configurations.fsharp = dap.configurations.cs

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint", linehl = "", numhl = "" })

      local map = vim.keymap.set
      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP toggle breakpoint" })
      map("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, { desc = "DAP conditional breakpoint" })
      map("n", "<leader>dc", dap.continue, { desc = "DAP continue / start" })
      map("n", "<leader>dn", dap.step_over, { desc = "DAP step over (next)" })
      map("n", "<leader>di", dap.step_into, { desc = "DAP step into" })
      map("n", "<leader>do", dap.step_out, { desc = "DAP step out" })
      map("n", "<leader>dr", dap.repl.toggle, { desc = "DAP toggle REPL" })
      map("n", "<leader>dl", dap.run_last, { desc = "DAP run last" })
      map("n", "<leader>dt", dap.terminate, { desc = "DAP terminate" })
      map("n", "<leader>du", dapui.toggle, { desc = "DAP toggle UI" })
      map("n", "<leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "DAP hover variable" })
      map("v", "<leader>dh", function() require("dap.ui.widgets").preview() end, { desc = "DAP preview expression" })
    end,
  },
}
