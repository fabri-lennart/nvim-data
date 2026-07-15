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
-- │  4) ¿DÓNDE se ve lo renderizado?                                    │
-- │     • Cada celda muestra su salida (texto Y plots) en una           │
-- │       VENTANA FLOTANTE, y SOLO la de la celda donde estás.          │
-- │     • Se abre sola al ejecutar. La reabrís con <leader>jo y         │
-- │       la cerrás con <leader>jh. Nunca se apilan todas juntas.       │
-- │     • Ghostty habla el protocolo Kitty → el plot se ve de           │
-- │       verdad, no como texto. (Requiere ImageMagick, ver README.)    │
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
-- EJECUTAR TODAS LAS CELDAS DE CÓDIGO (de arriba a abajo, desde cero).
-- Molten NO trae esto de fábrica: `MoltenReevaluateAll` solo re-corre las
-- celdas que YA evaluaste. Acá recorremos el archivo, detectamos cada
-- "# %%" y evaluamos su bloque con la función remota MoltenEvaluateRange.
-- Se saltean las celdas markdown ("# %% [markdown]" / "[md]"): son prosa.
-- Como MoltenEvaluateRange es síncrona, el kernel encola las celdas y las
-- ejecuta en orden. Necesitás el kernel ya arrancado (<leader>ji).
-- ─────────────────────────────────────────────────────────────────────
local function molten_eval_all_cells()
	-- Junta las líneas que abren celda, marcando cuáles son markdown.
	local markers = {}
	for lnum = 1, vim.fn.line("$") do
		local line = vim.fn.getline(lnum)
		if line:match("^%s*#%s*%%%%") then
			local low = line:lower()
			local is_md = low:match("%[markdown%]") ~= nil or low:match("%[md%]") ~= nil
			table.insert(markers, { lnum = lnum, md = is_md })
		end
	end

	if #markers == 0 then
		vim.notify("No encontré celdas «# %%» en este archivo.", vim.log.levels.WARN)
		return
	end

	local count = 0
	for i, m in ipairs(markers) do
		if not m.md then
			local top = m.lnum + 1 -- primera línea DESPUÉS del "# %%"
			local next_lnum = markers[i + 1] and markers[i + 1].lnum or (vim.fn.line("$") + 1)
			local bot = next_lnum - 1 -- última línea antes del próximo "# %%"
			if bot >= top then
				-- 1-indexado; sin arg de kernel, molten usa el kernel actual ('%k').
				vim.fn.MoltenEvaluateRange(top, bot)
				count = count + 1
			end
		end
	end
	vim.notify(("▶▶ Enviadas %d celdas de código al kernel."):format(count), vim.log.levels.INFO)
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

-- ─────────────────────────────────────────────────────────────────────
-- VENV "TRADICIONAL" PARA NOTEBOOKS  (python -m venv, NO uv)
-- ─────────────────────────────────────────────────────────────────────
-- Filosofía: para scripts / desarrollo de software usás `uv`. Para
-- notebooks querés un venv CLÁSICO y aislado que NO ensucie el Python del
-- sistema (así no instalás "miles de cosas" que lo vuelvan frágil).
--
-- Creamos UN venv central reutilizable en  ~/.venvs/notebooks , le
-- instalamos el stack de datos + ipykernel, y registramos su kernel en
-- Jupyter con el nombre "notebooks". A partir de ahí, <leader>ji lo toma
-- POR DEFECTO (sin menú) mientras exista. Recrearlo es idempotente.
--
--   <leader>jV  → crear/asegurar el venv + kernel (async, no congela nvim)
--   <leader>ji  → arrancar Molten tomando el kernel "notebooks" por defecto
-- ─────────────────────────────────────────────────────────────────────
local NB_VENV_DIR = vim.fn.expand("~/.venvs/notebooks")
local NB_KERNEL_NAME = "notebooks"
local NB_KERNEL_DISPLAY = "Python (notebooks)"
-- Stack de datos típico. Editá esta lista si querés otro set por defecto.
local NB_PACKAGES = {
	"ipykernel", -- imprescindible: es lo que hace que sea un "kernel"
	"pandas",
	"numpy",
	"matplotlib",
	"seaborn",
	"scikit-learn",
	"polars",
}

-- Comilla-simple segura para pasar rutas/nombres a `sh -c`.
local function shq(s)
	return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

