# 第12章 练习 — LSP 语言服务与 Mason

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看参考。

---

## 练习 1：LSP 快捷键记忆

**题目**：不看文档，写出以下操作对应的 LazyVim 默认快捷键：

| 操作 | 快捷键 |
|------|--------|
| 跳转到符号定义 | ? |
| 查看符号的所有引用 | ? |
| 悬停显示文档 | ? |
| 代码操作（快速修复） | ? |
| 重命名符号 | ? |
| 查看当前行诊断详情 | ? |
| 跳转到下一个诊断 | ? |
| 跳转到上一个诊断 | ? |

---

## 练习 2：配置语言服务器

**题目**：你是一个前端开发者，主要使用 TypeScript/React 和 CSS。
写出完整的 `lua/plugins/lsp.lua`，配置以下服务器：

1. **ts_ls**：启用 inlay hints（参数名和类型提示）
2. **cssls**：用默认配置
3. **html**：用默认配置
4. **eslint**：用默认配置（代码规范检查）

要求：
- 用 `opts = { servers = { ... } }` 结构
- 只配置需要自定义设置的服务器，其他用空 table

**参考答案**：

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = {
          -- 你的答案
        },
        cssls = {},
        html = {},
        eslint = {},
      },
    },
  },
}
```

---

## 练习 3：诊断级别判断

**题目**：以下诊断信息分别属于哪个级别（Error/Warning/Info/Hint）？

| 诊断信息 | 级别 |
|----------|------|
| `undefined variable 'foo'` | ? |
| `unused variable 'x'` | ? |
| `consider using f-string instead of .format()` | ? |
| `missing return type annotation` | ? |
| `cannot assign to final variable` | ? |
| `line too long (120 > 88 characters)` | ? |
| `import 'os' is unused` | ? |

---

## 练习 4：Mason 故障排查

**题目**：以下场景，你会用什么命令排查问题？

1. 你打开了一个 Python 文件，但 `gd` 没有反应。怎么确认 pyright 是否在运行？
2. Mason 安装了一个语言服务器，但 LspInfo 显示没有连接。怎么查看安装日志？
3. 你想确认所有配置的语言服务器都已正确安装。用什么命令做健康检查？
4. LSP 的行为异常（比如补全建议错误），怎么查看 LSP 的通信日志？
5. 你想更新所有已安装的语言服务器到最新版本。用什么命令？

**参考答案**：

1. 运行 `:LspInfo` 查看是否有 pyright 客户端连接到当前 buffer
2. 运行 `:MasonLog` 查看安装过程的详细日志
3. 运行 `:checkhealth lspconfig` 检查所有配置的服务器状态
4. 运行 `:LspLog` 打开 LSP 日志文件，查看 JSON-RPC 消息
5. 运行 `:MasonUpdate` 更新所有 Mason 管理的工具

---

## 如何使用本章代码

```bash
cd lazyvim/12-lsp-mason

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/lsp.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/plugins/lsp.lua ~/.config/nvim/lua/plugins/12-demo.lua
# nvim  → :Lazy sync → 打开 .lua 文件 → :LspInfo 确认 lua_ls 已连接
```

做完所有练习后，进入 [第13章 自动补全](../13-completion/)。
