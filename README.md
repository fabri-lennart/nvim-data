# nvim-data

Personal Neovim IDE for data engineering.

Built from scratch for working with Go, JavaScript/TypeScript, Python, SQL, dbt, Terraform and Docker.
No distributions, no abstractions — just Lua.

## Stack
- **Editor**: Neovim 0.11+
- **Languages**: Go · JavaScript/TypeScript · HTML/CSS · Python · SQL · Terraform · Bash · YAML
- **Database**: DuckDB · Snowflake · Postgres (via dadbod)
- **AI**: Claude (via codecompanion)

## Requirements
- Neovim 0.11+
- git · lazygit · lazydocker · yazi
- pip install black debugpy sqlfmt
- Go: `go`, `gopls`, `dlv`, `goimports`
- JavaScript/TypeScript: `node`, `typescript-language-server`, `prettier`, and Mason's `js-debug-adapter`
- Google Cloud: Google Cloud CLI (`gcloud` and `bq`); run `gcloud init` to choose your project

## Theme and data validation

- Kanagawa Wave is the default theme. Use `<leader>uk` to toggle Kanagawa/Gruvbox or `<leader>uc` to select a theme.
- JSON and YAML use language-server schema validation; CSV/TSV can be inspected with `<leader>cs`.
- In a SQL buffer, `<leader>Gv` runs a BigQuery dry run to validate the query without executing it.
- `<leader>Gp` lists Google Cloud projects; `<leader>Gc` shows the active CLI configuration.

## Go and JavaScript debugging

- Open a Go file and press `<F5>` to launch Delve, or `<leader>dT` to debug the current test.
- Open a JavaScript/TypeScript file and press `<F5>` to choose a Node launch, Node attach, or local browser session.
- Use `<leader>dt` for breakpoints, `<F10>` to step over, `<F11>` to step in, and `<F12>` to step out.
- Go files use tabs and `goimports` on save. JavaScript, TypeScript, HTML, and CSS use Prettier on save.

### Notebooks / Jupyter (Molten)
- Kernel:   `pip install pynvim jupyter_client ipykernel jupytext`
- Plots inline (ImageMagick, backend Kitty vía Ghostty):
  `sudo apt install imagemagick`
- Dentro de Neovim, una vez: `:UpdateRemotePlugins` y reiniciar.

**Flujo:** abre un `.py` (celdas `# %%`) o un `.ipynb` →
`<leader>ji` arranca el kernel → cursor en una celda → `<leader>jc` la ejecuta.
El texto sale como *virt-text* debajo de la celda; los plots con `<leader>jo`.
Todos los atajos están documentados en which-key bajo `<leader>j`.
