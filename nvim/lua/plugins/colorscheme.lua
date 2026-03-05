return {
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_background = "hard" -- Darkest background
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 1
      vim.cmd.colorscheme("everforest")

      local delirium_dark_bg = "#282829"
      local apply_background = function()
        vim.api.nvim_set_hl(0, "Normal", { bg = delirium_dark_bg })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = delirium_dark_bg })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = delirium_dark_bg })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = delirium_dark_bg })
        vim.api.nvim_set_hl(0, "LineNr", { bg = delirium_dark_bg })
        vim.api.nvim_set_hl(0, "CursorLineNr", { bg = delirium_dark_bg })
      end

      apply_background()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = apply_background,
      })
    end,
  },
}
