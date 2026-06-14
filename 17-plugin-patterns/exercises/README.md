# 第17章 练习 — 插件配置模式

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看 `reference/`。

---

## 练习 1：找出错误配置

**题目**：以下配置有错误，找出问题并改正：

```lua
-- 配置 A
{
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = { "python", "rust", "go" },
  },
}

-- 配置 B
{
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    opts.defaults = { layout_strategy = "vertical" }
    return opts
  end,
}

-- 配置 C
{
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = { "stylua", "shellcheck" },
  },
}
```

**问题**：
1. 配置 A 有什么问题？会导致什么后果？
2. 配置 B 有什么问题？（提示：return 和 table 覆盖）
3. 配置 C 和配置 A 是同一类问题吗？为什么？

**参考答案**：见 [`reference/exercise-01.md`](./reference/exercise-01.md)

---

## 练习 2：写出正确的 extend 配置

**题目**：把练习 1 中的三个错误配置改正为正确的 extend 版本。

要求：
1. 保留 LazyVim 的默认值
2. 追加你需要的值
3. 用正确的 extend 函数

**参考答案**：见 [`reference/exercise-02.md`](./reference/exercise-02.md)

---

## 练习 3：禁用与替换快捷键

**题目**：你需要做以下快捷键操作，写出完整的 spec：

1. 禁用 LazyVim 默认的 `<leader>ff`（Telescope find_files）
2. 把 `<leader>ff` 重新绑定为 `Telescope oldfiles`（最近文件）
3. 禁用 `<leader>fb`（Telescope buffers）
4. 新增 `<leader>fg` 为 `Telescope live_grep`（如果 LazyVim 已有，写 desc 说明）

写出完整的 `return { ... }` 格式，注意 `keys` 字段的写法。

**参考答案**：见 [`reference/exercise-03.md`](./reference/exercise-03.md)

---

## 练习 4：决策练习——覆盖还是 extend？

**题目**：对以下每个场景，判断应该用"table 直传"、"function extend"还是"config 完全覆盖"：

| 场景 | 推荐方式 | 理由 |
|------|----------|------|
| 给 tokyonight 换个 style | ? | ? |
| 给 treesitter 追加 3 个语言 | ? | ? |
| 给 telescope 的 defaults 追加 file_ignore_patterns | ? | ? |
| 给 lualine 完全重写 section_c | ? | ? |
| 禁用 mini.animate | ? | ? |
| 给 mason 追加工具 | ? | ? |

**参考答案**：见 [`reference/exercise-04.md`](./reference/exercise-04.md)

---

## 练习 5（进阶）：综合配置

**题目**：写一个完整的 `lua/plugins/custom.lua`，实现以下需求：

1. 给 treesitter 追加 `lua`、`vim`、`vimdoc` 语言
2. 给 mason 追加 `stylua`、`luacheck` 工具
3. 禁用 `indent-blankline.nvim`（缩进线插件）
4. 禁用 telescope 的 `<leader><leader>` 绑定（buffer 切换）
5. 给 telescope 追加 `layout_strategy = "vertical"` 配置

要求：
- 用 extend 模式（不要覆盖默认值）
- 每个插件一个 spec（不要合并到一起）
- 返回格式：`return { ... }`

**参考答案**：见 [`reference/exercise-05.md`](./reference/exercise-05.md)

---

## 如何使用本章代码

```bash
cd lazyvim/17-plugin-patterns

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/patterns.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/plugins/patterns.lua ~/.config/nvim/lua/plugins/17-demo.lua
# nvim  → :Lazy sync → 观察 spec 是否被正确识别
```

做完所有练习后，进入 [第18章 自定义快捷键与自动命令](../18-custom-keymaps/)。
