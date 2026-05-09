return {

  -- =====================
  -- GIT SIGNS IN GUTTER
  -- =====================
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = vim.keymap.set
          local opts = { noremap = true, silent = true, buffer = bufnr }

          map("n", "<leader>gs", gs.stage_hunk, opts)
          map("n", "<leader>gr", gs.reset_hunk, opts)
          map("n", "<leader>gp", gs.preview_hunk, opts)
          map("n", "<leader>gb", gs.blame_line, opts)
          map("n", "<leader>gd", gs.diffthis, opts)
          map("n", "]g", gs.next_hunk, opts)
          map("n", "[g", gs.prev_hunk, opts)
        end,
      })
    end,
  },

  -- =====================
  -- LAZYGIT FLOATING TUI
  -- =====================
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set(
        "n",
        "<leader>gg",
        "<cmd>LazyGit<cr>",
        { noremap = true, silent = true, desc = "Open LazyGit" }
      )
    end,
  },
}
