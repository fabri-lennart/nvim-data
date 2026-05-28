return {

	-- =====================
	-- COLORSCHEME
	-- =====================
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- opciones: latte, frappe, macchiato, mocha
				transparent_background = false,
				term_colors = true,
				styles = {
					comments = { "italic" }, -- igual que tenias en gruvbox
					folds = { "italic" },
					operators = {},
					strings = {},
				},
				integrations = {
					neotree = true,
					alpha = true,
					treesitter = true,
					telescope = true,
					gitsigns = true,
					cmp = true,
					mason = true,
					dap = true,
					dap_ui = true,
					native_lsp = { enabled = true },
					indent_blankline = { enabled = true },
				},
			})
			vim.cmd.colorscheme("catppuccin")
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
					theme = "catppuccin",
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
							filetype = "neo-tree",
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

			-- Colores del dashboard con la paleta de catppuccin
			local colors = require("catppuccin.palettes").get_palette("mocha")
			vim.api.nvim_set_hl(0, "AlphaHeader", { fg = colors.green })
			vim.api.nvim_set_hl(0, "AlphaButtons", { fg = colors.peach })
			vim.api.nvim_set_hl(0, "AlphaFooter", { fg = colors.yellow })

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

			dashboard.section.header.opts.hl = "AlphaHeader"
			dashboard.section.buttons.opts.hl = "AlphaButtons"
			dashboard.section.footer.opts.hl = "AlphaFooter"

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

	-- =====================
	-- FILE EXPLORER (NEO-TREE, lado derecho)
	-- =====================
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true,
				window = {
					position = "right", -- explorador en el lado derecho
					width = 35,
				},
				filesystem = {
					follow_current_file = { enabled = true },
					use_libuv_file_watcher = true,
					filtered_items = {
						hide_dotfiles = false,
						hide_gitignored = false,
					},
				},
			})

			-- Toggle del explorador (Espacio + e)
			vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Explorer (Neo-tree)" })
		end,
	},
}
