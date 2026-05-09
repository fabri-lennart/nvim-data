return {

	-- =====================
	-- DAP CORE
	-- =====================
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")
			local map = vim.keymap.set
			local opts = { noremap = true, silent = true }

			-- Main debug flow (F keys are standard across all IDEs)
			map("n", "<F5>", dap.continue, opts) -- start / continue
			map("n", "<F10>", dap.step_over, opts) -- step over
			map("n", "<F11>", dap.step_into, opts) -- step into
			map("n", "<F12>", dap.step_out, opts) -- step out

			-- Breakpoints under <leader>D
			map("n", "<leader>Db", dap.toggle_breakpoint, opts)
			map("n", "<leader>DB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, opts)
			map("n", "<leader>Dl", function()
				dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end, opts)
			map("n", "<leader>Dr", dap.repl.open, opts)
			map("n", "<leader>Dx", dap.terminate, opts)
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

			vim.keymap.set("n", "<leader>Du", dapui.toggle, { noremap = true, silent = true, desc = "Toggle debug UI" })
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
			local opts = { noremap = true, silent = true }

			map("n", "<leader>Dm", require("dap-python").test_method, opts)
			map("n", "<leader>Dc", require("dap-python").test_class, opts)
			map("v", "<leader>Ds", require("dap-python").debug_selection, opts)
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
				"<leader>Dt",
				require("dap-go").debug_test,
				{ noremap = true, silent = true, desc = "Debug Go test" }
			)
		end,
	},
}
