-- =====================================================================
-- THEME MANAGER
-- Punto único para: registrar colorschemes, cambiar entre ellos y
-- alternar la transparencia del fondo.
--
-- La transparencia es AGNÓSTICA AL TEMA: se aplica mediante un autocmd
-- ColorScheme que quita el fondo de los grupos de resaltado relevantes
-- cada vez que se carga un tema. Así, al cambiar de tema (con nuestro
-- selector, :colorscheme o Telescope) se conserva el estado actual.
-- =====================================================================

local M = {}

-- Temas disponibles en el selector. `bg` fija vim.o.background antes de cargar.
M.themes = {
	{ label = "Gruvbox — dark", scheme = "gruvbox", bg = "dark" },
	{ label = "Gruvbox — light", scheme = "gruvbox", bg = "light" },
	{ label = "Nordic", scheme = "nordic", bg = "dark" },
}

-- Tema por defecto al arrancar (debe coincidir con un `label` de arriba).
M.default = "Gruvbox — dark"

-- Estado de la transparencia (fondo del editor apagado para ver la terminal).
M.transparent = false

-- Grupos de resaltado a los que les quitamos el fondo cuando la
-- transparencia está ON. Los primeros planos (fg) se conservan intactos.
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

local function strip_backgrounds()
	for _, g in ipairs(groups) do
		local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
		hl.bg = nil
		hl.ctermbg = nil
		hl.link = nil
		vim.api.nvim_set_hl(0, g, hl)
	end
end

-- Reaplica la transparencia después de que se cargue CUALQUIER tema.
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("FabriThemeTransparency", { clear = true }),
	callback = function()
		if M.transparent then
			strip_backgrounds()
		end
	end,
})

-- Carga un colorscheme (fijando antes el background si se indica).
function M.set(scheme, bg)
	if bg then
		vim.o.background = bg
	end
	local ok, err = pcall(vim.cmd.colorscheme, scheme)
	if not ok then
		vim.notify("No se pudo cargar el tema '" .. scheme .. "': " .. tostring(err), vim.log.levels.ERROR)
	end
end

-- Selector interactivo de tema.
function M.pick()
	vim.ui.select(M.themes, {
		prompt = "Elige un tema:",
		format_item = function(t)
			return t.label
		end,
	}, function(choice)
		if not choice then
			return
		end
		M.set(choice.scheme, choice.bg)
		vim.notify("Tema: " .. choice.label, vim.log.levels.INFO)
	end)
end

-- Alterna la transparencia del fondo (para que se vea la terminal detrás).
function M.toggle_transparency()
	M.transparent = not M.transparent
	if M.transparent then
		strip_backgrounds()
	else
		-- Recarga el tema actual para restaurar los fondos originales.
		if vim.g.colors_name then
			vim.cmd.colorscheme(vim.g.colors_name)
		end
	end
	vim.notify("Transparencia " .. (M.transparent and "ON" or "OFF"), vim.log.levels.INFO)
end

-- Registra comandos, keymaps y aplica el tema por defecto al arrancar.
function M.setup()
	vim.api.nvim_create_user_command("ThemeSelect", M.pick, { desc = "Elegir tema (colorscheme)" })
	vim.api.nvim_create_user_command("ToggleTransparency", M.toggle_transparency, {
		desc = "Toggle transparencia del fondo",
	})

	vim.keymap.set("n", "<leader>uc", M.pick, {
		noremap = true,
		silent = true,
		desc = "Cambiar tema",
	})
	vim.keymap.set("n", "<leader>ut", M.toggle_transparency, {
		noremap = true,
		silent = true,
		desc = "Toggle transparencia",
	})

	-- Aplica el tema por defecto.
	for _, t in ipairs(M.themes) do
		if t.label == M.default then
			M.set(t.scheme, t.bg)
			return
		end
	end
end

return M
