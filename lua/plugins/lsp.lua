return {
  -- Mason for managing LSP servers, DAP servers, linters, and formatters
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        -- The Roslyn C# server (see roslyn.lua) lives in a third-party
        -- registry, not the official mason-org one. Both are listed so
        -- `:MasonInstall roslyn` resolves while everything else still works.
        registries = {
          "github:mason-org/mason-registry",
          "github:Crashdummyy/mason-registry",
        },
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },

  -- Mason integration with nvim-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "rust_analyzer",
          "lua_ls",
          "sqlls",
          "postgres_lsp",
          "pyright",
          "ruff",
          "gopls",
          "clangd",
          "ltex",
          "fsautocomplete",
        },
        automatic_installation = true,
      })
    end,
  },

  -- LSP progress notifications
  {
    "j-hui/fidget.nvim",
    opts = {},
  },

  -- LSP Configuration using Neovim 0.11+ native API
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Setup capabilities for nvim-cmp
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Configure rust-analyzer
      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              runBuildScripts = true,
            },
            checkOnSave = true,
            check = {
              allFeatures = true,
              allTargets = true,
              command = "clippy",
              extraArgs = { "--no-deps" },
              features = "all",
            },
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
          },
        },
      })

      -- Configure Lua LSP for Neovim configuration (lazydev.nvim handles workspace/globals)
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            telemetry = {
              enable = false,
            },
          },
        },
      })

      -- Configure SQL LSP (generic SQL — sql-language-server)
      vim.lsp.config("sqlls", {
        capabilities = capabilities,
        settings = {
          sqlLanguageServer = {
            lint = {
              rules = {
                ["align-column-to-the-first"] = "error",
                ["column-new-line"] = "error",
                ["linebreak-after-clause-keyword"] = "error",
                ["reserved-word-case"] = "error",
                ["space-surrounding-operators"] = "error",
                ["where-clause-new-line"] = "error",
                ["align-where-clause-to-the-first"] = "error",
              }
            }
          }
        }
      })

      -- Configure Postgres LSP (supabase-community/postgres-language-server)
      -- Attaches only when a `postgres-language-server.jsonc` workspace marker is present.
      vim.lsp.config("postgres_lsp", {
        capabilities = capabilities,
      })

      -- Configure Pyright for Python (type checking only, ruff handles linting/formatting)
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          pyright = {
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              typeCheckingMode = "strict",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      })

      -- Configure ty for Python (type checking by Astral)
      vim.lsp.config("ty", {
        capabilities = capabilities,
      })

      -- Configure Ruff for Python (linting and formatting)
      vim.lsp.config("ruff", {
        capabilities = capabilities,
        init_options = {
          settings = {
            lineLength = 88,
          },
        },
      })

      -- Configure clangd for C/C++.
      --
      -- clangd is useless without a compilation database. It searches the
      -- parents of the edited file and a `build/` subdirectory of each parent,
      -- so a CMake project configured with -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
      -- into `<root>/build/` is found automatically. `<leader>Cg` does that.
      vim.lsp.config("clangd", {
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          -- Cap indexing threads. A monorepo such as azure-sdk-for-cpp has
          -- hundreds of translation units and will otherwise take the machine.
          "--background-index-priority=low",
          "-j=4",
          "--clang-tidy",
          -- `iwyu` guesses an include path from the index and often picks a
          -- private internal header over the public one. Completion still
          -- works; only the automatic `#include` is off.
          "--header-insertion=never",
          "--completion-style=detailed",
          "--all-scopes-completion",
          "--function-arg-placeholders",
          "--pch-storage=memory",
          -- Read the repository .clang-format when formatting through the LSP.
          "--fallback-style=file",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })

      -- Configure sourcekit-lsp for Swift (ships with the Swift toolchain / Xcode).
      --
      -- Do not list c/cpp here and do not use `.git` as a root marker. Both
      -- together made sourcekit attach to every C++ file in any git
      -- repository, alongside clangd, which produced two sets of diagnostics
      -- and two completion sources. Swift interop with C/C++ headers still
      -- works inside a real Swift package.
      vim.lsp.config("sourcekit", {
        capabilities = capabilities,
        cmd = { "xcrun", "sourcekit-lsp" },
        filetypes = { "swift", "objc", "objcpp" },
        root_markers = { "Package.swift", "*.xcodeproj", "*.xcworkspace", "buildServer.json" },
      })

      -- Configure gopls for Go
      vim.lsp.config("gopls", {
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      -- Configure LTeX for grammar/spell checking in markdown and text files
      vim.lsp.config("ltex", {
        capabilities = capabilities,
        filetypes = { "markdown", "text", "gitcommit" },
        settings = {
          ltex = {
            language = "en-US",
          },
        },
      })

      -- Merge nvim-cmp capabilities into the Roslyn C# server. The actual
      -- cmd/filetypes/root_dir and `vim.lsp.enable("roslyn")` are supplied by
      -- the roslyn.nvim plugin (see roslyn.lua); this only augments it.
      vim.lsp.config("roslyn", {
        capabilities = capabilities,
      })

      -- Configure fsautocomplete for F# (cmd/root_markers ship with lspconfig).
      vim.lsp.config("fsautocomplete", {
        capabilities = capabilities,
      })

      -- Enable the configured LSP servers (roslyn is enabled by its own plugin)
      vim.lsp.enable({ "rust_analyzer", "lua_ls", "sqlls", "postgres_lsp", "pyright", "ty", "ruff", "gopls", "clangd", "sourcekit", "ltex", "fsautocomplete" })

      -- Global mappings
      vim.keymap.set("n", "<space>se", function()
        vim.diagnostic.open_float({ max_width = 80, wrap = true })
      end, { desc = "Show diagnostic float" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

      vim.keymap.set("n", "<space>fm", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format code" })

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          -- Buffer local mappings
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set("n", "<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<space>f", function()
            vim.lsp.buf.format { async = true }
          end, opts)

          -- clangd extensions. `switchSourceHeader` is not part of the LSP
          -- specification, so it is requested by hand rather than through
          -- vim.lsp.buf.
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "clangd" then
            vim.keymap.set("n", "<leader>Ch", function()
              local params = vim.lsp.util.make_text_document_params(ev.buf)
              client:request("textDocument/switchSourceHeader", params, function(err, result)
                if err or not result then
                  vim.notify("No matching source or header file", vim.log.levels.WARN)
                  return
                end
                vim.cmd.edit(vim.uri_to_fname(result))
              end, ev.buf)
            end, vim.tbl_extend("force", opts, { desc = "Switch source/header" }))

            vim.keymap.set("n", "<leader>Ci", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
            end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))

            vim.keymap.set("n", "<leader>Cy", function()
              vim.cmd("LspClangdShowSymbolInfo")
            end, vim.tbl_extend("force", opts, { desc = "clangd symbol info" }))
          end
        end,
      })
    end,
  },
}