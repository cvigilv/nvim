-- Functions {{{1
-- Hide section in Literate.jl {{{1
vim.api.nvim_create_user_command("HideLiterate", function(excmd_opts)
  if not excmd_opts.range then
    error("Only works for visually selected code", vim.log.levels.ERROR)
  end
  vim.cmd(string.format("%d,%dnormal %s", excmd_opts.line1, excmd_opts.line2, "A#hide"))
end, {
  desc = "Hides selected section in Literate.jl compliant script",
  range = true,
})

-- Toggle Markdown highlighting in Julia comments
local julia_markdown_injection_enabled = true

local function toggle_julia_markdown_injection()
  if julia_markdown_injection_enabled then
    -- Disable the injection
    vim.treesitter.query.set("julia", "injections", "")
    print("Julia Markdown injection disabled")
  else
    -- Enable the injection
    local query = [[
            ((line_comment) @injection.content
             (#set! injection.language "markdown")
             (#offset! @injection.content 0 2 0 0))
        ]]
    vim.treesitter.query.set("julia", "injections", query)
    print("Julia Markdown injection enabled")
  end

  julia_markdown_injection_enabled = not julia_markdown_injection_enabled

  -- Force a refresh of the highlighting
  vim.cmd("edit")
end

-- Create the Ex command
vim.api.nvim_create_user_command(
  "LitCmdMd",
  toggle_julia_markdown_injection,
  { desc = "Toggle Markdown highlighting in Julia comments" }
)
