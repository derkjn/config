return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
      "theHamsta/nvim-dap-virtual-text",
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<F5>", function() require("dap").continue() end, desc = "Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Step out" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<S-F9>", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = { "delve", "php" },
        handlers = {},
      })

      -- Go debugging (via nvim-dap-go / delve)
      require("dap-go").setup()

      -- PHP debugging (Xdebug)
      dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" },
      }
      dap.configurations.php = {
        {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug",
          port = 9003,
          pathMappings = {
            ["/var/www/html"] = "${workspaceFolder}",
          },
        },
      }

      local dap_vscode = require("dap.ext.vscode")

      local function strip_jsonc(input)
        local output = {}
        local i = 1
        local in_string = false
        local escaped = false

        while i <= #input do
          local ch = input:sub(i, i)
          local next_ch = input:sub(i + 1, i + 1)

          if in_string then
            output[#output + 1] = ch
            if escaped then
              escaped = false
            elseif ch == "\\" then
              escaped = true
            elseif ch == '"' then
              in_string = false
            end
            i = i + 1
          else
            if ch == '"' then
              in_string = true
              output[#output + 1] = ch
              i = i + 1
            elseif ch == "/" and next_ch == "/" then
              i = i + 2
              while i <= #input do
                local c = input:sub(i, i)
                if c == "\n" or c == "\r" then
                  break
                end
                i = i + 1
              end
            elseif ch == "/" and next_ch == "*" then
              i = i + 2
              while i <= (#input - 1) do
                if input:sub(i, i) == "*" and input:sub(i + 1, i + 1) == "/" then
                  i = i + 2
                  break
                end
                i = i + 1
              end
            else
              output[#output + 1] = ch
              i = i + 1
            end
          end
        end

        local cleaned = table.concat(output):gsub(",%s*([}%]])", "%1")
        return cleaned
      end

      dap_vscode.json_decode = function(json_string, opts)
        local cleaned = strip_jsonc(json_string)
        return vim.json.decode(cleaned, opts)
      end

      local ok_launch, launch_err = pcall(dap_vscode.load_launchjs, nil, {
        cppdbg = { "c", "cpp", "rust" },
        go = { "go" },
        php = { "php" },
        node = { "javascript", "typescript" },
        ["pwa-node"] = { "javascript", "typescript" },
      })

      if not ok_launch then
        vim.notify("DAP launch.json parse failed: " .. tostring(launch_err), vim.log.levels.WARN)
      end

      -- DAP UI
      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Breakpoint signs
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◐", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })
    end,
  },
}
