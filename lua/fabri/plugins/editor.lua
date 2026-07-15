-- =====================================================================
-- EDITOR  —  búsqueda, sintaxis y utilidades de edición
-- (which-key -> whichkey.lua ; toggleterm -> terminal.lua ; conform -> lsp.lua)
-- =====================================================================
return {

	-- =====================
	-- FUZZY FINDER
	-- =====================
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					prompt_prefix = "   ",
					selection_caret = "  ",
					path_display = { "smart" },
					file_ignore_patterns = {
						".git/",
						"node_modules/",
						"__pycache__/",
						".venv/",
						".terraform/",
					},
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous,
							["<C-j>"] = actions.move_selection_next,
							["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<Esc>"] = actions.close,
						},
					},
				},
			})

			local map = vim.keymap.set
			local function o(desc)
				return { noremap = true, silent = true, desc = desc }
			end

			map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", o("Buscar archivos"))
			map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", o("Buscar texto (grep)"))
			map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", o("Buscar buffers"))
			map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", o("Buscar en la ayuda"))
			map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", o("Archivos recientes"))
			map("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", o("Buscar palabra bajo cursor"))
		end,
	},

	-- =====================
	-- SYNTAX PARSING
	-- =====================
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		priority = 900,
		config = function()
			require("nvim-treesitter.config").setup({
				ensure_installed = {
					"lua",
					"python",
					"sql",
					"go",
					"dockerfile",
					"yaml",
					"json",
					"toml",
					"bash",
					"markdown",
					"markdown_inline",
					"csv",
					"hcl", -- Terraform
					"jinja", -- dbt / Airflow templates
				},
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- =====================
	-- AUTO CLOSE BRACKETS
	-- =====================
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({ check_ts = true })

			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	-- =====================
	-- FAST NAVIGATION
	-- =====================
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		config = function()
			require("flash").setup({ modes = { search = { enabled = false } } })

			local map = vim.keymap.set
			local opts = { noremap = true, silent = true }

			map({ "n", "x", "o" }, "s", function()
				require("flash").jump()
			end, opts)
			map({ "n", "x", "o" }, "S", function()
				require("flash").treesitter()
			end, opts)
		end,
	},

	-- =====================
	-- TODO HIGHLIGHTS
	-- =====================
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({
				signs = true,
				keywords = {
					FIX = { icon = " ", color = "error" },
					TODO = { icon = " ", color = "info" },
					NOTE = { icon = " ", color = "hint" },
					WARN = { icon = " ", color = "warning" },
					DATA = { icon = " ", color = "info" },
				},
			})

			vim.keymap.set(
				"n",
				"<leader>ft",
				"<cmd>TodoTelescope<cr>",
				{ noremap = true, silent = true, desc = "Buscar TODOs" }
			)
		end,
	},
}
