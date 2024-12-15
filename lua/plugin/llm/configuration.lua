---@module "plugin.llm.configuration"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

---@class Claudio.Configuration
---@field api_key string Anthropic API key value
---@field tools Claudio.Tools.Configuration Configuration related to the tools functionality
---@field chat Claudio.Chat.Configuration Configuration related to the tools functionality

---@class Claudio.Tools.Configuration
---@field enabled boolean Whether to setup Tools functionality
---@field include_builtins boolean Whether to include built-in tool definitions
---@field prompts_dir string Path where user defined prompts are defined
---@field force_fts table|nil
---@field timeout integer Time out duration for requests

---@class Claudio.Chat.Configuration
---@field enabled boolean Whether to setup Chat functionality
---@field model string ID of model to use
---@field system_prompt string System prompt

--@type Claudio.Configuration
local defaults = {
  api_key = os.getenv("ANTHROPIC_API_KEY") --[[@as string]],
  model = "claude-3-5-sonnet-20240620",
  tools = {
    enabled = true,
    include_builtin = true,
    prompts_dir = vim.fn.stdpath("config") .. "/claudio/tools",
    force_fts = nil,
    timeout = 30,
  },
  chat = {
    enabled = true,
    system_prompt = "You are a useful code partner called Claudio.",
  },
}

local M = {}

--- Update defaults with user configuration
---@param opts Claudio.Configuration Claudio configuration table
---@return Claudio.Configuration opts Updated Claudio configuration table
M.updateconfig = function(opts)
  opts = opts and vim.tbl_deep_extend("force", {}, defaults, opts) or defaults

  -- Validate setup
  vim.validate({
    ["api_key"] = { opts.api_key, "string" },
    ["model"] = { opts.model, "string" },
    ["tools"] = { opts.tools, "table" },
    ["tools.enabled"] = { opts.tools.enabled, "boolean" },
    ["tools.include_builtin"] = { opts.tools.include_builtin, "boolean" },
    ["tools.prompts_dir"] = { opts.tools.prompts_dir, "string" },
    ["tools.timeout"] = { opts.tools.timeout, "number" },
    ["chat"] = { opts.chat, "table" },
    ["chat.enabled"] = { opts.chat.enabled, "boolean" },
    ["chat.system_prompt"] = { opts.chat.system_prompt, "string" },
  })

  return opts
end

return M
