return {
  -- UI debugging
  {
    "rcarriga/nvim-dap-ui",
    cmd = "DapOpen",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()
      local dap, dapui = require("dap"), require("dapui")
      --
      -- -- DAP UI setup
      dapui.setup()
      --
      vim.fn.sign_define("DapBreakpoint", { text = "📍", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define('DapLogPoint', { text = '✏️', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '👉🏾', texthl = '', linehl = 'debugPC', numhl = '' })

      -- Auto-open/close dapui
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

      -- Keymaps
      local map = function(mode, lhs, rhs, opts)
        vim.keymap.set(mode, lhs, rhs, opts or {})
      end
      --               
      map("n", "<Leader>di", function() dap.step_into() end, { desc = "  Step into" })
      map("n", "<Leader>dn", function() dap.step_over() end, { desc = "  Step over" })
      map("n", "<Leader>do", function() dap.step_out() end, { desc = "  Step out" })
      map("n", "<Leader>ds", function() dap.continue() end, { desc = "  Start" })
      map("n", "<Leader>dc", function() dap.continue() end, { desc = "⏯️ Continue" })
      map("n", "<Leader>db", function() dap.toggle_breakpoint() end, { desc = "📍 toggle breakpoint" })
      map("n", "<Leader>dd", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "set conditional breakpoint" })
      map("n", "<Leader>dt", function() dap.terminate() end, { desc = "  terminate" })
      map("n", "<Leader>dl", function() dap.run_last() end, { desc = "  run last" })

      map("n", "<Leader>dx", "<cmd>RustLsp testables<CR>", { desc = "testables" })
    end,
  },
  -- Debugging
  {
    "mfussenegger/nvim-dap",
    config = function()
      -- local dap, dapui = require("dap"), require("dapui")
      -- dap.listeners.before.attach.dapui_config = function()
      --   dapui.open()
      -- end
      -- dap.listeners.before.launch.dapui_config = function()
      --   dapui.open()
      -- end
      -- dap.listeners.before.event_terminated.dapui_config = function()
      --   dapui.close()
      -- end
      -- dap.listeners.before.event_exited.dapui_config = function()
      --   dapui.close()
      -- end
    end,
  },
}
