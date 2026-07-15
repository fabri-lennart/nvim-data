return {

	-- =====================
	-- COLORSCHEME (Nord)
	-- =====================
	{
		"AlexvZyl/nordic.nvim",
		priority = 1000,
		config = function()
			require("nordic").setup({
				bold_keywords = false,
				italic_comments = true,
				transparent = {
					bg = false,
					float = false,
				},
				reduced_blue = true,
				cursorline = {
					theme = "dark",
					blend = 0.85,
				},
				telescope = { style = "flat" },
			})
			require("nordic").load()

			-- ---------------------------------------------------------------
			-- Transparency toggle
			-- Hot-swaps the editor background on/off. Theme-agnostic: it strips
			-- the background from the relevant highlight groups while keeping
			-- foregrounds intact, and reloads Nord to restore the original look.
			-- ---------------------------------------------------------------
			local transparent = false

			local groups = {
				"Normal",
				"NormalNC",
				"NormalFloat",
				"FloatBorder",
				"SignColumn",
				"EndOfBuffer",
				"MsgArea",
				"LineNr",
				"CursorLineNr",
				"NeoTreeNormal",
				"NeoTreeNormalNC",
				"NeoTreeEndOfBuffer",
				"TelescopeNormal",
				"TelescopeBorder",
				"WhichKeyFloat",
			}

			local function set_transparency(enabled)
				transparent = enabled
				if enabled then
					for _, g in ipairs(groups) do
						local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
						hl.bg = nil
						hl.ctermbg = nil
						hl.link = nil
						vim.api.nvim_set_hl(0, g, hl)
					end
				else
					-- Reload Nord to restore every original background
					require("nordic").load()
				end
			end

			vim.api.nvim_create_user_command("ToggleTransparency", function()
				set_transparency(not transparent)
				vim.notify("Transparency " .. (transparent and "ON" or "OFF"), vim.log.levels.INFO)
			end, { desc = "Toggle background transparency" })

			vim.keymap.set(
				"n",
				"<leader>ut",
				"<cmd>ToggleTransparency<cr>",
				{ noremap = true, silent = true, desc = "Toggle transparency" }
			)
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
					theme = "nordic",
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

			-- Colores del dashboard con la paleta de Nord (frost + aurora)
			vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#88C0D0" })
			vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#81A1C1" })
			vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#EBCB8B" })

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

			-- Centrar el dashboard verticalmente (padding superior dinámico)
			local function alpha_content_height()
				local h = 0
				for i = 2, #dashboard.opts.layout do
					local el = dashboard.opts.layout[i]
					if el.type == "padding" then
						h = h + (type(el.val) == "function" and el.val() or el.val)
					elseif el.type == "text" then
						h = h + (type(el.val) == "table" and #el.val or 1)
					elseif el.type == "group" then
						local n = #el.val
						local sp = (el.opts and el.opts.spacing) or 0
						h = h + n + math.max(0, n - 1) * sp
					else
						h = h + 1
					end
				end
				return h
			end

			dashboard.opts.layout[1].val = function()
				return math.max(1, math.floor((vim.api.nvim_win_get_height(0) - alpha_content_height()) / 2))
			end

			alpha.setup(dashboard.opts)

			-- Re-centrar el dashboard al redimensionar la ventana
			vim.api.nvim_create_autocmd("VimResized", {
				callback = function()
					if vim.bo.filetype == "alpha" then
						vim.cmd("AlphaRedraw")
					end
				end,
			})

			-- Hide statusline and tabline on dashboard
			vim.api.nvim_create_autocmd("User", {
				pattern = "AlphaReady",
				callback = function()
					vim.opt.showtabline = 0
					vim.opt.laststatus = 0
					vim.cmd("AlphaRedraw")
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
