local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader key (must match init.lua load order)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Better escape
map("i", "jk", "<Esc>", opts)

-- Save
map("n", "<leader>w", ":w<CR>", opts)
map("n", "<leader>q", ":q<CR>", opts)

-- Reload config
map("n", "<leader>r", ":source %<CR>", opts)

-- Move between splits (windows)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-l>", "<C-w>l", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)

-- Resize splits
map("n", "<C-Up>", ":resize +2<CR>", opts)
map("n", "<C-Down>", ":resize -2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Create splits
map("n", "<leader>sv", ":vsplit<CR>", opts)
map("n", "<leader>sh", ":split<CR>", opts)

-- Move between buffers
map("n", "<Tab>", ":bnext<CR>", opts)
map("n", "<S-Tab>", ":bprevious<CR>", opts)
map("n", "<leader>x", ":bdelete<CR>", opts)

-- Better indent in visual mode (stays selected)
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Clear search highlight
map("n", "<Esc>", ":nohl<CR>", opts)
