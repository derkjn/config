return {
  {
    "VidocqH/lsp-lens.nvim",
    event = "LspAttach",
    opts = {
      enable = true,
      include_declaration = false,
      sections = {
        definition = false,
        references = true,
        implements = false,
      },
      ignore_filetype = {
        "prisma",
      },
    },
    config = function(_, opts)
      require("lsp-lens").setup(opts)
    end,
  },
}
