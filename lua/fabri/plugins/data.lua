-- =====================================================================
-- DATA & WORKFLOW
-- SQL (Dadbod) · REST (Kulala) · dbt · Markdown · CSV · venv · Jupyter (Molten)
-- =====================================================================
--
-- ┌───────────────────────────────────────────────────────────────────┐
-- │  FLUJO DE NOTEBOOKS / CELDAS (lo que necesitas saber como datero)   │
-- ├───────────────────────────────────────────────────────────────────┤
-- │                                                                     │
-- │  1) ¿QUÉ archivos?                                                  │
-- │     • .py  con celdas marcadas por  "# %%"  (formato "percent").    │
-- │     • .ipynb → jupytext lo abre COMO python con celdas "# %%",      │
-- │       lo editas normal y al guardar (:w) se re-escribe el .ipynb.   │
-- │                                                                     │
-- │  2) ¿QUÉ pongo al inicio del archivo? (la "config de cada archivo") │
-- │     Nada obligatorio. El patrón típico de un script de análisis:    │
-- │                                                                     │
-- │        # %%  ← primera celda: imports                              │
-- │        import pandas as pd                                          │
-- │        import matplotlib.pyplot as plt                              │
-- │                                                                     │
-- │        # %%  ← segunda celda: cargar datos                         │
-- │        df = pd.read_csv("data.csv")                                 │
-- │        df.head()                                                    │
-- │                                                                     │
-- │        # %%  ← tercera celda: un plot                              │
-- │        df["col"].hist(); plt.show()                                 │
-- │                                                                     │
-- │     Cada "# %%" ABRE una celda nueva. No necesitas cerrarla.        │
-- │     (Inserta una rápido con  <leader>jb )                           │
-- │                                                                     │
-- │  3) ¿CÓMO ejecuto?                                                  │
-- │     a. <leader>ji  → arranca/elige el kernel (UNA vez por sesión).  │
-- │     b. Párate dentro de una celda y <leader>jc → ejecuta la celda.  │
-- │        (o <leader>jl línea suelta, o selecciona y <leader>jv)       │
-- │                                                                     │
-- │  4) ¿DÓNDE se ve lo renderizado?                                   │
-- │     • TEXTO (prints, df.head(), shapes): aparece como texto         │
-- │       "virtual" JUSTO DEBAJO de la celda, en el mismo buffer.       │
-- │     • PLOTS / imágenes: se dibujan en la VENTANA DE SALIDA de       │
-- │       Molten. Ábrela con <leader>jo (ciérrala con <leader>jh).      │
-- │       Ghostty habla el protocolo Kitty, así que la imagen se ve     │
-- │       de verdad, no como texto. (Requiere ImageMagick, ver README.) │
-- │                                                                     │
-- └───────────────────────────────────────────────────────────────────┘

