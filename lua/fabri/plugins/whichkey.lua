-- =====================================================================
-- KEYMAPS  —  which-key centralizado (menú de atajos)
-- Los grupos se declaran aquí; las descripciones de cada atajo viven
-- junto a su plugin (desc = "...") y which-key las muestra automáticamente.
-- =====================================================================
return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")

			wk.setup({
				preset = "modern",
				-- El menú aparece al instante al pulsar <leader> (espacio)
				delay = 0,
			})

			wk.add({
				-- ---------- Grupos (prefijos <leader>) ----------
				{ "<leader>f", group = "find", icon = "" },
				{ "<leader>s", group = "splits", icon = "" },
				{ "<leader>g", group = "git", icon = "" },
				{ "<leader>d", group = "debug", icon = "" },
				{ "<leader>b", group = "database", icon = "" },
				{ "<leader>l", group = "lsp", icon = "" },
				{ "<leader>t", group = "terminal", icon = "" },
				{ "<leader>c", group = "code / formato", icon = "" },
				{ "<leader>m", group = "dbt / markdown", icon = "" },
				{ "<leader>R", group = "http (kulala)", icon = "󱂛" },
				{ "<leader>i", group = "infra (terraform)", icon = "󱁢" },
				{ "<leader>j", group = "jupyter (molten)", icon = "" },
				{ "<leader>a", group = "ai", icon = "󰚩" },
				{ "<leader>e", group = "explorer", icon = "" },
				{ "<leader>u", group = "ui / toggles", icon = "" },

				-- ---------- Debug: iconografía explícita para el popup ----------
				{ "<leader>dt", desc = "Toggle breakpoint", icon = "" },
				{ "<leader>dc", desc = "Continuar / iniciar", icon = "" },
				{ "<leader>di", desc = "Step into (entrar)", icon = "" },
				{ "<leader>do", desc = "Step over (siguiente)", icon = "" },
				{ "<leader>dO", desc = "Step out (salir)", icon = "" },
				{ "<leader>dr", desc = "Abrir REPL / consola", icon = "" },
				{ "<leader>dB", desc = "Breakpoint condicional", icon = "" },
				{ "<leader>dP", desc = "Log point", icon = "" },
				{ "<leader>dx", desc = "Terminar sesión", icon = "" },
				{ "<leader>du", desc = "Panel de debug (UI)", icon = "" },

				-- ---------- Git: quick launch ----------
				{ "<leader>gg", desc = "LazyGit (flotante)", icon = "" },

				-- ---------- Terminal: docker ----------
				{ "<leader>td", desc = "LazyDocker (contenedores)", icon = "" },
				{ "<leader>tt", desc = "Terminal flotante", icon = "" },

				-- ---------- Splits ----------
				{ "<leader>sv", desc = "Split vertical", icon = "" },
				{ "<leader>sh", desc = "Split horizontal", icon = "" },

				-- ---------- Navegación entre ventanas (Ctrl + hjkl / flechas) ----------
				-- Documentadas para tenerlas siempre visibles como sugerencia.
				{
					mode = { "n" },
					{ "<C-h>", desc = "Ventana: ir a la izquierda", icon = "" },
					{ "<C-j>", desc = "Ventana: ir abajo", icon = "" },
					{ "<C-k>", desc = "Ventana: ir arriba", icon = "" },
					{ "<C-l>", desc = "Ventana: ir a la derecha", icon = "" },
					{ "<C-Up>", desc = "Ventana: más alta", icon = "" },
					{ "<C-Down>", desc = "Ventana: más baja", icon = "" },
					{ "<C-Left>", desc = "Ventana: más angosta", icon = "" },
					{ "<C-Right>", desc = "Ventana: más ancha", icon = "" },
				},
			})
		end,
	},
}
