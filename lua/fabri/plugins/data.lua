return {

  -- =====================
  -- DATABASE ENGINE
  -- =====================
  {
    "tpope/vim-dadbod",
    lazy = true,
  },

  -- =====================
  -- DATABASE UI
  -- =====================
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      -- Connection strings live in a local env file, never committed to git
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 40

      -- Supported connection string formats:
      -- DuckDB:    duckdb:///path/to/file.db
      -- Snowflake: snowflake://user:pass@account/db
      -- Postgres:  postgresql://user:pass@host/db

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map("n", "<leader>db", "<cmd>DBUIToggle<cr>",       opts)
      map("n", "<leader>df", "<cmd>DBUIFindBuffer<cr>",   opts)
      map("n", "<leader>dr", "<cmd>DBUIRenameBuffer<cr>", opts)
      map("n", "<leader>dl", "<cmd>DBUILastQueryInfo<cr>", opts)
    end,
  },
}
