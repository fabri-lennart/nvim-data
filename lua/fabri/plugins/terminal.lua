return {
	-- =====================
	-- TERMINAL FLOTANTE + LAZYGIT + LAZYDOCKER
	-- =====================
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("toggleterm").setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return math.floor(vim.o.columns * 0.4)
					end
				end,
				open_mapping = [[<c-\>]],
				hide_numbers = true,
				shade_terminals = true,
				start_in_insert = true,
				persist_size = true,
				persist_mode = true,
				direction = "float",
				close_on_exit = true,
				float_opts = {
					border = "curved",
					width = function() return math.floor(vim.o.columns * 0.85) end,
					height = function() return math.floor(vim.o.lines * 0.85) end,
					winblend = 0,
				},
			})

			local Terminal = require("toggleterm.terminal").Terminal

			-- Terminal flotante de propósito general
			local float_term = Terminal:new({ direction = "float", hidden = true })

			-- LazyGit (interfaz para commits, ramas, stash, etc.)
			local lazygit = Terminal:new({
				cmd = "lazygit",
				direction = "float",
				hidden = true,
				on_open = function() vim.cmd("startinsert!") end,
			})

			-- LazyDocker (gestión visual de contenedores)
			local lazydocker = Terminal:new({
				cmd = "lazydocker",
				direction = "float",
				hidden = true,
				on_open = function() vim.cmd("startinsert!") end,
			})

			local map = vim.keymap.set
			map("n", "<leader>tt", function() float_term:toggle() end, { desc = "Terminal flotante" })
			map("n", "<leader>tg", function() lazygit:toggle() end, { desc = "LazyGit" })
			map("n", "<leader>td", function() lazydocker:toggle() end, { desc = "LazyDocker (contenedores)" })
			map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal horizontal" })
			map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal vertical" })

			-- Que el botón "LazyGit" del dashboard también funcione,
			-- sin pisar el comando si ya lo provee otro plugin (git.lua)
			if vim.fn.exists(":LazyGit") == 0 then
				vim.api.nvim_create_user_command("LazyGit", function() lazygit:toggle() end, {})
			end

			-- Atajos cómodos dentro del modo terminal
			local function set_terminal_keymaps()
				local opts = { buffer = 0 }
				map("t", "<esc>", [[<C-\><C-n>]], opts)
				map("t", "jk", [[<C-\><C-n>]], opts)
				map("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
				map("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
				map("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
				map("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
			end

			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "term://*toggleterm#*",
				callback = set_terminal_keymaps,
			})
		end,
	},
}
