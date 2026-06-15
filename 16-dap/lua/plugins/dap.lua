--- lua/plugins/dap.lua — DAP 调试器 spec（第16章）
---
--- 这个文件演示 nvim-dap + nvim-dap-ui 的 spec 格式。
--- 包含 Python (debugpy) 和 TypeScript (js-debug) 的配置示例。
---
--- ⚠️ 铁律：
---   - nvim-dap 用 keys 懒加载（调试时才用，不要用 event = "BufReadPost"）
---   - dap-ui 作为 nvim-dap 的 dependency 自动加载
---   - 调试适配器（debugpy/js-debug）需要单独安装
---   - 所有快捷键必须带 desc
---
--- 文件返回 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- nvim-dap — DAP 协议客户端
  -- ========================================================================
  -- 用 keys 懒加载：只有按调试快捷键时才加载。
  -- 依赖 nvim-dap-ui（自动打开调试面板）和 nvim-nio（异步 IO）。
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- dap-ui：可视化调试面板
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        keys = {
          { "<leader>du", function() require("dapui").toggle() end, desc = "DAP: 切换 UI" },
        },
        opts = {},
        config = function(_, opts)
          local dapui = require("dapui")
          dapui.setup(opts)

          -- 自动打开/关闭 UI：调试开始时打开，结束时关闭
          local dap = require("dap")
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

      -- Python 调试适配器（可选：需要 pip install debugpy）
      {
        "mfussenegger/nvim-dap-python",
        config = function()
          -- 使用系统 python 或指定 debugpy 路径
          local ok, dap_python = pcall(require, "dap-python")
          if ok then
            dap_python.setup("python")
          end
        end,
      },
    },

    -- DAP 快捷键（keys 懒加载触发器）
    keys = {
      {
        "<leader>db",
        function() require("dap").toggle_breakpoint() end,
        desc = "DAP: 切换断点",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("条件断点: "))
        end,
        desc = "DAP: 条件断点",
      },
      {
        "<leader>dc",
        function() require("dap").continue() end,
        desc = "DAP: 继续",
      },
      {
        "<leader>dn",
        function() require("dap").step_over() end,
        desc = "DAP: 步过",
      },
      {
        "<leader>di",
        function() require("dap").step_into() end,
        desc = "DAP: 步入",
      },
      {
        "<leader>do",
        function() require("dap").step_out() end,
        desc = "DAP: 步出",
      },
      {
        "<leader>dt",
        function() require("dap").terminate() end,
        desc = "DAP: 终止",
      },
      {
        "<leader>dr",
        function() require("dap").repl.toggle() end,
        desc = "DAP: REPL",
      },
      {
        "<leader>dl",
        function() require("dap").run_to_cursor() end,
        desc = "DAP: 运行到光标",
      },
    },
  },
}
