-- 1. Basic Settings
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Relative numbers for easy jumping
vim.opt.shiftwidth = 2        -- Good for OCaml/Rust
vim.opt.expandtab = true      -- Use spaces
vim.opt.termguicolors = true  -- True color support

-- 2. Bootstrap Plugin Manager (lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 3. Load Plugins
require("lazy").setup({
  "neovim/nvim-lspconfig",             -- LSP configurations
  "williamboman/mason.nvim",           -- LSP manager
  "williamboman/mason-lspconfig.nvim",
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" }, -- Better highlighting
  "navarasu/onedark.nvim",             -- Clean color scheme
})

-- 4. Plugin Configurations
require('onedark').load()
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "rust_analyzer", "ocamllsp", "clangd" }
})

-- 5. Setup Language Servers
local lspconfig = require('lspconfig')

-- Rust setup
lspconfig.rust_analyzer.setup{}

-- OCaml setup
lspconfig.ocamllsp.setup{}

-- C++ setup
lspconfig.clangd.setup{}

-- 6. Keybindings
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover Info" })
