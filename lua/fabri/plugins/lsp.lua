-- =====================================================================
-- LSP & COMPLETADO  —  SINGLE SOURCE OF TRUTH
-- Todo lo relacionado a Mason, servidores LSP, autocompletado (nvim-cmp)
-- y formateo (conform / Ruff) vive AQUÍ. No dupliques esto en otro archivo.
-- =====================================================================
return {

	-- =====================
	-- MASON — instalador de LSPs / herramientas
	-- =====================
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			vim.keymap.set("n", "<leader>lm", "<cmd>Mason<cr>", { noremap = true, silent = true, desc = "Abrir Mason" })
		end,
	},

	-- =====================
	-- MASON <-> LSPCONFIG + configuración de servidores
	-- =====================
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig", -- provee las definiciones por defecto que usa vim.lsp.enable
			"b0o/schemastore.nvim", -- catálogo de JSON/YAML schemas (k8s, compose, GH Actions, etc.)
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"gh_actions_ls", -- GitHub Actions
					"pyright", -- Python (ETL / DAGs de Airflow)
					"gopls", -- Go
					"lua_ls", -- Lua
					"dockerls", -- Dockerfile
					"yamlls", -- YAML (Kubernetes, docker-compose, dbt)
					"jsonls", -- JSON
					"terraformls", -- Terraform / GCP
					"helm_ls", -- Helm charts (plantillas K8s)
					"bashls", -- Bash scripting
				},
				automatic_installation = true,
			})

			local schemastore = require("schemastore")

			-- Keymaps cuando cualquier LSP se adjunta a un buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local map = vim.keymap.set
					local function o(desc)
						return { noremap = true, silent = true, buffer = args.buf, desc = desc }
					end

					map("n", "gd", vim.lsp.buf.definition, o("Ir a definición"))
					map("n", "gr", vim.lsp.buf.references, o("Ver referencias"))
					map("n", "K", vim.lsp.buf.hover, o("Documentación (hover)"))
					map("n", "<leader>lr", vim.lsp.buf.rename, o("Renombrar símbolo"))
					map("n", "<leader>la", vim.lsp.buf.code_action, o("Code action"))
					map("n", "<leader>ld", vim.diagnostic.open_float, o("Ver diagnóstico"))
					map("n", "[d", vim.diagnostic.goto_prev, o("Diagnóstico anterior"))
					map("n", "]d", vim.diagnostic.goto_next, o("Diagnóstico siguiente"))
					map("n", "<leader>lf", function()
						vim.lsp.buf.format({ async = true })
					end, o("Formatear (LSP)"))
				end,
			})

			-- Python (pyright) — pensado para scripts de ETL y DAGs de Airflow
			vim.lsp.config("pyright", {
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})

			-- Lua
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
					},
				},
			})

			-- Terraform / GCP
			vim.lsp.config("terraformls", {
				filetypes = { "terraform", "tf", "terraform-vars" },
			})

			-- YAML — Kubernetes + docker-compose + dbt + catálogo SchemaStore
			vim.lsp.config("yamlls", {
				settings = {
					yaml = {
						-- Usamos SchemaStore en vez del store interno de yamlls
						schemaStore = { enable = false, url = "" },
						schemas = vim.tbl_extend("force", schemastore.yaml.schemas(), {
							-- Kubernetes: "kubernetes" es una palabra especial de yamlls
							-- que aplica el schema oficial de K8s a estos manifests
							kubernetes = {
								"*.k8s.yaml",
								"**/k8s/**/*.yaml",
								"**/kube/**/*.yaml",
								"**/manifests/**/*.yaml",
								"**/kubernetes/**/*.yaml",
							},
							-- dbt schema files
							["https://raw.githubusercontent.com/dbt-labs/dbt-jsonschema/main/schemas/dbt_yml_files.json"] = {
								"schema.yml",
								"schema.yaml",
								"**/models/**/*.yml",
								"**/models/**/*.yaml",
								"sources.yml",
								"sources.yaml",
							},
							-- docker-compose
							["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
								"docker-compose*.yml",
								"docker-compose*.yaml",
							},
						}),
						validate = true,
						completion = true,
					},
				},
			})

			-- JSON — con catálogo completo de SchemaStore
			vim.lsp.config("jsonls", {
				settings = {
					json = {
						schemas = schemastore.json.schemas(),
						validate = { enable = true },
					},
				},
			})

			-- Habilitar todos los servidores
			vim.lsp.enable({
				"gh_actions_ls",
				"pyright",
				"gopls",
				"lua_ls",
				"dockerls",
				"yamlls",
				"jsonls",
				"terraformls",
				"helm_ls",
				"bashls",
			})

			-- Diagnósticos
			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = true,
				update_in_insert = false,
				float = { border = "rounded", source = true },
			})

			-- Asociaciones de filetype
			-- dbt (Jinja+SQL) y GitHub Actions se tratan de forma especial
			vim.filetype.add({
				extension = {
					tf = "terraform",
				},
				pattern = {
					[".*/%.github/workflows/.*%.ya?ml"] = "yaml.github",
					[".*/.dbt/.*%.sql"] = "jinja",
					[".*/models/.*%.sql"] = "jinja",
					[".*/macros/.*%.sql"] = "jinja",
					[".*/analyses/.*%.sql"] = "jinja",
					[".*/snapshots/.*%.sql"] = "jinja",
					[".*/dbt_project%.yml"] = "yaml",
					[".*/profiles%.yml"] = "yaml",
				},
			})
		end,
	},

	-- =====================
	-- AUTOCOMPLETADO (nvim-cmp)
	-- =====================
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"kristijanhusak/vim-dadbod-completion",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "vim-dadbod-completion" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},

	-- =====================
	-- FORMATEO AL GUARDAR (conform)
	-- Ruff para Python; formateadores dedicados por lenguaje
	-- =====================
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					-- Ruff: ordena imports y luego formatea (reemplaza a black + isort)
					python = { "ruff_organize_imports", "ruff_format" },
					lua = { "stylua" },
					sql = { "sqlfmt" },
					sh = { "shfmt" },
					bash = { "shfmt" },
					terraform = { "terraform_fmt" },
					tf = { "terraform_fmt" },
					yaml = { "prettier" },
					["yaml.github"] = { "prettier" },
					json = { "prettier" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true,
				},
			})

			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				require("conform").format({ async = true, lsp_fallback = true })
			end, { noremap = true, silent = true, desc = "Formatear archivo" })
		end,
	},
}
