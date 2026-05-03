local conform = require("conform")
local lint = require("lint")

-- Tools per language
local languages = {
  ["*"] = { formatter = { "trim_whitespace", "trim_newlines" }, linter = nil },
  bib = { formatter = { "bibtex-tidy" }, linter = nil },
  json = { formatter = { "jq" }, linter = nil },
  julia = { formatter = { "runic" }, linter = nil },
  lua = { formatter = { "stylua" }, linter = { "luacheck" } },
  markdown = { formatter = { "injected" }, linter = nil },
  python = { formatter = { "ruff" }, linter = { "mypy" } },
  sh = { formatter = { "shfmt" }, linter = { "shellcheck" } },
  typst = { formatter = { "typstyle" }, linter = nil },
}

-- Custom formatters
conform.formatters = {
  runic = {
    command = "julia",
    args = { "--project=@runic", "-e", "using Runic; exit(Runic.main(ARGS))" },
  },
  typstyle = {
    command = "typstyle",
    args = { "-i" },
  },
}

-- Tool configuration
lint.linters_by_ft = {}
conform.setup({
  notify_on_error = true,
  notify_no_formatters = false,
  default_format_opts = {
    quiet = true,
    lsp_fallback = "first",
    timeout_ms = 10000,
  },
})
for ft, tools in pairs(languages) do
  conform.formatters_by_ft[ft] = tools["formatter"]
  if tools.linter then table.insert(lint.linters_by_ft, { [ft] = tools.linter }) end
end

-- Autocommands
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  pattern = "*",
  callback = function() require("lint").try_lint() end,
  desc = "Automatic linting",
})

-- Keymaps
vim.keymap.set(
  "n",
  "<leader>lf",
  function() require("conform").format({ async = true }) end,
  { desc = "Format buffer" }
)

-- Completion
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "blink.cmp" and (kind == "install" or kind == "update") then
      vim.notify("[pkg] Rebuilding blink.cmp", vim.log.levels.INFO)
      require("blink.cmp").build():wait(60000)
    end
  end,
})

require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<C-x><C-o>"] = { "show", "fallback" },
    ["<C-x><C-n>"] = {
      function(cmp) return cmp.show({ providers = { "buffer" } }) end,
      "fallback",
    },
    ["<C-x><C-f>"] = {
      function(cmp) return cmp.show({ providers = { "path" } }) end,
      "fallback",
    },
  },
  completion = {
    documentation = {
      auto_show = true,
      window = {
        min_width = 64,
        max_width = 64,
        max_height = 32,
        border = { "🬕", "🬂", "🬨", "▐", "🬷", "🬭", "🬲", "▌" },
      },
    },
    menu = {
      auto_show_delay_ms = 500,
      border = { "🬕", "🬂", "🬨", "▐", "🬷", "🬭", "🬲", "▌" },
      draw = {
        columns = {
          { "label", "label_description", gap = 1 },
          { "kind" },
        },
      },
    },
  },
  sources = {
    default = { "lazydev", "lsp", "snippets", "omni" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },
  },
  fuzzy = {
    sorts = {
      "exact",
      "score",
      "sort_text",
    },
  },
})

-- TODO: check https://github.com/disrupted/blink-cmp-conventional-commits

-- TODO: See how i could imlpement something like this
-- local cmp = require("blink.cmp")
-- if cmp.windows and cmp.windows.autocomplete then
--   cmp.on_open(vim.cmd("Copilot disable"))
--   cmp.on_close(vim.cmd("Copilot enable"))
-- end
