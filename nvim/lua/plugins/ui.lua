return {
  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "everforest",
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = {
          {
            function()
              return vim.lsp.status()
            end,
            cond = function()
              return vim.lsp.status() ~= ""
            end,
            color = { fg = "#83c092" },
          },
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },
  -- Buffer tabs
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "NvimTree", text = "File Explorer", highlight = "Directory", separator = true },
        },
      },
    },
  },
  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
    },
  },
  -- Keybinding help
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>d", group = "Debug" },
        { "<leader>c", group = "Code" },
        { "<leader>b", group = "Buffer" },
        { "<leader>x", group = "Diagnostics" },
      },
    },
  },
  -- LSP progress indicator
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      progress = {
        display = {
          done_ttl = 3,
          done_icon = "✓",
          progress_icon = { pattern = "dots", period = 1 },
        },
      },
      notification = {
        window = {
          winblend = 0,
          border = "none",
          align = "bottom",
        },
      },
    },
  },
}
