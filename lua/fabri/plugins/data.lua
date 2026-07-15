-- =====================================================================
-- DATA & WORKFLOW
-- SQL (Dadbod) · REST (Kulala) · dbt · Markdown · CSV · venv · Jupyter (Molten)
-- =====================================================================
return {

	-- =====================
	-- SQL — motor de base de datos (Dadbod)
	-- =====================
	{
		"tpope/vim-dadbod",
		lazy = true,
	},

	-- =====================
	-- SQL — interfaz de base de datos (Dadbod UI) bajo <leader>b
	-- =====================
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			"tpope/vim-dadbod",
			"kristijanhusak/vim-dadbod-completion",
		},
		cmd = { "DBUI", "DBUIToggle", "DBUIFindBuffer", "DBUIRenameBuffer", "DBUILastQueryInfo" },
		-- init corre al arranque (antes de cargar el plugin): deja listas las globals
		init = function()
			-- Las cadenas de conexión viven en un archivo local, nunca en git
			vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_show_database_icon = 1
			vim.g.db_ui_force_echo_notifications = 1
			vim.g.db_ui_win_position = "left"
			vim.g.db_ui_winwidth = 40

			-- Formatos de conexión soportados:
			-- DuckDB:    duckdb:///path/to/file.db
			-- Snowflake: snowflake://user:pass@account/db
			-- Postgres:  postgresql://user:pass@host/db
		end,
		-- keys los registra lazy y carga el plugin bajo demanda al pulsarlos
		keys = {
			{ "<leader>bt", "<cmd>DBUIToggle<cr>", desc = "DB: toggle UI" },
			{ "<leader>bf", "<cmd>DBUIFindBuffer<cr>", desc = "DB: find buffer" },
			{ "<leader>br", "<cmd>DBUIRenameBuffer<cr>", desc = "DB: renombrar buffer" },
			{ "<leader>bl", "<cmd>DBUILastQueryInfo<cr>", desc = "DB: última query" },
		},
	},

	-- =====================
	-- REST CLIENT — Kulala (peticiones HTTP/GraphQL desde archivos .http/.rest)
	-- Crea un .http, escribe la request y dispárala con <leader>Rs
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
	-- dbt — correr/testear modelos desde el editor (dbtpal)
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
	-- MARKDOWN-PREVIEW — previsualiza README/*.md en el navegador en vivo
	-- =====================
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown: toggle preview" },
		},
		config = function()
			vim.g.mkdp_auto_close = 1
			vim.g.mkdp_theme = "dark"
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
	-- RAINBOW_CSV — colorea cada columna de un CSV/TSV + consultas RBQL
	-- =====================
	{
		"cameron-wags/rainbow_csv.nvim",
		config = true,
		ft = { "csv", "tsv", "csv_semicolon", "csv_whitespace", "csv_pipe", "rfc_csv", "rfc_semicolon" },
		cmd = { "RainbowDelim", "RainbowDelimSimple", "RainbowDelimQuoted", "RainbowMultiDelim" },
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

	-- =====================
	-- JUPYTER — Molten (evaluar código Python de forma interactiva)
	-- Requiere: pip install pynvim jupyter_client ipykernel  (+ :UpdateRemotePlugins)
	-- Salida en texto/virt-text por defecto (estable en cualquier terminal).
	-- =====================
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		build = ":UpdateRemotePlugins",
		ft = "python",
		cmd = {
			"MoltenInit",
			"MoltenEvaluateLine",
			"MoltenEvaluateVisual",
			"MoltenEvaluateOperator",
			"MoltenReevaluateCell",
		},
		init = function()
			vim.g.molten_image_provider = "none" -- sin backend de imágenes = máxima estabilidad
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = false
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = true
		end,
		keys = {
			{ "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Molten: iniciar kernel" },
			{ "<leader>je", "<cmd>MoltenEvaluateOperator<cr>", desc = "Molten: evaluar (operator)" },
			{ "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Molten: evaluar línea" },
			{ "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Molten: reevaluar celda" },
			{ "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Molten: borrar celda" },
			{ "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Molten: mostrar salida" },
			{ "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Molten: ocultar salida" },
			{ "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Molten: evaluar selección" },
		},
	},
}
