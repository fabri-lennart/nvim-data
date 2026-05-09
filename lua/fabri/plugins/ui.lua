return {

	-- =====================
	-- COLORSCHEME
	-- =====================
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			require("gruvbox").setup({
				contrast = "hard",
				transparent_mode = false,
				italic = {
					strings = false,
					comments = true,
					operators = false,
					folds = true,
				},
			})
			vim.cmd("colorscheme gruvbox")
		end,
	},

	-- =====================
	-- STATUS LINE
	-- =====================
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "gruvbox",
					component_separators = "|",
					section_separators = { left = "", right = "" },
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { { "filename", path = 1 } },
					lualine_x = { "encoding", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- =====================
	-- BUFFER TABS
	-- =====================
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",
					separator_style = "slant",
					always_show_bufferline = true,
					show_buffer_close_icons = true,
					show_close_icon = false,
					color_icons = true,
					diagnostics = "nvim_lsp",
					offsets = {
						{
							filetype = "yazi",
							text = "File Explorer",
							highlight = "Directory",
							separator = true,
						},
					},
				},
			})

			local map = vim.keymap.set
			local opts = { noremap = true, silent = true }

			map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", opts)
			map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", opts)
			map("n", "<leader>x", "<cmd>bdelete<cr>", opts)
			map("n", "<leader>X", "<cmd>bdelete!<cr>", opts)
		end,
	},

	-- =====================
	-- INDENT GUIDES
	-- =====================
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("ibl").setup({
				indent = {
					char = "│",
				},
				scope = {
					enabled = true,
					show_start = true,
				},
				exclude = {
					filetypes = { "alpha", "lazy", "mason", "help" },
				},
			})
		end,
	},

	-- =====================
	-- AUTO DETECT TABS VS SPACES
	-- =====================
	{
		"tpope/vim-sleuth",
		-- No config needed, works automatically
		-- Detects indentation style from the file and surrounding files
	},

	-- =====================
	-- DASHBOARD
	-- =====================
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			dashboard.section.header.val = {
				"",
				"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
				"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
				"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
				"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
				"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
				"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
				"",
			}

			dashboard.section.buttons.val = {
				dashboard.button("f", "  Find File", "<cmd>Telescope find_files<cr>"),
				dashboard.button("r", "  Recent Files", "<cmd>Telescope oldfiles<cr>"),
				dashboard.button("g", "  Find Word", "<cmd>Telescope live_grep<cr>"),
				dashboard.button("d", "  Database", "<cmd>DBUIToggle<cr>"),
				dashboard.button("G", "  LazyGit", "<cmd>LazyGit<cr>"),
				dashboard.button("c", "  Config", "<cmd>e $MYVIMRC<cr>"),
				dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
			}

			dashboard.section.footer.val = "fabri's data engineering IDE"

			dashboard.section.header.opts.hl = "GruvboxGreen"
			dashboard.section.buttons.opts.hl = "GruvboxOrange"
			dashboard.section.footer.opts.hl = "GruvboxYellow"

			alpha.setup(dashboard.opts)

			-- Hide statusline and tabline on dashboard
			vim.api.nvim_create_autocmd("User", {
				pattern = "AlphaReady",
				callback = function()
					vim.opt.showtabline = 0
					vim.opt.laststatus = 0
				end,
			})

			-- Restore them when leaving dashboard
			vim.api.nvim_create_autocmd("BufUnload", {
				buffer = 0,
				callback = function()
					vim.opt.showtabline = 2
					vim.opt.laststatus = 3
				end,
			})
		end,
	},
}