-- ¿El kernel "notebooks" ya está registrado en Jupyter?
local function nb_kernel_exists()
	local out = vim.fn.system({ "jupyter", "kernelspec", "list", "--json" })
	if vim.v.shell_error ~= 0 then
		return false
	end
	local ok, data = pcall(vim.json.decode, out)
	if not ok or type(data) ~= "table" or type(data.kernelspecs) ~= "table" then
		return false
	end
	return data.kernelspecs[NB_KERNEL_NAME] ~= nil
end

-- Arranca Molten tomando el kernel de notebooks POR DEFECTO.
-- Si aún no existe, cae al MoltenInit normal (menú de kernels).
local function molten_init_default()
	if nb_kernel_exists() then
		vim.cmd("MoltenInit " .. NB_KERNEL_NAME)
	else
		vim.notify("No existe el kernel «notebooks» todavía. Crealo con <leader>jV.", vim.log.levels.WARN)
		vim.cmd("MoltenInit") -- menú normal como fallback
	end
end

-- Crea (si falta) el venv de notebooks, instala el stack y registra el
-- kernel. Idempotente: si el venv ya existe, solo re-asegura el kernel.
-- Todo async vía jobstart para no bloquear el editor.
local function notebook_venv_setup()
	local py = NB_VENV_DIR .. "/bin/python"
	local exists = vim.fn.executable(py) == 1

	local cmd
	if exists then
		-- Solo (re)registrar el kernel — barato e idempotente.
		cmd = table.concat({
			shq(py),
			"-m ipykernel install --user",
			"--name " .. shq(NB_KERNEL_NAME),
			"--display-name " .. shq(NB_KERNEL_DISPLAY),
		}, " ")
		vim.notify("venv de notebooks ya existe → re-asegurando kernel…", vim.log.levels.INFO)
	else
		local pkgs = {}
		for _, p in ipairs(NB_PACKAGES) do
			table.insert(pkgs, shq(p))
		end
		cmd = table.concat({
			"python3 -m venv " .. shq(NB_VENV_DIR),
			shq(py) .. " -m pip install --upgrade pip",
			shq(py) .. " -m pip install " .. table.concat(pkgs, " "),
			shq(py)
				.. " -m ipykernel install --user --name "
				.. shq(NB_KERNEL_NAME)
				.. " --display-name "
				.. shq(NB_KERNEL_DISPLAY),
		}, " && ")
		vim.notify(
			"Creando venv de notebooks en " .. NB_VENV_DIR .. "\n(instalando stack de datos; puede tardar 1-2 min)…",
			vim.log.levels.INFO
		)
	end

	local errbuf = {}
	vim.fn.jobstart({ "sh", "-c", cmd }, {
		on_stdout = function(_, d)
			if d then
				vim.list_extend(errbuf, d)
			end
		end,
		on_stderr = function(_, d)
			if d then
				vim.list_extend(errbuf, d)
			end
		end,
		on_exit = function(_, code)
			vim.schedule(function()
				if code == 0 then
					vim.notify(
						"✓ venv de notebooks listo. Kernel «"
							.. NB_KERNEL_DISPLAY
							.. "» registrado.\nArrancalo con <leader>ji (lo toma por defecto).",
						vim.log.levels.INFO
					)
				else
					local lines = vim.tbl_filter(function(l)
						return l ~= ""
					end, errbuf)
					local tail = table.concat(lines, "\n")
					vim.notify(
						"✗ Falló el setup del venv (code " .. code .. "):\n" .. tail:sub(-900),
						vim.log.levels.ERROR
					)
				end
			end)
		end,
	})
end

-- ─────────────────────────────────────────────────────────────────────
-- INSTALAR LIBRERÍAS AL VUELO  —  DOS DESTINOS BIEN DIFERENCIADOS
-- ─────────────────────────────────────────────────────────────────────
-- Hay dos venvs posibles y el menú de which-key los distingue claramente:
--
--   <leader>jP → venv GENERAL de notebooks (~/.venvs/notebooks).
--                El compartido que usás para todo. Siempre disponible.
--   <leader>jI → venv del PROYECTO (.venv/ o venv/ local).
--                Se busca subiendo desde el archivo actual; si no hay,
--                te ofrece crearlo en la raíz del proyecto (cwd).
--
-- Ambos usan el MISMO runner de pip (`pip_install_async`); solo cambia el
-- intérprete de destino y la etiqueta que se muestra en los mensajes.
-- ─────────────────────────────────────────────────────────────────────

