-- =====================================================================
-- DEVOPS & INFRAESTRUCTURA
-- Terraform (GCP) · Helm / Kubernetes · Docker
-- Los LSP (terraformls, yamlls con schemas K8s, helm_ls, dockerls) se
-- configuran en lsp.lua. Aquí van las herramientas y sintaxis dedicadas.
-- =====================================================================
return {

	-- =====================
	-- TERRAFORM — comandos, alineado y sintaxis para infra en GCP
	-- Los atajos <leader>i* requieren el CLI `terraform` instalado.
	-- =====================
	{
		"hashivim/vim-terraform",
		ft = { "terraform", "terraform-vars", "hcl" },
		init = function()
			vim.g.terraform_align = 1
			vim.g.terraform_fmt_on_save = 0 -- lo maneja conform / LSP
		end,
		keys = {
			{ "<leader>ii", "<cmd>Terraform init<cr>", ft = "terraform", desc = "Terraform: init" },
			{ "<leader>ip", "<cmd>Terraform plan<cr>", ft = "terraform", desc = "Terraform: plan" },
			{ "<leader>iv", "<cmd>Terraform validate<cr>", ft = "terraform", desc = "Terraform: validate" },
			{ "<leader>if", "<cmd>Terraform fmt<cr>", ft = "terraform", desc = "Terraform: fmt" },
			{ "<leader>ia", "<cmd>Terraform apply<cr>", ft = "terraform", desc = "Terraform: apply" },
		},
	},

	-- =====================
	-- HELM — detección de filetype y sintaxis para plantillas K8s (Helm)
	-- Evita que yamlls marque errores falsos en los templates con {{ }}
	-- y activa helm_ls (configurado en lsp.lua).
	-- =====================
	{
		"towolf/vim-helm",
		ft = { "helm", "yaml" },
	},
}