-- ─────────────────────────────────────────────────────────────────────
-- Helpers para trabajar con celdas "# %%" desde Molten.
-- Se definen aquí (ámbito del módulo) y se referencian abajo en `keys`.
-- ─────────────────────────────────────────────────────────────────────
-- Patrón que delimita una celda (permite indentación y "# %%" o "#%%").
local CELL = [[^\s*#\s*%%]]

-- Simula pulsaciones reales (igual que si las tecleara el usuario).
local function feed(keys)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "nx", false)
end

-- Ejecuta la celda donde está el cursor (bloque entre dos "# %%").
local function molten_eval_cell()
	-- Límite superior: línea del "# %%" anterior (o inicio del archivo).
	local top = vim.fn.search(CELL, "bcnW")
	top = (top == 0) and 1 or (top + 1)
	-- Límite inferior: línea antes del próximo "# %%" (o fin del archivo).
	local nxt = vim.fn.search(CELL, "nW")
	local bot = (nxt == 0) and vim.fn.line("$") or (nxt - 1)
	-- Selecciona la celda en visual-línea y la evalúa (mismo camino que <leader>jv).
	feed(("%dGV%dG:<C-u>MoltenEvaluateVisual<CR>"):format(top, bot))
end

-- Navegación entre celdas.
local function molten_next_cell()
	vim.fn.search(CELL, "W")
end
local function molten_prev_cell()
	vim.fn.search(CELL, "bW")
end

-- Inserta un delimitador de celda debajo y deja el cursor dentro.
local function molten_insert_cell()
	vim.api.nvim_put({ "", "# %%", "" }, "l", true, true)
	vim.cmd("normal! j")
end

-- ─────────────────────────────────────────────────────────────────────
-- Crear un .ipynb NUEVO ya bien formado (con kernelspec elegido por vos).
-- Así, si lo compartís, Jupyter lo reconoce sin problemas y no dependés
-- del parche defensivo de jupytext. Flujo:
--   1) lista los kernels instalados  (jupyter kernelspec list --json)
--   2) elegís uno en un menú
--   3) pedís nombre de archivo
--   4) escribe un notebook mínimo VÁLIDO (nbformat 4) con ese kernelspec
--   5) lo abre → jupytext lo muestra como Python con celdas "# %%"
-- ─────────────────────────────────────────────────────────────────────
local function jupyter_new_notebook()
	-- 1) Kernels disponibles.
	local out = vim.fn.system({ "jupyter", "kernelspec", "list", "--json" })
	if vim.v.shell_error ~= 0 then
		vim.notify("No pude listar kernels. ¿Está jupyter instalado?  pip install jupyter", vim.log.levels.ERROR)
		return
	end
	local ok, data = pcall(vim.json.decode, out)
	if not ok or type(data) ~= "table" or type(data.kernelspecs) ~= "table" then
		vim.notify("No pude leer la lista de kernels de jupyter.", vim.log.levels.ERROR)
		return
	end

	local kernels = {}
	for name, info in pairs(data.kernelspecs) do
		local spec = (info and info.spec) or {}
		table.insert(kernels, {
			name = name,
			display = spec.display_name or name,
			language = spec.language or "python",
		})
	end
	if #kernels == 0 then
		vim.notify("No hay kernels instalados. Probá:  python -m ipykernel install --user", vim.log.levels.ERROR)
		return
	end
	table.sort(kernels, function(a, b)
		return a.display < b.display
	end)

	-- 2) Elegir kernel.
	vim.ui.select(kernels, {
		prompt = "Kernel para el nuevo notebook:",
		format_item = function(k)
			return string.format("%s  (%s)", k.display, k.name)
		end,
	}, function(kernel)
		if not kernel then
			return -- cancelado
		end
		-- 3) Nombre del archivo.
		vim.ui.input({ prompt = "Nombre del notebook: ", default = "nuevo.ipynb" }, function(fname)
			if not fname or fname == "" then
				return
			end
			if not fname:match("%.ipynb$") then
				fname = fname .. ".ipynb"
			end
			if vim.fn.filereadable(fname) == 1 then
				vim.notify("Ya existe: " .. fname, vim.log.levels.WARN)
				return
			end

			-- 4) Notebook mínimo válido (nbformat 4.4: no requiere ids de celda).
			local nb = {
				cells = {
					{
						cell_type = "code",
						execution_count = vim.NIL,
						metadata = vim.empty_dict(),
						outputs = {},
						source = {},
					},
				},
				metadata = {
					kernelspec = {
						display_name = kernel.display,
						language = kernel.language,
						name = kernel.name,
					},
					language_info = { name = kernel.language },
				},
				nbformat = 4,
				nbformat_minor = 4,
			}

			local f = io.open(fname, "w")
			if not f then
				vim.notify("No pude crear el archivo: " .. fname, vim.log.levels.ERROR)
				return
			end
			f:write(vim.json.encode(nb))
			f:close()

			-- 5) Abrirlo: jupytext toma el control y lo muestra con celdas "# %%".
			vim.cmd.edit(vim.fn.fnameescape(fname))
			vim.notify(string.format("Notebook creado con kernel «%s».", kernel.display))
		end)
	end)