-- Runner común: corre `pip install <input>` async en el python `py`.
-- `label` es solo para los avisos (ej. "venv GENERAL", "proyecto: ./.venv").
-- Cada token del input es un paquete y se comilla por separado para que
-- specs tipo  "pandas==2.2"  o  "ruff>=0.5"  pasen sanos a la shell.
local function pip_install_async(py, input, label)
	local pkgs = {}
	for tok in input:gmatch("%S+") do
		table.insert(pkgs, shq(tok))
	end
	local cmd = shq(py) .. " -m pip install " .. table.concat(pkgs, " ")

	vim.notify(("Instalando en %s: %s …"):format(label, input), vim.log.levels.INFO)

	local errbuf = {}
	vim.fn.jobstart({ "sh", "-c", cmd }, {
		on_stdout = function(_, d)
			if d then
				vim.list_extend(errbuf, d)
			end
		end,
		on_stderr = function(_, d)
			if d then
				vim.list_extend(errbuf, d)
			end
		end,
		on_exit = function(_, code)
			vim.schedule(function()
				if code == 0 then
					vim.notify(
						("✓ Instalado en %s: %s\n(reiniciá el kernel con <leader>jk si ya estaba abierto)"):format(
							label,
							input
						),
						vim.log.levels.INFO
					)
				else
					local lines = vim.tbl_filter(function(l)
						return l ~= ""
					end, errbuf)
					vim.notify(
						"✗ Falló pip (code " .. code .. "):\n" .. table.concat(lines, "\n"):sub(-900),
						vim.log.levels.ERROR
					)
				end
			end)
		end,
	})
end

-- <leader>jP — pip install en el venv GENERAL de notebooks.
local function notebook_venv_install()
	local py = NB_VENV_DIR .. "/bin/python"
	if vim.fn.executable(py) ~= 1 then
		vim.notify("Todavía no existe el venv GENERAL de notebooks. Crealo primero con <leader>jV.", vim.log.levels.WARN)
		return
	end

	vim.ui.input({ prompt = "pip install → venv GENERAL (~/.venvs/notebooks): " }, function(input)
		if not input or vim.trim(input) == "" then
			return -- cancelado / vacío
		end
		pip_install_async(py, input, "venv GENERAL (~/.venvs/notebooks)")
	end)
end

-- Busca un venv de PROYECTO: desde la carpeta del archivo actual sube por el
-- árbol de directorios buscando  .venv/bin/python  o  venv/bin/python.
-- Devuelve (ruta_al_python, ruta_al_venv) o nil si no encuentra ninguno.
local function find_project_venv_python()
	local dir = vim.fn.expand("%:p:h")
	if dir == "" then
		dir = vim.fn.getcwd()
	end
	while true do
		for _, name in ipairs({ ".venv", "venv" }) do
			local venv = dir .. "/" .. name
			local py = venv .. "/bin/python"
			if vim.fn.executable(py) == 1 then
				return py, venv
			end
		end
		local parent = vim.fn.fnamemodify(dir, ":h")
		if parent == dir then
			return nil -- llegamos a la raíz "/"
		end
		dir = parent
	end
end

