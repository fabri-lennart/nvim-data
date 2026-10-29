local function run(title, command, input)
  if vim.fn.executable(command[1]) == 0 then
    vim.notify(command[1] .. " is not installed or not on PATH", vim.log.levels.ERROR)
    return
  end
  vim.system(command, { text = true, stdin = input }, function(result)
    vim.schedule(function()
      local output = (result.stdout or "") .. (result.stderr or "")
      vim.notify(title .. "\n" .. (output ~= "" and output or "Done"),
        result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
    end)
  end)
end

vim.api.nvim_create_user_command("GCloudProjects", function()
  run("Google Cloud projects", { "gcloud", "projects", "list" })
end, { desc = "List Google Cloud projects" })

vim.api.nvim_create_user_command("GCloudConfig", function()
  run("Google Cloud configuration", { "gcloud", "config", "list" })
end, { desc = "Show active Google Cloud configuration" })

vim.api.nvim_create_user_command("BQValidate", function()
  if vim.bo.filetype ~= "sql" then
    vim.notify("Open a SQL buffer first", vim.log.levels.WARN)
    return
  end
  local query = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  run("BigQuery dry run", { "bq", "query", "--dry_run", "--use_legacy_sql=false" }, query)
end, { desc = "Validate BigQuery SQL without running it" })

vim.keymap.set("n", "<leader>Gp", "<cmd>GCloudProjects<cr>", { desc = "Google Cloud projects" })
vim.keymap.set("n", "<leader>Gc", "<cmd>GCloudConfig<cr>", { desc = "Google Cloud config" })
vim.keymap.set("n", "<leader>Gv", "<cmd>BQValidate<cr>", { desc = "BigQuery: validate SQL" })