end

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
	-- IMAGE.NVIM — backend gráfico para dibujar plots dentro de Neovim
	-- Ghostty implementa el protocolo Kitty, así que usamos backend "kitty".
	-- processor "magick_cli" usa el binario `magick`/`convert` (ImageMagick),
	-- NO el luarock, para no depender de luarocks.
	-- Requiere en el sistema:  sudo apt install imagemagick   (ver README).
	-- Si ImageMagick falta: Neovim NO se rompe; los plots simplemente no se
	-- dibujan (el texto sigue funcionando). Molten lo usa como su proveedor.
	-- =====================
	{
		"3rd/image.nvim",
		ft = { "python", "markdown" },
		opts = {
			backend = "kitty",
			processor = "magick_cli",
			-- Molten dibuja directo con la API; no necesitamos que image.nvim
			-- intercepte markdown/neorg, así que lo dejamos desactivado.
			integrations = {
				markdown = { enabled = false },
				neorg = { enabled = false },
			},
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = math.huge,
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true,
			editor_only_render_when_focused = true,
		},
	},

	-- =====================
	-- JUPYTEXT — abrir/guardar .ipynb como si fuera un .py con celdas "# %%"
	-- Abrís un notebook.ipynb → lo ves como python con celdas → :w lo re-escribe
	-- de vuelta en formato .ipynb. Requiere:  pip install jupytext  (ver README).
	-- Debe cargar temprano para poder interceptar la apertura del .ipynb.
	-- =====================
	{
		"GCBallesteros/jupytext.nvim",
		lazy = false,
		-- Usamos `config` (en vez de `opts`) para poder aplicar un parche
		-- defensivo ANTES de arrancar el plugin.
		config = function()
			-- ── PARCHE: notebooks sin `kernelspec` ───────────────────────────
			-- Algunos .ipynb (generados a mano o por scripts) vienen con
			-- `"metadata": {}`, es decir SIN kernelspec. jupytext.nvim asume
			-- que siempre existe y en utils.lua hace `metadata.kernelspec.language`,
			-- por lo que al abrirlos revienta con:
			--   attempt to index field 'kernelspec' (a nil value)
			-- Envolvemos get_ipynb_metadata: si falta kernelspec/lenguaje,
			-- asumimos Python (el caso normal de un datero) y seguimos.
			-- Al vivir en NUESTRA config, sobrevive a `:Lazy update`.
			local utils = require("jupytext.utils")
			local get_metadata = utils.get_ipynb_metadata
			utils.get_ipynb_metadata = function(filename)
				local ok, meta = pcall(get_metadata, filename)
				if ok and meta and meta.language and meta.extension then
					return meta
				end
				-- Fallback: notebook sin kernelspec → lo tratamos como Python.
				return { language = "python", extension = "py" }
			end

			require("jupytext").setup({
				style = "percent", -- celdas delimitadas por "# %%"
				output_extension = "auto",
				force_ft = nil,
			})

			-- Atajo global (siempre disponible, no solo en buffers python):
			-- crea un .ipynb nuevo eligiendo kernel → queda bien formado.
			-- Nota: <leader>jn (minúscula) es "celda siguiente", por eso "jN".
			vim.keymap.set("n", "<leader>jN", jupyter_new_notebook, {
				desc = "Jupyter: NUEVO notebook (.ipynb) + elegir kernel",
			})
		end,
	},

	-- =====================
	-- JUPYTER — Molten (evaluar código Python de forma interactiva)
	-- Requiere: pip install pynvim jupyter_client ipykernel  (+ :UpdateRemotePlugins)
	--
	-- Flujo mínimo:
	--   1. Abre un .py (con "# %%") o un .ipynb.
	--   2. <leader>ji  → arranca el kernel (elige el de tu venv si te pregunta).
	--   3. Cursor en una celda → <leader>jc  → la ejecuta.
	--   4. Texto = virt-text bajo la celda · Plots = <leader>jo (ventana de salida).
	-- =====================
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		build = ":UpdateRemotePlugins",
		dependencies = { "3rd/image.nvim" },
		-- Cargamos molten SOLO por filetype (python) y por sus atajos.
		-- ¡OJO! NO usar `cmd = { "MoltenInit", ... }` aquí: molten es un
		-- REMOTE PLUGIN de Python, sus comandos los registra el manifiesto
		-- (rplugin.vim) al arrancar Neovim. Si además los declaramos en `cmd`,
		-- lazy.nvim crea placeholders con esos mismos nombres y, cuando carga
		-- molten (disparado por `ft`/`keys`), BORRA esos placeholders... que
		-- para entonces son los comandos reales del manifiesto. El síntoma es
		-- justo: "not an editor command: MoltenEvaluateVisual".
		ft = "python",
		init = function()
			-- Proveedor de imágenes: ahora SÍ dibujamos plots (vía image.nvim).
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			-- No abrir la ventana de salida sola: el texto ya sale como virt-text,
			-- y los plots los abrís a demanda con <leader>jo (menos ruido).
			vim.g.molten_auto_open_output = false
			vim.g.molten_wrap_output = true
			-- Muestra la salida de TEXTO como texto virtual debajo de la celda.
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = true
		end,
		keys = {
			-- Kernel
			{ "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Molten: iniciar/elegir kernel" },
			{ "<leader>jk", "<cmd>MoltenRestart!<cr>", desc = "Molten: reiniciar kernel" },
			{ "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Molten: interrumpir ejecución" },
			-- Ejecutar
			{ "<leader>jc", molten_eval_cell, ft = "python", desc = "Molten: ▶ ejecutar CELDA (# %%)" },
			{ "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Molten: ejecutar línea" },
			{ "<leader>je", "<cmd>MoltenEvaluateOperator<cr>", desc = "Molten: ejecutar (motion, ej. jeip)" },
			{ "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Molten: ejecutar selección" },
			{ "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Molten: reevaluar celda actual" },
			{ "<leader>jA", "<cmd>MoltenReevaluateAll<cr>", desc = "Molten: reevaluar TODAS las celdas" },
			-- Navegar entre celdas
			{ "<leader>jn", molten_next_cell, ft = "python", desc = "Molten: celda siguiente" },
			{ "<leader>jp", molten_prev_cell, ft = "python", desc = "Molten: celda anterior" },
			{ "<leader>jb", molten_insert_cell, ft = "python", desc = "Molten: insertar bloque de celda (# %%)" },
			-- Salida (aquí se ven los plots)
			{ "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Molten: mostrar salida (plots aquí)" },
			{ "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Molten: ocultar salida" },
			{ "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Molten: borrar salida de la celda" },
		},
	},
}
