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
			local opts = { noremap = true, silent = true }

			map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
			map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opts)
			map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts)
			map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opts)
			map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", opts)
			map("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", opts)
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
					"hcl",
					"jinja",
				},
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- =====================
	-- KEYMAP GUIDE
	-- =====================
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")

			wk.setup({
				preset = "modern",
				-- Pop up the hint window the instant <leader> (space) is pressed
				delay = 0,
			})

			wk.add({
				-- Leader groups (with icons for a cleaner popup)
				{ "<leader>f", group = "find", icon = "" },
				{ "<leader>s", group = "splits", icon = "" },
				{ "<leader>g", group = "git", icon = "" },
				{ "<leader>d", group = "debug", icon = "" },
				{ "<leader>b", group = "database", icon = "" },
				{ "<leader>l", group = "lsp", icon = "" },
				{ "<leader>t", group = "terminal", icon = "" },
				{ "<leader>a", group = "ai", icon = "󰚩" },
				{ "<leader>e", group = "explorer", icon = "" },
				{ "<leader>u", group = "ui / toggles", icon = "" },
				{ "<leader>c", group = "code / formato", icon = "" },
				{ "<leader>m", group = "dbt / markdown", icon = "" },
				{ "<leader>R", group = "http (kulala)", icon = "󱂛" },

				-- Splits: create + resize kept together under <leader>s
				{ "<leader>sv", desc = "Split vertically", icon = "" },
				{ "<leader>sh", desc = "Split horizontally", icon = "" },

				-- Debug (nvim-dap) — iconografía limpia para el menú flotante
				{ "<leader>dt", desc = "Toggle breakpoint", icon = "" },
				{ "<leader>dc", desc = "Continuar / iniciar", icon = "" },
				{ "<leader>di", desc = "Step into (entrar)", icon = "" },
				{ "<leader>do", desc = "Step over (siguiente)", icon = "" },
				{ "<leader>dO", desc = "Step out (salir)", icon = "" },
				{ "<leader>dr", desc = "Abrir REPL / consola", icon = "" },
				{ "<leader>dB", desc = "Breakpoint condicional", icon = "" },
				{ "<leader>dP", desc = "Log point", icon = "" },
				{ "<leader>dx", desc = "Terminar sesión", icon = "" },
				{ "<leader>du", desc = "Panel de debug (UI)", icon = "" },

				-- Window navigation (Ctrl+hjkl) — always visible as a hint group.
				-- Registered as a documentation group so pressing <C-w> or browsing
				-- with :WhichKey surfaces the split movement/resize combos.
				{
					mode = { "n" },
					{ "<C-h>", desc = "Window: move left", icon = "" },
					{ "<C-j>", desc = "Window: move down", icon = "" },
					{ "<C-k>", desc = "Window: move up", icon = "" },
					{ "<C-l>", desc = "Window: move right", icon = "" },
					{ "<C-Up>", desc = "Window: taller", icon = "" },
					{ "<C-Down>", desc = "Window: shorter", icon = "" },
					{ "<C-Left>", desc = "Window: narrower", icon = "" },
					{ "<C-Right>", desc = "Window: wider", icon = "" },
				},
			})
		end,
	},

	-- =====================
	-- TERMINAL + LAZYDOCKER
	-- =====================
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
				open_mapping = [[<C-\>]],
				direction = "float",
				float_opts = { border = "curved" },
				shade_terminals = true,
			})

			local map = vim.keymap.set
			local opts = { noremap = true, silent = true }

			map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", opts)
			map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", opts)
			map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", opts)
			map("t", "<Esc>", [[<C-\><C-n>]], opts)

			-- LazyDocker floating terminal
			local Terminal = require("toggleterm.terminal").Terminal
			local lazydocker = Terminal:new({
				cmd = "lazydocker",
				hidden = true,
				direction = "float",
				float_opts = { border = "curved" },
			})

			map("n", "<leader>td", function()
				lazydocker:toggle()
			end, { noremap = true, silent = true, desc = "Open LazyDocker" })
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
	-- FORMAT ON SAVE
	-- =====================
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					-- Ruff: sorts imports first, then formats (drop-in for black + isort)
					python = { "ruff_organize_imports", "ruff_format" },
					lua = { "stylua" },
					sql = { "sqlfmt" },
					sh = { "shfmt" },
					bash = { "shfmt" },
					terraform = { "terraform_fmt" },
					yaml = { "prettier" },
                                        ["yaml.github"] = { "prettier" },
					json = { "prettier" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true,
				},
			})

			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				require("conform").format({ async = true, lsp_fallback = true })
			end, { noremap = true, silent = true, desc = "Format file" })
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
				{ noremap = true, silent = true, desc = "Find TODOs" }
			)
		end,
	},
}
