local fallback = {
  background = "#111318",
  surface = "#111318",
  surface_low = "#191c20",
  surface_high = "#282a2f",
  surface_highest = "#32353a",
  foreground = "#e1e2e9",
  muted = "#c3c6cf",
  outline = "#8d9199",
  outline_variant = "#43474e",
  primary = "#a6c8ff",
  on_primary = "#01315e",
  primary_container = "#224876",
  on_primary_container = "#d5e3ff",
  secondary = "#bcc7dc",
  on_secondary = "#273141",
  secondary_container = "#3d4758",
  on_secondary_container = "#d8e3f8",
  tertiary = "#dabde2",
  on_tertiary = "#3d2846",
  tertiary_container = "#553f5d",
  on_tertiary_container = "#f7d8ff",
  error = "#ffb4ab",
  on_error = "#690005",
  error_container = "#93000a",
  on_error_container = "#ffdad6",
  base00 = "#0b203d",
  base01 = "#2e4059",
  base02 = "#516075",
  base03 = "#738090",
  base04 = "#96a0ac",
  base05 = "#b9bfc8",
  base06 = "#dcdfe3",
  base07 = "#ffffff",
  base08 = "#ff86b0",
  base09 = "#e594bd",
  base0a = "#87aeeb",
  base0b = "#1fc744",
  base0c = "#cc9bde",
  base0d = "#76afff",
  base0e = "#dd8dff",
  base0f = "#7e828b",
}

local palette_path = vim.fn.expand("~/.cache/matugen/nvim-colors.lua")
local ok, generated = pcall(dofile, palette_path)
local c = ok and type(generated) == "table" and vim.tbl_extend("force", fallback, generated) or fallback

local function rgb(hex)
  local r, g, b = hex:match("#(%x%x)(%x%x)(%x%x)")
  if not r then
    return 0, 0, 0
  end
  return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
end

local function channel(value)
  value = value / 255
  return value <= 0.04045 and value / 12.92 or ((value + 0.055) / 1.055) ^ 2.4
end

local function luminance(hex)
  local r, g, b = rgb(hex)
  return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
end

local function contrast(a, b)
  local first, second = luminance(a), luminance(b)
  local lighter, darker = math.max(first, second), math.min(first, second)
  return (lighter + 0.05) / (darker + 0.05)
end

local function readable(color, replacement)
  local r, g, b = rgb(color)
  local chroma = math.max(r, g, b) - math.min(r, g, b)
  return contrast(color, c.background) >= 3 and chroma >= 24 and color or replacement
end

-- Dark, low-saturation source images can make Matugen's Base16 accents nearly
-- monochrome or identical to the background. Retain them when vivid and
-- legible; otherwise use Matugen's high-contrast Material roles.
c.base08 = readable(c.base08, c.primary)
c.base09 = readable(c.base09, c.tertiary)
c.base0a = readable(c.base0a, c.secondary)
c.base0b = readable(c.base0b, c.tertiary)
c.base0c = readable(c.base0c, c.secondary)
c.base0d = readable(c.base0d, c.primary)
c.base0e = readable(c.base0e, c.tertiary)
c.base0f = readable(c.base0f, c.outline)

local vscode = require("config.vscode_theme").load()
local ui = vscode and vscode.colors or {}
local tokens = vscode and vscode.tokens or {}
c.background = ui["editor.background"] or c.background
c.foreground = ui["editor.foreground"] or c.foreground
c.surface_low = ui["editorWidget.background"] or c.surface_low
c.surface_high = ui["editorSuggestWidget.background"] or c.surface_high
c.surface_highest = ui["editor.selectionBackground"] or c.surface_highest
c.muted = ui["descriptionForeground"] or c.muted
c.outline = ui["editorGutter.foldingControlForeground"] or c.outline
c.outline_variant = ui["editorIndentGuide.background1"] or c.outline_variant
c.primary = ui["textLink.foreground"] or c.primary
c.on_primary = ui["button.foreground"] or c.on_primary
c.primary_container = ui["list.activeSelectionBackground"] or c.primary_container
c.on_primary_container = ui["list.activeSelectionForeground"] or c.on_primary_container
c.error = ui["editorError.foreground"] or c.error
c.error_container = ui["inputValidation.errorBackground"] or c.error_container
c.on_error_container = c.error
c.base03 = tokens.Comment or c.base03
c.base05 = c.foreground
c.base08 = tokens.Variable or c.base08
c.base09 = tokens.Number or c.base09
c.base0a = tokens.Type or c.base0a
c.base0b = tokens.String or c.base0b
c.base0c = tokens["Keyword Operator"] or c.base0c
c.base0d = tokens.Function or c.base0d
c.base0e = tokens.Keyword or c.base0e
local warning = ui["editorWarning.foreground"] or c.base0a

