# AGENTS.md - Neovim Configuration Codebase Guide

## Build/Lint/Test Commands

### Primary Commands
- **Format Lua**: `stylua .` (configured in stylua.toml)
- **Lint Lua**: `luacheck lua/` (no .luacheckrc found, uses defaults)
- **Test Plugin**: `make test` (uses Plenary test framework)
- **Format in Neovim**: `:lua require("conform").format()` or `<leader>lf`

### Running Single Tests
For individual test files, use the Plenary test runner:
```bash
nvim --headless --noplugin -u scripts/minimal_init.vim -c "PlenaryBustedFile path/to/test_file.lua"
```

### Test Structure (Plenary + luassert)
Use the template in `extras/skeletons/personal/lua/test.lua`:
```lua
local eq = assert.are.same
local is_true = assert.is.True

describe("function_name", function()
  before_each(function()
    -- Setup
  end)
  
  it("should do something", function() 
    -- Test implementation
    eq(expected, actual)
  end)
end)
```

## Code Style Guidelines

### File Headers (Required)
All Lua modules MUST include this exact header format:
```lua
---@module "module.path.name"
---@author Carlos Vigil-Vásquez
---@license MIT 2025
```

### Formatting Rules (stylua.toml)
- **Line width**: 96 characters
- **Indentation**: 2 spaces (not tabs)
- **Line endings**: Unix (LF)
- **Quotes**: Always double quotes (`"`)
- **Parentheses**: Always use call parentheses
- **Sort requires**: Enabled
- **Simple statements**: Always collapse

### Module Structure Pattern
```lua
---@module "module.name"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

---@param param_name type Description
---@return type Description
function M.function_name(param_name)
  -- Implementation
end

return M
```

### EmmyLua Type Annotations
- Document ALL public functions with `---@param` and `---@return`
- Use descriptive parameter and return type documentation
- Include module declarations with `---@module`
- Use `---@diagnostic disable` sparingly and only when necessary

### Naming Conventions
- **Variables/Functions**: `snake_case` (e.g., `my_function`, `local_var`)
- **Modules**: `snake_case` with dots (e.g., `lib.statuscolumn.components`)  
- **Types/Classes**: `PascalCase` (e.g., `MyClass`, `ConfigTable`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `MAX_RETRIES`)
- **Private functions**: Prefix with underscore (e.g., `_internal_helper`)
- Avoid abbreviations - use descriptive names

### Import/Require Organization
- Sort requires alphabetically (enforced by stylua)
- Group local requires at the top of functions when possible
- Use meaningful variable names for required modules

## Repository Structure

### Core Directories
- **`init.lua`**: Entry point, requires `before` and `pkg` modules
- **`lua/before/`**: Pre-plugin initialization (settings, leader keys, globals)
- **`lua/pkg/`**: Plugin specifications organized by category
  - `llm.lua`, `lsp.lua`, `navigation.lua`, `pkm.lua`, `syntax.lua`, `tools.lua`, `ui.lua`
- **`lua/plugin/`**: Custom plugin implementations and configurations
- **`lua/lib/`**: Reusable utility libraries and helper modules
- **`plugin/`**: Core Neovim configurations (autocmds, keymaps, LSP configs)
- **`after/ftplugin/`**: Filetype-specific configurations
- **`lsp/`**: Language server specific configurations
- **`colors/`**: Custom colorschemes (`claro.lua`, `oscuro.lua`)
- **`extras/`**: Templates, skeletons, and additional resources

### File Organization Patterns
- Plugin specs in `lua/pkg/` should return Lazy.nvim compatible tables
- Custom plugins in `lua/plugin/` should follow the module pattern
- Library modules in `lua/lib/` should be pure utilities without side effects
- Filetype configs in `after/ftplugin/` should be buffer-local only

## Configuration Patterns

### Vim Settings Structure
Settings are centralized in `lua/before/settings.lua` with clear organization:
- Disable unwanted built-in plugins with `vim.g.loaded_*`
- Use descriptive comments for each option
- Group related settings together (UI, behavior, performance)

### Plugin Configuration
- Use lazy loading when appropriate (`ft`, `cmd`, `keys` properties)
- Prefer `config = true` for simple setups
- Extract complex configurations to separate modules
- Use meaningful variable names in plugin specs

## Error Handling & Best Practices

### Error Handling Patterns
```lua
-- For operations that might fail
local success, result = pcall(risky_function, args)
if not success then
  vim.notify("Error: " .. result, vim.log.levels.ERROR)
  return nil
end

-- For nil checks
if not value then
  error("Expected value but got nil", 2)
end

-- For assertions on critical assumptions  
assert(condition, "Critical assumption failed: " .. description)
```

### Performance Considerations
- Use `vim.schedule()` for heavy operations in autocommands
- Prefer buffer-local mappings in ftplugin files
- Cache expensive computations when appropriate
- Use `vim.tbl_*` functions for table operations

### Documentation Standards
- Write clear, concise function descriptions
- Document side effects and state changes
- Include usage examples for complex functions
- Explain non-obvious implementation decisions with comments

## Testing Guidelines

### Test File Structure
- Place test files adjacent to the modules they test
- Use descriptive test names that explain expected behavior
- Group related tests using `describe()` blocks
- Use `before_each()` for test setup, avoid global state

### Test Data Management
- Create minimal test fixtures
- Avoid dependency on external files or network
- Use temporary files for file system tests
- Clean up resources in test teardown

*Note: No Cursor rules (.cursor/rules/ or .cursorrules) or Copilot instructions (.github/copilot-instructions.md) found in this repository.*