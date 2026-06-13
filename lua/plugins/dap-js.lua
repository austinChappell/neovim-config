return {
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      local adapter_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug-adapter"

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = adapter_path,
          args = { "${port}" },
        },
      }

      dap.configurations.typescript = {
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to API (port 9229)",
          port = 9229,
          cwd = "${workspaceFolder}",
          resolveSourceMapLocations = {
            "${workspaceFolder}/**",
            "!**/node_modules/**",
          },
          sourceMaps = true,
          skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
      }
      dap.configurations.javascript = dap.configurations.typescript

      vim.fn.sign_define("DapStopped", {
        text = "→",
        texthl = "DiagnosticWarn",
        linehl = "DiffAdd",
        numhl = "DiagnosticWarn",
      })

      -- Tab completion in the REPL using DAP completions request
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dap-repl",
        callback = function()
          vim.keymap.set("i", "<Tab>", function()
            require("dap.repl").omnifunc(1, "")
            return "<C-x><C-o>"
          end, { buffer = true, expr = true })
        end,
      })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      -- Auto-open/close UI with debug sessions
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
