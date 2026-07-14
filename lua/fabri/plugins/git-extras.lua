return {
  -- Diffs, historial de archivos y resolución visual de conflictos
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git: diff de cambios" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git: historial del archivo" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Git: historial del repo" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Git: cerrar diffview" },
    },
    opts = {},
  },

  -- Grafo de ramas/commits (topología) integrado con diffview
  {
    "isakbm/gitgraph.nvim",
    dependencies = { "sindrets/diffview.nvim" },
    keys = {
      {
        "<leader>gl",
        function()
          require("gitgraph").draw({}, { all = true, max_count = 5000 })
        end,
        desc = "Git: grafo de ramas",
      },
    },
    opts = {
      hooks = {
        on_select_commit = function(commit)
          vim.cmd("DiffviewOpen " .. commit.hash .. "^!")
        end,
        on_select_range_commit = function(from, to)
          vim.cmd("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
        end,
      },
    },
  },
}
