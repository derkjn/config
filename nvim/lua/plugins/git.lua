return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Previous hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>gb", gs.blame_line, "Blame line")
        map("n", "<leader>gd", gs.diffthis, "Diff this")
      end,
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
      { "<leader>gV", "<cmd>DiffviewOpen HEAD~1..HEAD<cr>", desc = "Review latest commit" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
    },
    opts = {},
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gblame" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status (fugitive)" },
      { "<leader>gB", "<cmd>Gblame<cr>", desc = "Git blame (fugitive)" },
      { "<leader>gD", "<cmd>Gvdiffsplit<cr>", desc = "Vertical diff split" },
    },
  },
}
