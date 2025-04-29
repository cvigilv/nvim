-- HACK: Sticky shift commands (can't add the ! versions)
vim.api.nvim_create_user_command("Q", ":quit", {})
vim.api.nvim_create_user_command("Wq", ":wq", {})
vim.api.nvim_create_user_command("Wqa", ":wqa", {})

vim.api.nvim_create_user_command("AutoDenote", function()
  O = require("orgmode.api")
  D = require("denote.api")

  -- File status
  local filename = vim.fn.expand("%:p")
  local title
  local signature
  local keywords

  -- Get first header and tags for file
  local f = O.load(filename)
  local h1 = f:get_closest_headline({1,0})
  
  title = h1.title
  local tags = h1.all_tags

  -- Extract signature
  local possible_signatures = {"reference", "moc", "idea", "journal"}

  for _, tag in ipairs(tags) do
    if vim.tbl_contains(possible_signatures, tag) and signature == nil then
      signature = tag
    else
      if keywords == nil then
        keywords = {}
      end
      table.insert(keywords, tag)
    end
  end

  if title and signature and keywords then
    D.rename_file(filename, nil, title, signature, table.concat(keywords, " "), ".org")
  end

end, {})
