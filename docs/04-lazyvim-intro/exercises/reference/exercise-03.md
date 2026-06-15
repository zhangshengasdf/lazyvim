# 练习 3 参考答案 — 识别反模式

| 操作 | 对/错 | 理由 |
|------|-------|------|
| (a) 不备份旧配置，直接 `git clone starter ~/.config/nvim` | ❌ **错** | 旧配置会被覆盖或共存导致冲突。正确做法：先 `mv ~/.config/nvim{,.bak}`。 |
| (b) 在 `lua/plugins/options.lua` 里写 `vim.opt.number = true` | ❌ **错** | `lua/plugins/` 的文件必须 `return { ... }`（spec table），写裸语句会报错。`vim.opt` 应放 `lua/config/options.lua`。 |
| (c) 装完运行 `:LazyHealth` 检查是否有警告 | ✅ **对** | 健康检查能发现缺少外部工具（ripgrep、fd）、Nerd Font 没装等问题，第一时间修。 |
| (d) 把 lazy.nvim 手动 clone 到 `~/.local/share/nvim/lazy/lazy.nvim` | ❌ **错** | 应该让 `init.lua` 的 bootstrap 逻辑自动管理。手动 clone 会绕过版本检查，升级时出问题。 |
| (e) 在 `lua/config/keymaps.lua` 里用 `vim.keymap.set` 设置快捷键 | ✅ **对** | 这是 `lua/config/keymaps.lua` 的正确用法。注意用 `vim.keymap.set`，不要用已弃用的 `vim.api.nvim_set_keymap`，更不要用不存在的 `LazyVim.safe_keymap_set`（那是内部 API）。 |

**总结**：新手最容易踩的三个坑是 (a)(b)(d)。记住口诀：
- **改 Neovim 设置 → `lua/config/`**
- **装/改插件 → `lua/plugins/`**
- **备份再装，不要手抖**

**回到 [练习题](../README.md)**
