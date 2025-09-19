---@module "lsp"
---@author Carlos Vigil-Vásquez
---@license MIT 2025


-- Refer to https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L157-L184
-- Lsp <- Entry point
-- Lsp                        -> LspInfo (https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L68)
-- Lsp info                   -> LspInfo (https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L68)
-- Lsp start <name>           -> LspStart <name> (https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L99-L120)
-- Lsp stop <name>            -> LspStop <name> (https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L157-L184)
-- Lsp restart <name>         -> LspRestart <name> (https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L122-L155)
-- Lsp restart                -> Restart all LSP servers running on buffer
-- Lsp toggle <name>          -> Start or stop LSP server
-- Lsp log                    -> Open LSP logs (https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L70-L74)
