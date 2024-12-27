---@module "user.pkgs.trees"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

return {
  {
    "hedyhli/outline.nvim",
    config = function()
      vim.keymap.set("n", "<leader>ts", "<cmd>Outline<CR>", { desc = "Toggle Outline" })

      require("outline").setup({
        outline_window = {
          position = "left",
          auto_close = false,
          auto_jump = false,
          jump_highlight_duration = 500,
          hide_cursor = true,
          winhl = "Normal:ColorColumn,CursorLine:Normal",
        },

        outline_items = {
          show_symbol_lineno = true,
          markers = { "", "" },
        },

        guides = {
          markers = {
            bottom = "┗",
            middle = "┣",
            vertical = "┃",
          },
        },

        providers = {
          priority = { "lsp", "markdown" },
        },

        symbols = {
          icons = {
            Array = { icon = "󰅪", hl = "Constant" },
            Boolean = { icon = "⊨", hl = "Boolean" },
            Class = { icon = "𝓒", hl = "Type" },
            Component = { icon = "󰅴", hl = "Function" },
            Constant = { icon = "󰏿", hl = "Constant" },
            Constructor = { icon = "󰒓", hl = "Special" },
            Enum = { icon = "󰦨", hl = "Type" },
            EnumMember = { icon = "󰦨", hl = "Identifier" },
            Event = { icon = "󱐋", hl = "Type" },
            Field = { icon = "󰜢", hl = "Identifier" },
            File = { icon = "󰈔", hl = "Identifier" },
            Fragment = { icon = "󰅴", hl = "Constant" },
            Function = { icon = "󰊕", hl = "Function" },
            Interface = { icon = "󱡠", hl = "Type" },
            Key = { icon = "", hl = "Type" },
            Macro = { icon = " ", hl = "Function" },
            Method = { icon = "󰊕", hl = "Function" },
            Module = { icon = "󰅩", hl = "Include" },
            Namespace = { icon = "󰅪", hl = "Include" },
            Null = { icon = "NULL", hl = "Type" },
            Number = { icon = "#", hl = "Number" },
            Object = { icon = "⦿", hl = "Type" },
            Operator = { icon = "󰪚", hl = "Identifier" },
            Package = { icon = "󰏗", hl = "Include" },
            Parameter = { icon = " ", hl = "Identifier" },
            Property = { icon = "󰖷", hl = "Identifier" },
            StaticMethod = { icon = " ", hl = "Function" },
            String = { icon = "󰉿", hl = "String" },
            Struct = { icon = "󱡠", hl = "Structure" },
            TypeAlias = { icon = " ", hl = "Type" },
            TypeParameter = { icon = "󰬛𝙏", hl = "Identifier" },
            Variable = { icon = "󰆦", hl = "Constant" },
          },
        },
      })
    end,
  },
}
