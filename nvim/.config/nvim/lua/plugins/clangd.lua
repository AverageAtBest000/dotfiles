return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.clangd = opts.servers.clangd or {}
      local clangd = opts.servers.clangd
      clangd.cmd = clangd.cmd or { "clangd" }
      -- Read Pico and ESP-IDF cross-compiler targets and standard-library paths.
      table.insert(clangd.cmd, "--query-driver=/usr/bin/arm-none-eabi-gcc,/usr/bin/arm-none-eabi-g++," .. vim.fn.expand("~") .. "/.espressif/tools/xtensa-esp-elf/*/xtensa-esp-elf/bin/*")
    end,
  },
}
