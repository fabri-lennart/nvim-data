-- =====================================================================
-- GIT  —  signos en el gutter, LazyGit, diffview e historial
-- =====================================================================
return {

	-- =====================
	-- GITSIGNS — cambios en tiempo real, stage por hunks y blame
	-- =====================
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "▎" },
					change = { text = "▎" },
					delete = { text = "" },
					topdelete = { text = "" },
					changedelete = { text = "▎" },
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local map = vim.keymap.set
					local function o(desc)
						return { noremap = true, silent = true, buffer = bufnr, desc = desc }
					end

					map("n", "<leader>gs", gs.stage_hunk, o("Stage hunk"))
					map("n", "<leader>gr", gs.reset_hunk, o("Reset hunk"))
					map("n", "<leader>gp", gs.preview_hunk, o("Preview hunk"))
					map("n", "<leader>gb", gs.blame_line, o("Blame de la línea"))
					map("n", "<leader>gD", gs.diffthis, o("Diff del archivo actual"))
					map("n", "]g", gs.next_hunk, o("Hunk siguiente"))
					map("n", "[g", gs.prev_hunk, o("Hunk anterior"))
				end,
			})
		end,
	},

	-- =====================
	-- LAZYGIT — TUI flotante para commits, ramas, stash, etc.
	-- =====================
	{
		"kdheepak/lazygit.nvim",
		cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit (flotante)" },
		},
	},

	-- =====================
	-- DIFFVIEW — diffs, historial y resolución de conflictos
	-- =====================
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff de cambios" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Historial del archivo" },
			{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Historial del repo" },
			{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Cerrar diffview" },
		},
		opts = {},
	},

	-- =====================
	-- GITGRAPH — grafo de ramas/commits integrado con diffview
	-- =====================
	{
		"isakbm/gitgraph.nvim",
		dependencies = { "sindrets/diffview.nvim" },
		keys = {
			{
				"<leader>gl",
				function()
					require("gitgraph").draw({}, { all = true, max_count = 5000 })
				end,
				desc = "Grafo de ramas",
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
