return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",
          "intelephense",
          "lua_ls",
        },
        automatic_installation = false,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- Enable virtual text for inline diagnostics
      vim.diagnostic.config({
        virtual_text = {
          prefix = "● ",
          format = function(diagnostic)
            return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code or "")
          end,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Capabilities with cmp support
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Keymaps on LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", vim.lsp.buf.references, "References")
          map("gi", vim.lsp.buf.implementation, "Go to implementation")
          map("gt", vim.lsp.buf.type_definition, "Type definition")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>sh", vim.lsp.buf.signature_help, "Signature help")
          map("<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, "Format")
        end,
      })

      -- Go configuration with vim.lsp.config
      vim.lsp.config("gopls", {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_markers = { "go.work", "go.mod", ".git" },
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
              nilness = true,
              unusedwrite = true,
              useany = true,
            },
            staticcheck = true,
            gofumpt = true,
            completeUnimported = true,
            usePlaceholders = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      -- PHP configuration with vim.lsp.config
      vim.lsp.config("intelephense", {
        cmd = { "intelephense", "--stdio" },
        filetypes = { "php" },
        root_markers = { "composer.json", ".git" },
        capabilities = capabilities,
        settings = {
          intelephense = {
            files = { maxSize = 5000000 },
            environment = { phpVersion = "8.2" },
            stubs = {
              "apache", "bcmath", "bz2", "calendar", "com_dotnet", "Core",
              "ctype", "curl", "date", "dba", "dom", "enchant", "exif",
              "FFI", "fileinfo", "filter", "fpm", "ftp", "gd", "gettext",
              "gmp", "hash", "iconv", "imap", "intl", "json", "ldap",
              "libxml", "mbstring", "meta", "mysqli", "oci8", "odbc",
              "openssl", "pcntl", "pcre", "PDO", "pdo_ibm", "pdo_mysql",
              "pdo_pgsql", "pdo_sqlite", "pgsql", "Phar", "posix",
              "pspell", "readline", "Reflection", "session", "shmop",
              "SimpleXML", "snmp", "soap", "sockets", "sodium", "SPL",
              "sqlite3", "standard", "superglobals", "sysvmsg", "sysvsem",
              "sysvshm", "tidy", "tokenizer", "xml", "xmlreader",
              "xmlrpc", "xmlwriter", "xsl", "Zend OPcache", "zip", "zlib",
              "redis", "memcached",
            },
          },
        },
      })

      -- Lua configuration with vim.lsp.config
      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", "luarc.json", "luarc.jsonc", ".git" },
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      -- JSON configuration with vim.lsp.config
      vim.lsp.config("jsonls", {
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json", "jsonc" },
        root_markers = { ".git" },
        capabilities = capabilities,
      })

      -- YAML configuration with vim.lsp.config
      vim.lsp.config("yamlls", {
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml", "yml" },
        root_markers = { ".git", ".yamllint" },
        capabilities = capabilities,
      })

      -- Enable all configured servers
      vim.lsp.enable({ "gopls", "intelephense", "lua_ls", "jsonls", "yamlls" })
    end,
  },
}
