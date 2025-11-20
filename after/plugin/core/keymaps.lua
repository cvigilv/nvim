local map = vim.keymap.set

-- Quick-fix
map("n", "]Q", ":cnewer<CR>", { silent = false, desc = "Next quickfix list" })
map("n", "[Q", ":colder<CR>", { silent = false, desc = "Previous quickfix list" })

-- Execution
map("n", "<leader>x", ":source %<CR>", { silent = false, desc = "Source current file" })
map("v", "<leader>x", ":source<CR>", { silent = false, desc = "Source selected file" })

-- Diagnostics
vim.keymap.set(
  "n",
  "[d",
  function() vim.diagnostic.jump({ count = -1, float = true }) end,
  { desc = "Previous diagnostics", noremap = true }
)
vim.keymap.set(
  "n",
  "]d",
  function() vim.diagnostic.jump({ count = 1, float = true }) end,
  { desc = "Next diagnostics", noremap = true }
)
vim.keymap.set(
  "n",
  "<leader>d",
  vim.diagnostic.open_float,
  { desc = "Open diagnostics", noremap = true }
)

-- oil.nvim
vim.keymap.set(
  "n",
  "<leader><CR>",
  function() require("oil").open(nil, { preview = {} }) end,
  { desc = "File browser", noremap = true, silent = true }
)

-- conform.nvim
vim.keymap.set(
  "n",
  "<leader>lf",
  function() require("conform").format({ async = true }) end,
  { desc = "Format buffer" }
)

-- gitsigns
vim.keymap.set(
  "n",
  "<leader>ga",
  function() require("gitsigns").stage_hunk() end,
  { noremap = true, silent = true, desc = "Stage hunk" }
)
vim.keymap.set(
  "v",
  "<leader>ga",
  function() require("gitsigns").stage_hunk({ vim.fn.line("v"), vim.fn.line(".") }) end,
  { noremap = true, silent = true, desc = "Stage hunk" }
)
vim.keymap.set(
  "n",
  "<leader>gr",
  function() require("gitsigns").stage_hunk() end,
  { noremap = true, silent = true, desc = "Undo stage hunk" }
)
vim.keymap.set(
  "v",
  "<leader>gr",
  function() require("gitsigns").stage_hunk({ vim.fn.line("v"), vim.fn.line(".") }) end,
  { noremap = true, silent = true, desc = "Undo stage hunk" }
)
vim.keymap.set("n", "<leader>gd", function()
  require("gitsigns").preview_hunk_inline()
  require("gitsigns").toggle_linehl()
end, { noremap = true, silent = true, desc = "Toggle diff" })
vim.keymap.set(
  "n",
  "]g",
  function() require("gitsigns").nav_hunk("next") end,
  { noremap = true, silent = true, desc = "Go to next Git hunk" }
)
vim.keymap.set(
  "n",
  "[g",
  function() require("gitsigns").nav_hunk("prev") end,
  { noremap = true, silent = true, desc = "Go to previous Git hunk" }
)

-- orgmode
-- TODO Add some way to get last entry of topic and link it here
local function capture_to_denote()
  -- Generate timestamp
  local date = os.date("%Y%m%dT")
  local timestamp

  -- Get available topics
  local topics = {
    c = "Personal",
    p = "PhD",
    w = "Stepwise",
    ["?"] = "Custom",
  }
  vim
    .iter(vim.fn.glob(vim.g.denote.directory .. date .. "*==logs*.org", false, true, true))
    :fold({}, function(acc, v)
      local title = require("denote.frontmatter").parse_org_frontmatter(v).title
        or require("denote.naming").parse_filename(v, false).title
        or nil
      if title == nil then return acc end

      local topic = title:sub(14)
      if not vim.tbl_contains(vim.tbl_values(topics), topic) then
        acc[tostring(#vim.tbl_values(acc) + 1)] = topic
        topics[tostring(#vim.tbl_values(acc))] = topic
      end
      return acc
    end)

  -- Convert topics into prompts
  local prompts = vim.iter(topics):fold({}, function(acc, k, v)
    table.insert(acc, { string.format("%s  %s\n", k, v), "MsgArea" })
    return acc
  end)

  table.sort(prompts, function(a, b) return a[1] < b[1] end)
  table.insert(prompts, 1, { "[pkm] Select a topic ('q' to quit):\n", "MsgArea" })
  local topic = nil
  while topic == nil do
    vim.api.nvim_echo(prompts, false, {})
    local key = vim.fn.getchar()
    if type(key) == "number" then key = vim.fn.nr2char(key) end
    if key == "q" or key == "" then
      break
    elseif key == "?" then
      vim.ui.input({ prompt = "Topic: " }, function(v) topic = v end)
    elseif vim.tbl_contains(vim.tbl_keys(topics), key) then
      topic = topics[key]
    end
  end

  -- Get the target file path first
  local target_file = vim.fn.expand(
    vim.g.denote.directory
      .. date
      .. "*"
      .. "==logs"
      .. (topic ~= nil and (require("denote.naming").as_component_string(
        os.date("%Y%m%d") .. " " .. topic,
        "title"
      )) or "daily")
      .. require("denote.naming").as_component_string(topic, "keywords")
      .. "*.org"
  )
  local file_exists = vim.fn.filereadable(target_file) == 1
  if not file_exists then
    local time = os.date("%H%M%S")
    timestamp = date .. time
    target_file = target_file:gsub("*", time, 1)
    target_file = target_file:gsub("*", "", 1)
  end

  -- Create template based on file existence
  local opts
  if file_exists then
    opts = { template = {} }
  else
    opts = {
      template = {
        "#+title:      %<%Y/%m/%d>" .. (topic ~= nil and (" - " .. topic) or ""),
        "#+date:       %<%Y-%m-%d %a %H:%M:%S>",
        "#+identifier: " .. timestamp,
        "#+filetags:   " .. (topic ~= nil and ":" .. topic:lower() .. ":" or ""),
        "#+signature:  logs",
        "",
        "* %<%Y/%m/%d>" .. (topic ~= nil and (" - " .. topic) or ""),
        "",
      },
    }
  end
  table.insert(opts.template, "** [%<%Y-%m-%d %a %H:%M:%S>]%?")
  opts.whole_file = true
  opts.target = target_file
  opts.description = "Denote note"
  opts.properties = { empty_lines = 1 }
  return require("orgmode.capture.template"):new(opts)
end

local function smart_denote_capture()
  local template = capture_to_denote()
  if template then require("orgmode").capture:open_template(template) end
end
vim.keymap.set("n", ",O", smart_denote_capture)
