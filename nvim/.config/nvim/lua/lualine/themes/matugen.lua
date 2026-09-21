-- Keep the statusline on the same palette instead of auto-adjusting its hues.
local function color(group, key)
  return string.format("#%06x", vim.api.nvim_get_hl(0, { name = group, link = false })[key])
end

local bg = color("Normal", "bg")
local fg = color("Normal", "fg")
local theme = {}
for mode, group in pairs({
  normal = "Function",
  insert = "String",
  visual = "Keyword",
  replace = "Number",
  command = "Function",
  terminal = "Function",
}) do
  local accent = color(group, "fg")
  theme[mode] = {
    a = { fg = bg, bg = accent, gui = "bold" },
    b = { fg = accent, bg = bg },
    c = { fg = fg, bg = bg },
  }
end
theme.inactive = {
  a = { fg = color("Comment", "fg"), bg = bg },
  b = { fg = color("Comment", "fg"), bg = bg },
  c = { fg = color("Comment", "fg"), bg = bg },
}
return theme
