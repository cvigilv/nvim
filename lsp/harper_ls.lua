---@brief
---
--- https://github.com/automattic/harper
---
--- The language server for Harper, the slim, clean language checker for developers.
---
--- See our [documentation](https://writewithharper.com/docs/integrations/neovim) for more information on settings.
---
--- In short, they should look something like this:
--- ```lua
--- vim.lsp.config('harper_ls', {
---   settings = {
---     ["harper-ls"] = {
---       userDictPath = "~/dict.txt"
---     }
---   },
--- })
--- ```

local writing_filetypes = {
  "org",
  "markdown",
  "typst",
  "tex",
  "text",
}

local is_writing_ft = function()
  local ft = vim.bo.filetype
  return vim.tbl_contains(writing_filetypes, ft)
end

---@type vim.lsp.Config
return {
  cmd = { "harper-ls", "--stdio" },
  filetypes = {
    "org.denote",
    "markdown.denote",
    "text.denote",
    "org",
    "markdown",
    "typst",
    "gitcommit",
  },
  root_markers = { ".git" },
  settings = {
    userDictPath = "",
    fileDictPath = "",
    linters = {
      SpellCheck = is_writing_ft(),
      SpelledNumbers = false,
      AnA = true,
      SentenceCapitalization = is_writing_ft(),
      UnclosedQuotes = true,
      WrongQuotes = false,
      LongSentences = is_writing_ft(),
      RepeatedWords = true,
      Spaces = true,
      Matcher = true,
      CorrectNumberSuffix = true,
    },
    codeActions = {
      ForceStable = false,
    },
    markdown = {
      IgnoreLinkTitle = false,
    },
    diagnosticSeverity = "hint",
    isolateEnglish = true,
  },
}
