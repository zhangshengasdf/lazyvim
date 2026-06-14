# 第05章 练习 — 配置目录架构

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看 `reference/`。

---

## 练习 1：判断配置该放哪个文件（理解目录）

**题目**：以下每条配置，应该放在 `lua/config/` 的哪个文件里？（options.lua / keymaps.lua / autocmds.lua / 都不放，该放 lua/plugins/）

| 配置内容 | 放哪个文件？ |
|----------|--------------|
| (a) `vim.opt.number = true` | ? |
| (b) `vim.keymap.set("n", "<leader>w", ":w<CR>")` | ? |
| (c) 打开 `.md` 文件时自动设 `wrap` | ? |
| (d) 给 Telescope 插件追加一个布局选项 | ? |
| (e) `vim.g.mapleader = " "` | ? |
| (f) 把 `<C-h>` 映射为"跳到左窗口" | ? |
| (g) 给 nvim-treesitter 追加 `ensure_installed` 里的语言 | ? |

**参考答案**：见 [`reference/exercise-01.md`](./reference/exercise-01.md)

---

## 练习 2：识别合并语义（extend vs 覆盖）

**题目**：以下每个 spec，判断是 extend（正确）还是覆盖（错误）：

```lua
-- (a)
return {
  { "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "lua" } },
  },
}

-- (b)
return {
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "lua" })
    end,
  },
}

-- (c)
return {
  { "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        layout_strategy = "horizontal",
      })
    end,
  },
}

-- (d)
return {
  { "nvim-telescope/telescope.nvim",
    opts = { defaults = { layout_strategy = "horizontal" } },
  },
}
```

对每个 spec 回答：
1. 是 extend 还是覆盖？
2. 如果是覆盖，会丢失什么默认配置？

**参考答案**：见 [`reference/exercise-02.md`](./reference/exercise-02.md)

---

## 练习 3：动手创建 config 文件

**题目**：按照本章的结构，在 `lua/config/` 目录下创建以下文件（用真实 LazyVim 环境或模拟环境）：

1. 创建 `lua/config/options.lua`，设置以下选项：
   - `vim.opt.number = true`
   - `vim.opt.tabstop = 4`
   - `vim.opt.shiftwidth = 4`
   - `vim.g.mapleader = " "`

2. 创建 `lua/config/keymaps.lua`，设置：
   - `<leader>w` → 保存文件（带 desc）
   - `<C-h>` → 跳到左窗口（带 desc）

3. 用 `shared/verify.lua` 验证：

```bash
cd lazyvim/05-config-architecture
nvim --headless -u NONE \
  -c "luafile lua/config/options.lua" \
  -c "luafile lua/config/keymaps.lua" \
  -c "lua verify = dofile('../shared/verify.lua')" \
  -c "lua verify.run({
        {fn = verify.check_opt, args = {'number', true}},
        {fn = verify.check_opt, args = {'tabstop', 4}},
        {fn = verify.check_keymap, args = {'n', '<leader>w'}},
      })" \
  -c 'qa!'
```

**预期结果**：所有检查都 `OK`。

**参考答案**：见 [`reference/exercise-03.md`](./reference/exercise-03.md)

---

## 练习 4：理解加载顺序

**题目**：回答以下问题：

1. LazyVim source `lua/config/` 四个文件的顺序是什么？为什么是这个顺序？
2. `init.lua` 里的 `require("lazy").setup({...})` 和 `lua/config/lazy.lua` 是什么关系？
3. 你的 `lua/plugins/example.lua` 是在 `lua/config/options.lua` 之前还是之后被处理？

**参考答案**：见 [`reference/exercise-04.md`](./reference/exercise-04.md)

---

## 练习 5（进阶）：修复错误配置

**题目**：以下是某用户的 `lua/plugins/treesitter.lua`，它有**一个严重错误**。
找出错误并改正：

```lua
-- 某用户的配置（有错误！）
return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- 想增加 lua 和 rust 解析器
    opts = {
      ensure_installed = {
        "lua",
        "rust",
      },
    },
  },
}
```

**问题**：
1. 这个配置哪里错了？
2. 会造成什么后果？
3. 写出正确的版本。

**参考答案**：见 [`reference/exercise-05.md`](./reference/exercise-05.md)

---

## 如何使用本章代码

```bash
cd lazyvim/05-config-architecture

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/config/options.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/config/keymaps.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/example.lua" -c 'qa!'
# 预期：全部退出码 0
```

做完所有练习后，进入 [第06章 lazy.nvim 插件管理器](../06-lazy-nvim/)。
