---@module 'lib.tabline.ui'
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

---Table of icons for tab indexing with nested boolean states.
---@type table<number|string, table<boolean, string>>
M.index_icons = {
  [1] = { [false] = "󰲡 ", [true] = "󰲠 " },
  [2] = { [false] = "󰲣 ", [true] = "󰲢 " },
  [3] = { [false] = "󰲥 ", [true] = "󰲤 " },
  [4] = { [false] = "󰲧 ", [true] = "󰲦 " },
  [5] = { [false] = "󰲩 ", [true] = "󰲨 " },
  [6] = { [false] = "󰲫 ", [true] = "󰲪 " },
  [7] = { [false] = "󰲭 ", [true] = "󰲬 " },
  [8] = { [false] = "󰲯 ", [true] = "󰲮 " },
  [9] = { [false] = "󰲱 ", [true] = "󰲰 " },
  more = { [false] = "󰲳 ", [true] = "󰲲 " },
}

return M
