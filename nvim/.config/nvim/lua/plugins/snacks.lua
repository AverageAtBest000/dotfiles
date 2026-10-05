return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = {
            hidden = true,
          },
          explorer = {
            hidden = true,
            ignored = true,
            win = {
              list = {
                keys = {
                  ["j"] = "list_up",
                  ["k"] = "list_down",
                },
              },
              input = {
                keys = {
                  ["j"] = { "list_up", mode = "n" },
                  ["k"] = { "list_down", mode = "n" },
                },
              },
            },
          },
        },
      },
    },
  },
}
