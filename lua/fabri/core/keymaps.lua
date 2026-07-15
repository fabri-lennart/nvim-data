local map = vim.keymap.set

-- Build a { noremap, silent, desc } table so which-key picks up the label
local function opts(desc)
  return { noremap = true, silent = true, desc = desc }
end

-- Leader key (must match init.lua load order)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Better escape
map("i", "jk", "<Esc>", opts("Escape insert mode"))

-- Save
map("n", "<leader>w", ":w<CR>", opts("Save file"))
map("n", "<leader>q", ":q<CR>", opts("Quit window"))

-- Reload config
map("n", "<leader>r", ":source %<CR>", opts("Reload current file"))

-- Move between splits (windows)
map("n", "<C-h>", "<C-w>h", opts("Window: move left"))
map("n", "<C-l>", "<C-w>l", opts("Window: move right"))
map("n", "<C-j>", "<C-w>j", opts("Window: move down"))
map("n", "<C-k>", "<C-w>k", opts("Window: move up"))

-- Resize splits
map("n", "<C-Up>", ":resize +2<CR>", opts("Window: taller"))
map("n", "<C-Down>", ":resize -2<CR>", opts("Window: shorter"))
map("n", "<C-Left>", ":vertical resize -2<CR>", opts("Window: narrower"))
map("n", "<C-Right>", ":vertical resize +2<CR>", opts("Window: wider"))

-- Create splits
map("n", "<leader>sv", ":vsplit<CR>", opts("Split vertically"))
map("n", "<leader>sh", ":split<CR>", opts("Split horizontally"))

-- Move between buffers
map("n", "<Tab>", ":bnext<CR>", opts("Next buffer"))
map("n", "<S-Tab>", ":bprevious<CR>", opts("Previous buffer"))
map("n", "<leader>x", ":bdelete<CR>", opts("Close buffer"))

-- Better indent in visual mode (stays selected)
map("v", "<", "<gv", opts("Indent left"))
map("v", ">", ">gv", opts("Indent right"))

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", opts("Move selection down"))
map("v", "K", ":m '<-2<CR>gv=gv", opts("Move selection up"))

-- Clear search highlight
map("n", "<Esc>", ":nohl<CR>", opts("Clear search highlight"))
