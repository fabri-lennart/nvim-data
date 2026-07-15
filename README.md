# nvim-data

Personal Neovim IDE for data engineering.

Built from scratch for working with Python, SQL, dbt, Terraform, Docker and Go.
No distributions, no abstractions — just Lua.

## Stack
- **Editor**: Neovim 0.11+
- **Languages**: Python · SQL · Go · Terraform · Bash · YAML
- **Database**: DuckDB · Snowflake · Postgres (via dadbod)
- **AI**: Claude (via codecompanion)

## Requirements
- Neovim 0.11+
- git · lazygit · lazydocker · yazi
- pip install black debugpy sqlfmt

### Notebooks / Jupyter (Molten)
- Kernel:   `pip install pynvim jupyter_client ipykernel jupytext`
- Plots inline (ImageMagick, backend Kitty vía Ghostty):
  `sudo apt install imagemagick`
- Dentro de Neovim, una vez: `:UpdateRemotePlugins` y reiniciar.

**Flujo:** abre un `.py` (celdas `# %%`) o un `.ipynb` →
`<leader>ji` arranca el kernel → cursor en una celda → `<leader>jc` la ejecuta.
El texto sale como *virt-text* debajo de la celda; los plots con `<leader>jo`.
Todos los atajos están documentados en which-key bajo `<leader>j`.
