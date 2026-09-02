-- Options
vim.opt_local.expandtab = true
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt_local.foldmethod = "expr"
vim.opt_local.formatexpr = "v:lua.require('conform').formatexpr()"
vim.opt_local.textwidth = 96

-- Keymaps
vim.keymap.set("n", "<Tab>", "za", { noremap = true })
vim.keymap.set("n", "<S-Tab>", "zA", { noremap = true })

local ts_select = require("nvim-treesitter-textobjects.select")
local function textobject(lhs, capture, desc)
  vim.keymap.set(
    { "x", "o" },
    lhs,
    function() ts_select.select_textobject(capture, "textobjects") end,
    { buffer = true, desc = desc }
  )
end

textobject("ad", "@docstring.outer", "Around docstring")
textobject("id", "@docstring.inner", "Inside docstring")
textobject("af", "@julia_function.outer", "Around function")
textobject("if", "@julia_function.inner", "Inside function")
textobject("am", "@macro.outer", "Around macro call")
textobject("im", "@macro.inner", "Inside macro call")
textobject("at", "@type.outer", "Around type definition")
textobject("it", "@type.inner", "Inside type definition")
textobject("aM", "@module.outer", "Around module")
textobject("iM", "@module.inner", "Inside module")
textobject("ac", "@function_call.outer", "Around function call")
textobject("ic", "@function_call.inner", "Inside function call")
textobject("aa", "@argument.outer", "Around argument")
textobject("ia", "@argument.inner", "Inside argument")
textobject("a=", "@julia_assignment.outer", "Around assignment")
textobject("i=", "@julia_assignment.inner", "Inside assignment value")
textobject("ab", "@julia_block.outer", "Around block")
textobject("ib", "@julia_block.inner", "Inside block")

local ts_move = require("nvim-treesitter-textobjects.move")
local function movement(lhs, capture, move, desc)
  vim.keymap.set(
    { "n", "x", "o" },
    lhs,
    function() move(capture, "textobjects") end,
    { buffer = true, desc = desc }
  )
end

local movements = {
  d = { "@docstring.outer", "docstring" },
  f = { "@julia_function.outer", "function" },
  m = { "@macro.outer", "macro call" },
  t = { "@type.outer", "type definition" },
  M = { "@module.outer", "module" },
  c = { "@function_call.outer", "function call" },
  a = { "@argument.outer", "argument" },
  ["="] = { "@julia_assignment.outer", "assignment" },
  b = { "@julia_block.outer", "block" },
}

for noun, object in pairs(movements) do
  movement("]" .. noun, object[1], ts_move.goto_next_start, "Next " .. object[2])
  movement("[" .. noun, object[1], ts_move.goto_previous_start, "Previous " .. object[2])
end

-- JETLS diagnostics for this buffer, straight from the `jetls check` CLI: no
-- language server has to be running, and nothing stays resident afterwards.
vim.api.nvim_buf_create_user_command(
  0,
  "JetlsCheck",
  function() require("lib.jetls").check(0) end,
  { desc = "Check buffer with `jetls check`, into the quickfix list" }
)
vim.keymap.set(
  "n",
  "<leader>lc",
  function() require("lib.jetls").check(0) end,
  { buffer = true, desc = "Check buffer with JETLS" }
)
