--- lua/plugins/neo-tree.lua — Neo-tree spec 示例（第10章）
---
--- 这个文件演示 Neo-tree 的 lazy.nvim spec 写法：
---   1. cmd 懒加载（:Neotree 命令触发加载）
---   2. keys 懒加载（<leader>e 按键触发加载）
---   3. opts = function + vim.tbl_deep_extend 扩展配置
---   4. dependencies 声明（plenary、nui、icons）
---
--- ⚠️ 铁律：
---   - Neo-tree 的 filesystem 配置用 vim.tbl_deep_extend 扩展（不是覆盖）
---   - window.mappings 也要 extend（不要覆盖 LazyVim 默认的快捷键）
---   - cmd 和 keys 同时使用，满足任一即加载
---
--- 文件返回一个 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- Neo-tree 主 spec
  -- ========================================================================
  {
    "nvim-neo-tree/neo-tree.nvim",

    -- 依赖：Neo-tree 需要这些插件才能工作
    dependencies = {
      "nvim-lua/plenary.nvim",          -- 工具库
      "nvim-neo-tree/nui.nvim",         -- UI 组件库（浮窗、布局）
      "nvim-tree/nvim-web-devicons",    -- 文件图标（Nerd Font）
    },

    -- ======================================================================
    -- cmd 懒加载：运行 :Neotree 命令时加载
    -- ======================================================================
    -- LazyVim 默认的 cmd 列表，覆盖了所有 :Neotree 子命令
    cmd = { "Neotree" },

    -- ======================================================================
    -- keys 懒加载：按这些键时加载
    -- ======================================================================
    -- <leader>e 是 LazyVim 默认的 Neo-tree 切换键
    -- 按一次打开，再按一次关闭（toggle 行为）
    keys = {
      {
        "<leader>e",
        "<cmd>Neotree toggle<CR>",
        desc = "文件管理器",
      },
      {
        "<leader>E",
        "<cmd>Neotree toggle reveal<CR>",
        desc = "文件管理器（定位当前文件）",
      },
    },

    -- ======================================================================
    -- deactivate：退出 Neo-tree 的函数
    -- ======================================================================
    -- 当 Neo-tree 是唯一窗口时，关闭它而不是退出 Neovim
    deactivate = function()
      vim.cmd("Neotree close")
    end,

    -- ======================================================================
    -- init：在插件加载前执行
    -- ======================================================================
    -- 设置一个标记，让 LazyVim 知道我们用了 Neo-tree 作为文件浏览器
    -- 这样 LazyVim 不会同时启用 snacks.explorer
    init = function()
      -- 如果设置了 vim.g.lazyvim_picker 为 "snacks"，则不使用 Neo-tree
      -- 这是 LazyVim 的 picker 选择机制（Telescope vs snacks.picker）
      if vim.fn.argc(-1) == 1 then
        local stat = vim.uv.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          -- 如果启动时传入的是目录，自动打开 Neo-tree
          require("neo-tree")
        end
      end
    end,

    -- ======================================================================
    -- opts = function 扩展默认配置
    -- ======================================================================
    -- LazyVim 已为 Neo-tree 定义了默认 opts。
    -- 我们用 opts = function 拿到默认 opts 的引用，再用 tbl_deep_extend 追加。
    opts = function(_, opts)
      -- 扩展 filesystem 配置
      opts.filesystem = vim.tbl_deep_extend("force", opts.filesystem or {}, {
        -- 跟随当前文件
        follow_current_file = {
          enabled = true,
        },
        -- 过滤器
        filtered_items = {
          visible = false,
          hide_dotfiles = true,
          hide_gitignored = true,
          hide_by_name = {
            "node_modules",
            ".git",
            "__pycache__",
            ".DS_Store",
          },
        },
        -- 使用 libuv 文件监视器
        use_libuv_file_watcher = true,
      })

      -- 扩展 window 配置
      opts.window = vim.tbl_deep_extend("force", opts.window or {}, {
        position = "left",
        width = 35,
        mappings = {
          -- 禁用空格键的默认行为（避免和 Leader 键冲突）
          ["<space>"] = "none",
        },
      })

      -- 扩展 Git 状态符号
      if opts.default_component_configs then
        opts.default_component_configs.indent = vim.tbl_deep_extend(
          "force",
          opts.default_component_configs.indent or {},
          {
            with_expanders = true,
            expander_collapsed = "",
            expander_expanded = "",
          }
        )
      end
    end,

    -- ======================================================================
    -- config：setup 后的额外配置
    -- ======================================================================
    -- 如果需要在 setup 后做额外事情（比如注册自定义命令），用 config
    -- 这里留空，因为 opts 已经处理了所有配置
    config = function(_, opts)
      -- LazyVim 的 Neo-tree config 已经处理了 setup
      -- 如果你有额外需求，可以在这里添加
      -- 例如：注册自定义命令
      -- vim.api.nvim_create_user_command("NeotreeCwd", function()
      --   require("neo-tree.command").execute({ action = "show", dir = vim.uv.cwd() })
      -- end, { desc = "Neo-tree: 打开当前工作目录" })
    end,
  },
}