-- <leader>jI — pip install en el venv del PROYECTO. Si no hay ninguno,
-- ofrece crear un .venv (con pip + ipykernel) en la raíz (cwd).
local function project_venv_install()
	local py, venv = find_project_venv_python()
	if py then
		local short = vim.fn.fnamemodify(venv, ":~:.")
		vim.ui.input({ prompt = ("pip install → proyecto (%s): "):format(short) }, function(input)
			if not input or vim.trim(input) == "" then
				return
			end
			pip_install_async(py, input, "proyecto (" .. short .. ")")
		end)
		return
	end

	-- No hay venv de proyecto: ofrecer crearlo en la raíz (cwd).
	local target = vim.fn.getcwd() .. "/.venv"
	local short = vim.fn.fnamemodify(target, ":~:.")
	vim.ui.select({ "Sí, crear " .. short, "No, cancelar" }, {
		prompt = "No encontré venv de proyecto (.venv/venv). ¿Creo uno?",
	}, function(choice)
		if not choice or choice:match("^No") then
			return
		end
		local newpy = target .. "/bin/python"
		local cmd = table.concat({
			"python3 -m venv " .. shq(target),
			shq(newpy) .. " -m pip install --upgrade pip ipykernel",
		}, " && ")
		vim.notify("Creando venv del proyecto en " .. short .. " …", vim.log.levels.INFO)

		local errbuf = {}
		vim.fn.jobstart({ "sh", "-c", cmd }, {
			on_stdout = function(_, d)
				if d then
					vim.list_extend(errbuf, d)
				end
			end,
			on_stderr = function(_, d)
				if d then
					vim.list_extend(errbuf, d)
				end
			end,
			on_exit = function(_, code)
				vim.schedule(function()
					if code == 0 then
						vim.notify(
							"✓ venv del proyecto creado en " .. short .. "\nVolvé a pulsar <leader>jI para instalar librerías ahí.",
							vim.log.levels.INFO
						)
					else
						local lines = vim.tbl_filter(function(l)
							return l ~= ""
						end, errbuf)
						vim.notify(
							"✗ Falló crear el venv (code " .. code .. "):\n" .. table.concat(lines, "\n"):sub(-900),
							vim.log.levels.ERROR
						)
					end
				end)
			end,
		})
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
			-- Filetypes que NO deben "limpiar" la imagen al solaparse con su
			-- ventana. Incluimos "" (buffer sin filetype) porque la ventana de
			-- salida de Molten suele no tener filetype: sin esto, se contaría
			-- como solape y borraría el plot. (Setup recomendado por molten.)
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
			-- OJO: NO activar `editor_only_render_when_focused`. Engancha
			-- autocmds FocusLost/FocusGained que BORRAN la imagen ya dibujada
			-- al perder el foco y la restauran al recuperarlo. Ghostty emite
			-- eventos de foco (shell-integration=detect), y un FocusLost
			-- espurio (al abrir la salida de Molten / arrancar el kernel) deja
			-- el plot oculto para siempre —el texto sigue viéndose porque son
			-- extmarks, no image.nvim. Ese era EL bug de "texto sí, plot no".
			editor_only_render_when_focused = false,
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

			-- Atajo global para crear/asegurar el venv "tradicional" de
			-- notebooks (~/.venvs/notebooks) + su kernel. Disponible en
			-- cualquier buffer (no depende de que molten esté cargado).
			vim.keymap.set("n", "<leader>jV", notebook_venv_setup, {
				desc = "Jupyter: crear/asegurar venv de notebooks + kernel",
			})

			-- Instalar librerías al vuelo — DOS destinos diferenciados:
			--   jP → venv GENERAL (~/.venvs/notebooks), el compartido.
			--   jI → venv del PROYECTO (.venv/venv local, o lo crea).
			vim.keymap.set("n", "<leader>jP", notebook_venv_install, {
				desc = "Jupyter: pip install en venv GENERAL (~/.venvs/notebooks)",
			})
			vim.keymap.set("n", "<leader>jI", project_venv_install, {
				desc = "Jupyter: pip install en venv del PROYECTO (.venv local)",
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
	--   4. Salida (texto y plots) en ventana flotante de la celda actual
	--      (se abre sola; la reabrís con <leader>jo). Todas las celdas: <leader>ja.
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
			-- Proveedor de imágenes: dibujamos plots (vía image.nvim).
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_wrap_output = true
			-- MODO "solo celda actual": la salida NO se pega inline en el buffer.
			-- Se muestra en una VENTANA FLOTANTE de la celda donde está el cursor
			-- y se abre sola al ejecutar. Al moverte a otra celda ves la salida
			-- de ESA celda; nunca se apilan todas a la vez. (La reabrís a mano
			-- con <leader>jo y la cerrás con <leader>jh.)
			vim.g.molten_auto_open_output = true
			-- Sin texto virtual inline: evita que cada celda deje su salida
			-- pegada debajo y el buffer se llene de resultados viejos.
			vim.g.molten_virt_text_output = false
			vim.g.molten_virt_lines_off_by_1 = false
		end,
		keys = {
			-- Kernel
			{ "<leader>ji", molten_init_default, desc = "Molten: iniciar kernel (venv notebooks por defecto)" },
			{ "<leader>jk", "<cmd>MoltenRestart!<cr>", desc = "Molten: reiniciar kernel" },
			{ "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Molten: interrumpir ejecución" },
			-- Ejecutar
			{ "<leader>jc", molten_eval_cell, ft = "python", desc = "Molten: ▶ ejecutar CELDA (# %%)" },
			{ "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Molten: ejecutar línea" },
			{ "<leader>je", "<cmd>MoltenEvaluateOperator<cr>", desc = "Molten: ejecutar (motion, ej. jeip)" },
			{ "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Molten: ejecutar selección" },
			{ "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Molten: reevaluar celda actual" },
			{ "<leader>ja", molten_eval_all_cells, ft = "python", desc = "Molten: ▶▶ ejecutar TODAS las celdas (de cero)" },
			{ "<leader>jA", "<cmd>MoltenReevaluateAll<cr>", desc = "Molten: reevaluar solo las celdas YA ejecutadas" },
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
