--- lua/plugins/dap.lua — debugpy DAP 调试器配置（项目 2）
---
--- 这个文件配置 Python 调试器 debugpy。
--- debugpy 是 Python 官方的调试适配器，支持：
---   - 普通 Python 文件调试
---   - FastAPI/Flask/Django 应用调试
---   - 远程调试
---   - 运行中的进程附加（attach）
---
--- ⚠️ 铁律：
---   - nvim-dap 用 keys 懒加载（调试时才用）
---   - debugpy 需要单独安装（pip install debugpy 或 Mason）
---   - dap-ui 作为 nvim-dap 的 dependency 自动加载
---   - 所有快捷键必须带 desc
---
--- 文件返回 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- nvim-dap + nvim-dap-python — Python 调试器
  -- ========================================================================
  -- nvim-dap 是 DAP 协议客户端（第 16 章）
  -- nvim-dap-python 是 Python 调试适配器（封装 debugpy）
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- nvim-dap-python：Python 调试适配器
      {
        "mfussenegger/nvim-dap-python",
        config = function()
          local ok, dap_python = pcall(require, "dap-python")
          if ok then
            -- 使用系统 python 或虚拟环境中的 python
            -- debugpy 会自动使用当前虚拟环境
            dap_python.setup("python")
          end
        end,
      },
    },

    -- DAP 快捷键（keys 懒加载触发器）
    keys = {
      -- 调试当前 Python 文件
      {
        "<leader>dP",
        function()
          local ok, dap_python = pcall(require, "dap-python")
          if ok then
            dap_python.debug_selection()
          end
        end,
        desc = "DAP: 调试选中的 Python 代码",
      },

      -- 调试 Python 测试方法
      {
        "<leader>dt",
        function()
          local ok, dap_python = pcall(require, "dap-python")
          if ok then
            dap_python.test_method()
          end
        end,
        desc = "DAP: 调试当前测试方法",
      },

      -- 调试 Python 测试类
      {
        "<leader>dT",
        function()
          local ok, dap_python = pcall(require, "dap-python")
          if ok then
            dap_python.test_class()
          end
        end,
        desc = "DAP: 调试当前测试类",
      },
    },
  },

  -- ========================================================================
  -- nvim-dap — FastAPI/Flask 调试配置
  -- ========================================================================
  -- 用 config 函数注册自定义的调试启动配置
  -- 这些配置会出现在调试启动菜单中
  {
    "mfussenegger/nvim-dap",
    config = function()
      local ok, dap = pcall(require, "dap")
      if not ok then
        return
      end

      -- 获取 nvim-dap-python 注册的 Python 配置
      local python_configs = dap.configurations.python or {}

      -- 追加 FastAPI 调试配置
      table.insert(python_configs, {
        type = "python",
        request = "launch",
        name = "Launch FastAPI",
        module = "uvicorn",
        args = {
          "main:app",     -- FastAPI 应用入口
          "--reload",     -- 热重载
          "--port", "8000",
        },
        console = "integratedTerminal",
        cwd = "${workspaceFolder}",
      })

      -- 追加 Flask 调试配置
      table.insert(python_configs, {
        type = "python",
        request = "launch",
        name = "Launch Flask",
        module = "flask",
        env = {
          FLASK_APP = "app.py",
          FLASK_ENV = "development",
          FLASK_DEBUG = "1",
        },
        args = {
          "run",
          "--debugger",
          "--port", "5000",
        },
        console = "integratedTerminal",
        cwd = "${workspaceFolder}",
      })

      -- 追加 Django 调试配置
      table.insert(python_configs, {
        type = "python",
        request = "launch",
        name = "Launch Django",
        program = "${workspaceFolder}/manage.py",
        args = {
          "runserver",
          "--noreload",
        },
        console = "integratedTerminal",
        cwd = "${workspaceFolder}",
      })

      -- 更新配置
      dap.configurations.python = python_configs
    end,
  },
}
