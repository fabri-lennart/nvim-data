return {
	-- =====================
	-- KULALA — cliente HTTP/REST/GraphQL para probar tus endpoints
	-- OJO: requiere Neovim 0.12+ y curl. Revisa con: nvim --version
	-- Crea un archivo .http, escribe la request y dispara con <leader>Rs
	-- =====================
	{
		"mistweaverco/kulala.nvim",
		ft = { "http", "rest" },
		opts = {
			global_keymaps = false,
			kulala_keymaps_prefix = "",
		},
		keys = {
			{ "<leader>Rs", "<cmd>lua require('kulala').run()<cr>", ft = { "http", "rest" }, desc = "Kulala: enviar request" },
			{ "<leader>Ra", "<cmd>lua require('kulala').run_all()<cr>", ft = { "http", "rest" }, desc = "Kulala: enviar todas" },
			{ "<leader>Rb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Kulala: scratchpad" },
			{ "<leader>Rc", "<cmd>lua require('kulala').copy()<cr>", ft = { "http", "rest" }, desc = "Kulala: copiar como cURL" },
			{ "<leader>RC", "<cmd>lua require('kulala').from_curl()<cr>", ft = { "http", "rest" }, desc = "Kulala: pegar desde cURL" },
			{ "<leader>Re", "<cmd>lua require('kulala').set_selected_env()<cr>", ft = { "http", "rest" }, desc = "Kulala: elegir entorno" },
		},
	},

	-- =====================
	-- DBTPAL — correr/testear modelos dbt desde el editor
	-- =====================
	{
		"PedramNavid/dbtpal",
		ft = { "sql", "jinja", "yaml", "md" },
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
		config = function()
			local dbt = require("dbtpal")
			dbt.setup({
				path_to_dbt = "dbt",
				path_to_dbt_project = "",
				path_to_dbt_profiles_dir = vim.fn.expand("~/.dbt"),
				extended_path_search = true,
				protect_compiled_files = true,
			})

			local map = vim.keymap.set
			map("n", "<leader>mr", dbt.run, { desc = "dbt: run modelo abierto" })
			map("n", "<leader>mR", dbt.run_all, { desc = "dbt: run proyecto" })
			map("n", "<leader>mt", dbt.test, { desc = "dbt: test modelo abierto" })

			require("telescope").load_extension("dbtpal")
		end,
	},

	-- =====================
	-- CSVVIEW — ver CSV/TSV alineado en columnas
	-- =====================
	{
		"hat0uma/csvview.nvim",
		ft = { "csv", "tsv" },
		cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
		opts = { view = { display_mode = "border" }, parser = { comments = { "#", "//" } } },
		keys = { { "<leader>cs", "<cmd>CsvViewToggle<cr>", desc = "CSV: vista en tabla" } },
	},

	-- =====================
	-- VENV-SELECTOR — elegir venv/conda de Python al vuelo
	-- =====================
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
		ft = "python",
		cmd = "VenvSelect",
		opts = {},
		keys = { { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Python: venv/conda" } },
	},
}
