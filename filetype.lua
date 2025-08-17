vim.filetype.add({
  extension = {
    log = "log",
  },
  pattern = {
    ["/Users/carlos/org/*"] = function(_, _, ext)
      print("[filetype.lua] Setting as '" .. ext .. ".denote'")
      return ext .. "denote" end,
  },
})