local function is_dark(hex)
  local r, g, b = rgb(hex)
  return 0.299 * r + 0.587 * g + 0.114 * b < 128
end

vim.o.background = is_dark(c.background) and "dark" or "light"
vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd.syntax("reset")
end
vim.g.colors_name = "matugen"

local function hi(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

local function link(group, target)
  hi(group, { link = target })
end

-- Editor UI
hi("Normal", { fg = c.foreground, bg = c.background })
hi("NormalNC", { fg = c.foreground, bg = c.background })
hi("NormalFloat", { fg = c.foreground, bg = c.surface_low })
hi("FloatBorder", { fg = c.outline, bg = c.surface_low })
hi("FloatTitle", { fg = c.primary, bg = c.surface_low, bold = true })
hi("Cursor", { fg = c.background, bg = ui["editorCursor.foreground"] or c.primary })
hi("CursorLine", { bg = ui["editor.lineHighlightBackground"] or c.surface_low })
hi("CursorColumn", { bg = c.surface_low })
hi("ColorColumn", { bg = c.surface_low })
hi("LineNr", { fg = ui["editorLineNumber.foreground"] or c.outline_variant })
hi("CursorLineNr", { fg = ui["editorLineNumber.activeForeground"] or c.primary, bold = true })
hi("SignColumn", { fg = c.outline, bg = c.background })
hi("FoldColumn", { fg = c.outline, bg = c.background })
hi("Folded", { fg = c.muted, bg = c.surface_low })
hi("WinSeparator", { fg = c.outline_variant })
link("VertSplit", "WinSeparator")
hi("StatusLine", { fg = ui["statusBar.foreground"] or c.foreground, bg = ui["statusBar.background"] or c.background })
hi("StatusLineNC", { fg = c.muted, bg = c.surface_low })
hi("TabLine", { fg = c.muted, bg = c.surface_low })
hi("TabLineFill", { bg = c.background })
hi("TabLineSel", { fg = c.on_primary_container, bg = c.primary_container, bold = true })
hi("WinBar", { fg = c.foreground, bg = c.background, bold = true })
hi("WinBarNC", { fg = c.muted, bg = c.background })
hi("Pmenu", { fg = c.foreground, bg = c.surface_high })
hi("PmenuSel", { fg = c.on_primary_container, bg = c.primary_container, bold = true })
hi("PmenuSbar", { bg = c.surface_highest })
hi("PmenuThumb", { bg = c.outline })
hi("Search", { fg = c.foreground, bg = ui["editor.findMatchHighlightBackground"] or c.secondary_container })
hi("IncSearch", { fg = c.foreground, bg = ui["editor.findMatchBackground"] or c.primary_container, bold = true })
link("CurSearch", "IncSearch")
hi("Visual", { bg = c.surface_highest })
hi("MatchParen", { fg = c.tertiary, bold = true, underline = true })
hi("Directory", { fg = c.primary })
hi("Title", { fg = c.primary, bold = true })
hi("Question", { fg = c.tertiary })
hi("ModeMsg", { fg = c.secondary, bold = true })
hi("MoreMsg", { fg = c.tertiary })
hi("WarningMsg", { fg = warning })
hi("ErrorMsg", { fg = c.error, bold = true })
hi("NonText", { fg = c.outline_variant })
link("Whitespace", "NonText")
link("EndOfBuffer", "NonText")
hi("Conceal", { fg = c.outline })
hi("SpecialKey", { fg = c.outline })
hi("WildMenu", { fg = c.on_primary, bg = c.primary })
hi("QuickFixLine", { bg = c.surface_high })

-- Vim syntax and Treesitter
hi("Comment", { fg = c.base03, italic = true })
hi("Constant", { fg = c.base09 })
hi("String", { fg = c.base0b })
link("Character", "String")
link("Number", "Constant")
link("Boolean", "Constant")
link("Float", "Constant")
hi("Identifier", { fg = c.base08 })
hi("Function", { fg = c.base0d })
hi("Statement", { fg = c.base0e })
link("Conditional", "Statement")
link("Repeat", "Statement")
link("Label", "Statement")
link("Keyword", "Statement")
link("Exception", "Statement")
hi("PreProc", { fg = c.base0c })
link("Include", "PreProc")
link("Define", "PreProc")
link("Macro", "PreProc")
link("PreCondit", "PreProc")
hi("Type", { fg = c.base0a })
link("StorageClass", "Type")
link("Structure", "Type")
link("Typedef", "Type")
hi("Special", { fg = c.base0c })
link("SpecialChar", "Special")
link("Tag", "Special")
link("Delimiter", "Special")
link("SpecialComment", "Special")
link("Debug", "Special")
hi("Underlined", { fg = c.primary, underline = true })
hi("Error", { fg = c.on_error_container, bg = c.error_container })
hi("Todo", { fg = c.on_primary_container, bg = c.primary_container, bold = true })

local treesitter_links = {
  ["@annotation"] = "PreProc",
  ["@attribute"] = "PreProc",
  ["@boolean"] = "Boolean",
  ["@character"] = "Character",
  ["@comment"] = "Comment",
  ["@comment.error"] = "DiagnosticError",
  ["@comment.note"] = "DiagnosticInfo",
  ["@comment.todo"] = "Todo",
  ["@comment.warning"] = "DiagnosticWarn",
  ["@constant"] = "Constant",
  ["@constructor"] = "Type",
  ["@diff.delta"] = "DiffChange",
  ["@diff.minus"] = "DiffDelete",
  ["@diff.plus"] = "DiffAdd",
  ["@function"] = "Function",
  ["@function.builtin"] = "Function",
  ["@function.call"] = "Function",
  ["@keyword"] = "Keyword",
  ["@label"] = "Label",
  ["@markup.heading"] = "Title",
  ["@markup.italic"] = "Italic",
  ["@markup.link"] = "Underlined",
  ["@markup.raw"] = "String",
  ["@markup.strong"] = "Bold",
  ["@markup.strikethrough"] = "DiagnosticDeprecated",
  ["@module"] = "Include",
  ["@number"] = "Number",
  ["@operator"] = "Operator",
  ["@property"] = "Identifier",
  ["@punctuation"] = "Delimiter",
  ["@string"] = "String",
  ["@tag"] = "Tag",
  ["@type"] = "Type",
  ["@type.builtin"] = "Type",
  ["@variable"] = "Identifier",
  ["@variable.builtin"] = "Special",
}
for group, target in pairs(treesitter_links) do
  link(group, target)
end
hi("Bold", { bold = true })
hi("Italic", { italic = true })
hi("Operator", { fg = tokens["Keyword Operator"] or c.base05 })
hi("Delimiter", { fg = tokens.Punctuation or c.foreground })
hi("Tag", { fg = tokens.Tag or c.base08 })
hi("@punctuation.bracket", { fg = tokens["Punctuation Brackets"] or c.foreground })
hi("@function.builtin", { fg = tokens["Support Function"] or c.base0d })
hi("@string.escape", { fg = tokens["String Escape"] or c.base0c })
hi("@variable.parameter", { fg = tokens.Parameter or c.base08, italic = true })
hi("@variable.builtin", { fg = tokens["Language Variable"] or c.base08, italic = true })
hi("@module", { fg = tokens.Module or c.base0b })
hi("@attribute", { fg = tokens.Decorator or c.base09 })
hi("@markup.heading", { fg = tokens["Markdown Heading"] or c.primary, bold = true })
hi("@markup.strong", { fg = tokens["Markdown Bold"] or c.base09, bold = true })
hi("@markup.italic", { fg = tokens["Markdown Italic"] or c.base0e, italic = true })

-- Diagnostics, diffs, and Git
hi("DiagnosticError", { fg = c.error })
hi("DiagnosticWarn", { fg = warning })
hi("DiagnosticInfo", { fg = c.primary })
hi("DiagnosticHint", { fg = ui["editorHint.foreground"] or c.tertiary })
hi("DiagnosticOk", { fg = c.base0b })
hi("DiagnosticUnderlineError", { sp = c.error, undercurl = true })
hi("DiagnosticUnderlineWarn", { sp = warning, undercurl = true })
hi("DiagnosticUnderlineInfo", { sp = c.primary, undercurl = true })
hi("DiagnosticUnderlineHint", { sp = ui["editorHint.foreground"] or c.tertiary, undercurl = true })
hi("DiagnosticDeprecated", { strikethrough = true, sp = c.outline })
hi("DiffAdd", { fg = c.base0b, bg = c.surface_low })
hi("DiffChange", { fg = ui["editorGutter.modifiedBackground"] or c.base0a, bg = c.surface_low })
hi("DiffDelete", { fg = c.error, bg = c.surface_low })
hi("DiffText", { fg = c.on_primary_container, bg = c.primary_container, bold = true })
link("Added", "DiffAdd")
link("Changed", "DiffChange")
link("Removed", "DiffDelete")
hi("GitSignsAdd", { fg = c.base0b })
hi("GitSignsChange", { fg = ui["editorGutter.modifiedBackground"] or c.base0a })
hi("GitSignsDelete", { fg = c.error })

-- LSP semantic tokens
link("@lsp.type.class", "Type")
link("@lsp.type.decorator", "PreProc")
link("@lsp.type.enum", "Type")
link("@lsp.type.enumMember", "Constant")
link("@lsp.type.function", "Function")
link("@lsp.type.interface", "Type")
link("@lsp.type.macro", "Macro")
link("@lsp.type.method", "Function")
link("@lsp.type.namespace", "Include")
link("@lsp.type.parameter", "@variable.parameter")
link("@lsp.type.property", "Identifier")
link("@lsp.type.struct", "Type")
link("@lsp.type.type", "Type")
link("@lsp.type.typeParameter", "Type")
link("@lsp.type.variable", "Identifier")
hi("@lsp.typemod.variable.readonly", { fg = tokens["Variable Constant"] or c.base09 })
hi("@lsp.typemod.variable.defaultLibrary", { fg = tokens["Support Function"] or c.base0d })
hi("@lsp.type.enumMember", { fg = tokens.Type or c.base0a })

-- LazyVim's common UI plugins
hi("BlinkCmpLabel", { fg = c.foreground })
hi("BlinkCmpLabelDeprecated", { fg = c.outline, strikethrough = true })
hi("BlinkCmpLabelMatch", { fg = c.primary, bold = true })
hi("BlinkCmpKind", { fg = c.tertiary })
hi("BlinkCmpSource", { fg = c.outline })
hi("BlinkCmpMenu", { fg = c.foreground, bg = c.surface_high })
hi("BlinkCmpMenuBorder", { fg = c.outline, bg = c.surface_high })
hi("BlinkCmpDoc", { fg = c.foreground, bg = c.surface_low })
hi("BlinkCmpDocBorder", { fg = c.outline, bg = c.surface_low })
hi("WhichKey", { fg = c.primary })
hi("WhichKeyGroup", { fg = c.tertiary })
hi("WhichKeyDesc", { fg = c.foreground })
hi("WhichKeySeparator", { fg = c.outline })
hi("WhichKeyNormal", { bg = c.surface_low })
hi("TroubleText", { fg = c.foreground })
hi("TroubleNormal", { fg = c.foreground, bg = c.background })
hi("NoiceCmdlineIcon", { fg = c.primary })
hi("NoiceCmdlinePopupBorder", { fg = c.primary })
hi("MasonHeader", { fg = c.on_primary, bg = c.primary, bold = true })
hi("MasonHighlight", { fg = c.primary })
hi("MasonHighlightBlock", { fg = c.on_primary, bg = c.primary })
hi("TodoFgTODO", { fg = c.primary, bold = true })
hi("TodoFgWARN", { fg = warning, bold = true })
hi("TodoFgFIX", { fg = c.error, bold = true })
hi("SnacksPickerBorder", { fg = c.outline, bg = c.surface_low })
hi("SnacksPickerTitle", { fg = c.primary, bg = c.surface_low, bold = true })
hi("SnacksPickerMatch", { fg = c.primary, bold = true })
hi("SnacksDashboardHeader", { fg = c.primary, bold = true })
hi("SnacksDashboardIcon", { fg = c.tertiary })
hi("SnacksDashboardKey", { fg = c.secondary })
hi("SnacksDashboardDesc", { fg = c.foreground })
hi("SnacksIndent", { fg = c.outline_variant })
hi("SnacksIndentScope", { fg = c.primary })

local icon_colors = {
  MiniIconsAzure = c.primary,
  MiniIconsBlue = c.base0d,
  MiniIconsCyan = c.base0c,
  MiniIconsGreen = c.base0b,
  MiniIconsGrey = c.outline,
  MiniIconsOrange = c.base09,
  MiniIconsPurple = c.base0e,
  MiniIconsRed = c.base08,
  MiniIconsYellow = c.base0a,
}
for group, color in pairs(icon_colors) do
  hi(group, { fg = color })
end

-- Terminal ANSI colors follow the generated Base16 palette.
local terminal = {
  c.base00,
  c.base08,
  c.base0b,
  c.base0a,
  c.base0d,
  c.base0e,
  c.base0c,
  c.base05,
  c.base03,
  c.base08,
  c.base0b,
  c.base0a,
  c.base0d,
  c.base0e,
  c.base0c,
  c.base07,
}
local ansi = { "Black", "Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White" }
for index, color in ipairs(terminal) do
  local name = (index > 8 and "Bright" or "") .. ansi[(index - 1) % 8 + 1]
  vim.g["terminal_color_" .. (index - 1)] = ui["terminal.ansi" .. name] or color
end
