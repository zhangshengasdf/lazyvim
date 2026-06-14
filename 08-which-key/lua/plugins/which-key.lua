--- lua/plugins/which-key.lua — which-key.nvim 插件 spec（第08章）
---
--- 这个文件演示 which-key.nvim 的 lazy.nvim spec 格式。
--- 它返回一个 spec table，可以直接被 lazy.nvim 加载。
--- 即使没有 lazy.nvim，luafile 也能正常解析（返回一个被丢弃的 table）。
---
--- which-key.nvim 的作用：
---   - 按下前缀键（如 <Space>）后弹出快捷键提示菜单
---   - 自动拾取所有带 desc 的 vim.keymap.set 注册的快捷键
---   - 支持自定义分组标签（group）
---
--- ⚠️ LazyVim 已内置 which-key，你通常不需要自己写这个 spec。
---    这个文件是教学用——展示如何用 opts = function extend which-key 配置。

return {
  {
    "folke/which-key.nvim",
    -- LazyVim 用 event 懒加载 which-key（Neovim 启动后加载）
    -- 这样 which-key 能拾取所有启动时注册的快捷键
    event = "VeryLazy",

    -- opts_extend 告诉 lazy.nvim：opts.spec 字段用列表追加（extend），不是覆盖
    -- 这样你的自定义 spec 会追加到 LazyVim 默认的 spec 后面
    opts_extend = { "spec" },

    -- opts 传给 require("which-key").setup(opts)
    opts = {
      -- preset 选择预设窗口样式："classic"（默认）、"modern"、"helix"
      -- LazyVim 用 "helix"——紧凑布局，圆角边框，左对齐标题
      preset = "helix",

      -- 延迟弹出时间（毫秒）
      delay = 300,

      -- 键位提示图标
      icons = {
        breadcrumb = "»",   -- 子菜单路径分隔符
        separator = "→",    -- 按键和描述之间的分隔符
        group = "+",        -- 分组图标前缀
      },

      -- spec 字段：分组标签和额外映射（和 wk.add() 等价）
      -- 放在 opts.spec 里，lazy.nvim 会自动合并到 setup() 的参数中
      spec = {
        { "<leader>f", group = "查找" },
        { "<leader>s", group = "搜索" },
        { "<leader>b", group = "buffer" },
        { "<leader>g", group = "git" },
        { "<leader>c", group = "代码" },
        { "<leader>x", group = "扩展" },
        { "<leader>u", group = "UI" },
      },

      -- 触发 which-key 的键
      triggers = {
        { "<auto>", mode = "nixsotc" },
      },
    },

    -- keys 字段：注册 which-key 自身的快捷键（懒加载触发）
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer 快捷键（which-key）",
      },
    },
  },
}
