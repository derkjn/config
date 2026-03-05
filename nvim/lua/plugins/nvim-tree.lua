return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
      { "<leader>o", "<cmd>NvimTreeFindFile<cr>", desc = "Find file in tree" },
    },
    config = function()
      require("nvim-web-devicons").setup()
      require("nvim-tree").setup({
        view = { width = 35 },
        renderer = {
          group_empty = true,
          icons = {
            show = {
              git = true,
              folder = true,
              file = true,
              folder_arrow = true,
            },
            glyphs = {
              folder = { arrow_closed = "▶", arrow_open = "▼" },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "═",
                renamed = "≫",
                untracked = "?",
                deleted = "✖",
                ignored = "◌",
              },
            },
          },
        },
        filters = { dotfiles = false, custom = { "^.git$" } },
        git = { enable = true, ignore = false },
        actions = { open_file = { quit_on_open = false } },
      })
    end,
  },
}
