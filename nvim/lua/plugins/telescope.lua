return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fw", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
    },
    config = function()
      -- Defer setup to ensure treesitter is ready
      local function setup_telescope()
        local telescope = require("telescope")
        
        -- Override treesitter highlighter to handle missing ft_to_lang gracefully
        local ok, previewers = pcall(require, "telescope.previewers.utils")
        if ok then
          local original_ts_highlighter = previewers.ts_highlighter
          previewers.ts_highlighter = function(filepath, bufnr, opts)
            -- Check if treesitter's ft_to_lang exists
            local ok_ts, ts_query = pcall(require, "vim.treesitter.query")
            if not ok_ts then
              return nil
            end
            
            -- Try to use original if available, otherwise fall back to vim syntax
            if original_ts_highlighter then
              local ok_highlight, result = pcall(original_ts_highlighter, filepath, bufnr, opts)
              if ok_highlight then
                return result
              end
            end
            return nil
          end
        end
        
        telescope.setup({
          defaults = {
            file_ignore_patterns = { "node_modules", "vendor", ".git/" },
            layout_strategy = "horizontal",
            layout_config = { prompt_position = "top" },
            sorting_strategy = "ascending",
            preview = {
              check_mime_type = false,
              treesitter = false,
            },
          },
          pickers = {
            find_files = { hidden = true },
          },
        })
        telescope.load_extension("fzf")
      end
      
      vim.schedule(setup_telescope)
    end,
  },
}
