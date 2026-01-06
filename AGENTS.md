# AGENTS.md - Neovim Configuration Codebase Guide

## Build/Lint/Test Commands
- **Format Lua**: `stylua .` (configured in stylua.toml)
- **Lint Lua**: `luacheck lua/` 
- **Test Plugin**: `make test` (uses Plenary test framework, see extras/skeletons/personal/make/nvim-plugin)
- **Format specific languages**: Use `:lua require("conform").format()` or `<leader>lf` in Neovim

## Code Style Guidelines

### File Headers
All Lua modules must include:
```lua
---@module "module.path"
---@author Carlos Vigil-Vásquez  
---@license MIT 2025
```

### Formatting (stylua.toml)
- 96 character line width, 2-space indentation, Unix line endings
- Force double quotes, always use call parentheses, sort requires enabled
- Use `collapse_simple_statement = "Always"`

### Module Structure
- Use proper module pattern: `local M = {}` and `return M`
- Document all functions with EmmyLua annotations (`---@param`, `---@return`)
- Organize by: before/ (pre-setup), pkg/ (plugin specs), plugin/ (custom plugins), after/ftplugin/ (filetype config)

### Naming Conventions
- Snake_case for variables and functions
- PascalCase for types and classes  
- Descriptive names (avoid abbreviations)
- Use meaningful prefixes for config tables

## Repository Structure
- **lua/before/**: Pre-plugin initialization (leader key, globals, settings)
- **lua/pkg/**: Plugin specifications by category (llm, lsp, navigation, pkm, syntax, tools, ui)  
- **lua/plugin/**: Custom plugin implementations
- **plugin/**: Core Neovim configurations (autocmds, keymaps, lsp)
- **extras/**: Templates and skeletons
- **after/ftplugin/**: Filetype-specific configurations

## Error Handling
- Use `pcall()` for operations that might fail
- Provide meaningful error messages
- Check for nil values before use
- Use assertions for critical assumptions

*Note: No Cursor rules or Copilot instructions found in this repository.*