local function create_timestamped_file()
  local timestamp = os.date("%Y%m%dT%H%M%S")
  local filename = timestamp .. ".anki"
  vim.cmd("e " .. filename)
end

vim.keymap.set(
  "n",
  "<leader>an",
  function()
    vim.cmd("AnkiSend")
    create_timestamped_file()
  end,
  { noremap = true, silent = true }
)

vim.keymap.set("n", ",ap", function() vim.cmd("Anki Basic") end)
