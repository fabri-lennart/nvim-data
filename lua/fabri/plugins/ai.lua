return {
  -- =====================
  -- AI AUTOCOMPLETE (Supermaven — gratis, rápido)
  -- =====================
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    cmd = {
      "SupermavenUseFree",
      "SupermavenUsePro",
      "SupermavenStatus",
      "SupermavenRestart",
      "SupermavenLogout",
    },
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<C-g>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-l>",
        },
      })
    end,
  },
}
