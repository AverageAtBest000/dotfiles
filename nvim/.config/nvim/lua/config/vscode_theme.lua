-- Read the theme VS Code actually uses, including the extension's contrast
-- adjustments. The raw Matugen Base16 palette is not the same color scheme.
local M = {}

function M.load()
  local paths =
    vim.fn.glob(vim.fn.expand("~/.vscode/extensions/haikalllp.matugen-theme-*/themes/matugen.json"), false, true)
  table.sort(paths, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)
  for _, path in ipairs(paths) do
    local ok, theme = pcall(function()
      return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
    end)
    if ok and type(theme) == "table" and type(theme.colors) == "table" then
      local background = theme.colors["editor.background"]
      if type(background) == "string" and background:match("^#%x%x%x%x%x%x$") then
        -- Neovim highlights have no RGBA support; composite onto the editor.
        local function color(value)
          if type(value) ~= "string" or not value:match("^#%x+$") then
            return nil
          end
          if #value == 7 then
            return value
          end
          if #value ~= 9 then
            return nil
          end
          local alpha = tonumber(value:sub(8, 9), 16) / 255
          local channels = {}
          for i = 2, 6, 2 do
            local fg = tonumber(value:sub(i, i + 1), 16)
            local bg = tonumber(background:sub(i, i + 1), 16)
            channels[#channels + 1] = math.floor(fg * alpha + bg * (1 - alpha) + 0.5)
          end
          return string.format("#%02x%02x%02x", unpack(channels))
        end
        local colors, tokens = {}, {}
        for name, value in pairs(theme.colors) do
          colors[name] = color(value)
        end
        for _, token in ipairs(theme.tokenColors or {}) do
          if token.name and token.settings then
            tokens[token.name] = color(token.settings.foreground)
          end
        end
        return { colors = colors, tokens = tokens }
      end
    end
  end
end

return M
