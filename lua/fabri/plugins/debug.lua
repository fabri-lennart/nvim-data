return {

	-- =====================
	-- DAP CORE
	-- =====================
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")
			local map = vim.keymap.set

			-- Build a { noremap, silent, desc } table so which-key shows the label
			local function d(desc)
				return { noremap = true, silent = true, desc = desc }
			end

			-- Main debug flow (F keys are standard across all IDEs)
			map("n", "<F5>", dap.continue, d("Debug: continuar")) -- start / continue
			map("n", "<F10>", dap.step_over, d("Debug: step over")) -- step over
			map("n", "<F11>", dap.step_into, d("Debug: step into")) -- step into
			map("n", "<F12>", dap.step_out, d("Debug: step out")) -- step out

			-- Debug controls under <leader>d
			map("n", "<leader>dc", dap.continue, d("Continuar / iniciar"))
			map("n", "<leader>di", dap.step_into, d("Step into (entrar)"))
			map("n", "<leader>do", dap.step_over, d("Step over (siguiente línea)"))
			map("n", "<leader>dO", dap.step_out, d("Step out (salir)"))
			map("n", "<leader>dt", dap.toggle_breakpoint, d("Toggle breakpoint"))
			map("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Condición del breakpoint: "))
			end, d("Breakpoint condicional"))
			map("n", "<leader>dP", function()
				dap.set_breakpoint(nil, nil, vim.fn.input("Mensaje de log point: "))
			end, d("Log point"))
			map("n", "<leader>dr", dap.repl.open, d("Abrir REPL / consola"))
			map("n", "<leader>dx", dap.terminate, d("Terminar sesión"))
		end,
	},

	-- =====================
	-- DAP UI (visual debugger interface)
	-- =====================
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup({
				layouts = {
					{
						-- Left panel: scopes + breakpoints + stacks
						elements = {
							{ id = "scopes", size = 0.4 },
							{ id = "breakpoints", size = 0.2 },
							{ id = "stacks", size = 0.2 },
							{ id = "watches", size = 0.2 },
						},
						size = 40,
						position = "left",
					},
					{
						-- Bottom panel: repl + console output
						elements = {
							{ id = "repl", size = 0.5 },
							{ id = "console", size = 0.5 },
						},
						size = 12,
						position = "bottom",
					},
				},
			})

			-- Auto open/close UI when debug session starts/ends
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			vim.keymap.set("n", "<leader>du", dapui.toggle, { noremap = true, silent = true, desc = "Toggle panel de debug (UI)" })
		end,
	},

	-- =====================
	-- PYTHON DEBUGGER
	-- =====================
	{
		"mfussenegger/nvim-dap-python",
		dependencies = { "mfussenegger/nvim-dap" },
		ft = "python", -- only loads when you open a .py file
		config = function()
			-- Points to the debugpy installed in your system Python
			-- Run: pip install debugpy
			require("dap-python").setup("python")

			local map = vim.keymap.set

			map("n", "<leader>dm", require("dap-python").test_method, { noremap = true, silent = true, desc = "Python: debug test method" })
			map("n", "<leader>dC", require("dap-python").test_class, { noremap = true, silent = true, desc = "Python: debug test class" })
			map("v", "<leader>ds", require("dap-python").debug_selection, { noremap = true, silent = true, desc = "Python: debug selección" })
		end,
	},

	-- =====================
	-- GO DEBUGGER
	-- =====================
	{
		"leoluz/nvim-dap-go",
		dependencies = { "mfussenegger/nvim-dap" },
		ft = "go",
		config = function()
			require("dap-go").setup()

			vim.keymap.set(
				"n",
				"<leader>dT",
				require("dap-go").debug_test,
				{ noremap = true, silent = true, desc = "Go: debug test" }
			)
		end,
	},

	-- =====================
	-- LUA DEBUGGER (for Neovim Lua development)
	-- =====================
	{
		"jbyuki/one-small-step-for-vimkind",
		dependencies = { "mfussenegger/nvim-dap" },
		ft = "lua",
		config = function()
			local dap = require("dap")

			-- Adapter: attaches to a Neovim instance running the OSV server
			dap.adapters.nlua = function(callback, config)
				callback({
					type = "server",
					host = config.host or "127.0.0.1",
					port = config.port or 8086,
				})
			end

			dap.configurations.lua = {
				{
					type = "nlua",
					request = "attach",
					name = "Attach to running Neovim instance",
				},
			}

			local map = vim.keymap.set
			local opts = { noremap = true, silent = true }

			-- Launch the debug server inside THIS Neovim instance,
			-- then hit <F5> to attach and start stepping through your Lua.
			map("n", "<leader>dl", function()
				require("osv").launch({ port = 8086 })
			end, vim.tbl_extend("force", opts, { desc = "Lua: lanzar servidor de debug" }))
		end,
	},
}
