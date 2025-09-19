---@module "plugin.denote-darwin.graph"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

local function complete_graph()
  local dir = vim.g.denote.directory

  local edges = {}

  for source, links in pairs(_G.denote_cache_links) do
    local source_components = require("denote.naming").parse_filename(vim.fs.basename(source))
    if links ~= {} then
      for _, link in ipairs(links) do
        local target = link.path
        local target_components =
          require("denote.naming").parse_filename(vim.fs.basename(target))
        if vim.tbl_contains(vim.tbl_keys(_G.denote_cache_links), target) then
          table.insert(edges, {
            source = source_components.identifier,
            target = target_components.identifier,
            weight = 1,
          })
        end
      end
    end
  end

  local nodes = (
    vim
      .iter(vim.tbl_keys(_G.denote_cache_links))
      :map(function(f)
        local ft = vim.filetype.match({ filename = f })
        local components = vim.tbl_deep_extend(
          "force",
          {},
          require("denote.naming").parse_filename(f, false) or {},
          require("denote.frontmatter").parse_frontmatter(f, ft) or {}
        )

        components.keywords = type(components.keywords) == "string"
            and vim.split(components.keywords, "_")
          or components.keywords

        return {
          id = components.identifier,
          signature = components.signature,
          name = components.title,
          keywords = components.keywords,
          type = ft,
          filename = f,
          degree = #_G.denote_cache_links[f] or 0,
          backlinks = #require("denote.links").get_backlinks(f) or 0,
        }
      end)
      :totable()
  )

  local meta = {
    directed = true,
    type = "Global",
    parameters = {},
  }

  local template = "/Users/carlos/git/nvim/extras/denote-explore-network.html"

  local template_contents = table.concat(vim.fn.readfile(template), "\n"):gsub(
    "GRAPHDATA",
    vim.json.encode({ meta = meta, nodes = nodes, edges = edges })
  )
  vim.fn.writefile(vim.split(template_contents, "\n"), "/tmp/denote-graph.html")
  vim.fn.jobstart("open /tmp/denote-graph.html", { detach = true })
end
complete_graph()

return M
