return {

  -- =====================
  -- LSP SERVER INSTALLER
  -- =====================
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed   = "✓",
            package_pending     = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      vim.keymap.set("n", "<leader>lm", "<cmd>Mason<cr>",
        { noremap = true, silent = true, desc = "Open Mason" })
    end,
  },

  -- =====================
  -- MASON <-> NVIM LSP BRIDGE
  -- =====================
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",   -- Python
          "gopls",     -- Go
          "lua_ls",    -- Lua (for editing this config)
          "dockerls",  -- Dockerfile
          "yamlls",    -- YAML (dbt, docker-compose)
          "jsonls",    -- JSON
        },
        automatic_installation = true,
      })

      -- Keymaps that activate when any LSP attaches to a buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = vim.keymap.set
          local opts = { noremap = true, silent = true, buffer = args.buf }

          map("n", "gd",          vim.lsp.buf.definition,    opts)
          map("n", "gr",          vim.lsp.buf.references,    opts)
          map("n", "K",           vim.lsp.buf.hover,         opts)
          map("n", "<leader>lr",  vim.lsp.buf.rename,        opts)
          map("n", "<leader>la",  vim.lsp.buf.code_action,   opts)
          map("n", "<leader>ld",  vim.diagnostic.open_float, opts)
          map("n", "[d",          vim.diagnostic.goto_prev,  opts)
          map("n", "]d",          vim.diagnostic.goto_next,  opts)
          map("n", "<leader>lf",  function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })

      -- Server-specific settings using nvim 0.11 new API
      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode    = "basic",
              autoSearchPaths     = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }, -- stop lua_ls flagging 'vim' as undefined
            },
            workspace = {
              library       = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
          },
        },
      })

      -- Enable all servers
      vim.lsp.enable({
        "pyright",
        "gopls",
        "lua_ls",
        "dockerls",
        "yamlls",
        "jsonls",
      })

      -- Diagnostic display config
      vim.diagnostic.config({
        virtual_text    = true,
        signs           = true,
        underline       = true,
        update_in_insert = false,
        float = {
          border = "rounded",
          source = true,
        },
      })
    end,
  },

  -- =====================
  -- AUTOCOMPLETION
  -- =====================
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"]     = cmp.mapping.select_prev_item(),
          ["<C-j>"]     = cmp.mapping.select_next_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "vim-dadbod-completion" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}
