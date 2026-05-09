return {

  -- =====================
  -- AI ASSISTANT
  -- =====================
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "anthropic",
          },
          inline = {
            adapter = "anthropic",
          },
        },
        adapters = {
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                -- Set ANTHROPIC_API_KEY in your shell environment
                api_key = "ANTHROPIC_API_KEY",
              },
              schema = {
                model = {
                  default = "claude-sonnet-4-20250514",
                },
              },
            })
          end,
        },
        display = {
          chat = {
            window = {
              layout = "vertical",
              width = 0.35,
            },
          },
        },
      })

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>",  opts)
      map({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionChat Add<cr>",     opts)
      map("n",          "<leader>ai", "<cmd>CodeCompanion<cr>",             opts)
    end,
  },
}
