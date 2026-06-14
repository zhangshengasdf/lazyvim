# 第04章 练习 — LazyVim 简介与安装

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看 `reference/`。

---

## 练习 1：对比 Neovim 配置方案（理解概念）

**题目**：阅读下表，判断每种需求应该选哪个方案（原生 Neovim / LazyVim / Kickstart.nvim）：

| 需求场景 | 你会选哪个？为什么？ |
|----------|----------------------|
| (a) 我想完全自己选插件、自己写每一行配置，不在乎从零开始 | ? |
| (b) 我刚从 VS Code 转过来，想要开箱即用、不想折腾配置 | ? |
| (c) 我想理解 Neovim 配置的每一行，但不想装太多插件 | ? |

**提示**：回顾 README 的「LazyVim vs 原生 Neovim vs 其他发行版」对比表格。

**参考答案**：见 [`reference/exercise-01.md`](./reference/exercise-01.md)

---

## 练习 2：理解目录结构（填空）

**题目**：根据 LazyVim starter 的目录结构，填写每个文件/目录的作用：

```
~/.config/nvim/
├── init.lua              → 作用：_______________
├── lua/
│   ├── config/
│   │   ├── options.lua   → 作用：_______________
│   │   ├── keymaps.lua   → 作用：_______________
│   │   ├── autocmds.lua  → 作用：_______________
│   │   └── lazy.lua      → 作用：_______________
│   └── plugins/
│       └── example.lua   → 作用：_______________
├── lazy-lock.json        → 作用：_______________
```

**要求**：每个空格用一句话说清楚。

**参考答案**：见 [`reference/exercise-02.md`](./reference/exercise-02.md)

---

## 练习 3：识别反模式（判断对错）

**题目**：判断以下操作是对（OK）还是错（反模式），并说明理由：

| 操作 | 对/错 | 理由 |
|------|-------|------|
| (a) 不备份旧配置，直接 `git clone starter ~/.config/nvim` | ? | ? |
| (b) 在 `lua/plugins/options.lua` 里写 `vim.opt.number = true` | ? | ? |
| (c) 装完运行 `:LazyHealth` 检查是否有警告 | ? | ? |
| (d) 把 lazy.nvim 手动 clone 到 `~/.local/share/nvim/lazy/lazy.nvim` | ? | ? |
| (e) 在 `lua/config/keymaps.lua` 里用 `vim.keymap.set` 设置快捷键 | ? | ? |

**参考答案**：见 [`reference/exercise-03.md`](./reference/exercise-03.md)

---

## 练习 4：模拟安装步骤（排序）

**题目**：以下是安装 LazyVim 的步骤，请按正确顺序排列（用字母排序，如 `D → A → C → B`）：

```
A. 运行 :LazyHealth 检查健康状态
B. clone LazyVim starter 到 ~/.config/nvim
C. 备份旧配置（mv ~/.config/nvim{,.bak}）
D. 第一次启动 nvim（自动 bootstrap lazy.nvim + 下载插件）
E. 运行 :Lazy sync 同步插件版本
```

**正确顺序**：_____ → _____ → _____ → _____ → _____

**参考答案**：见 [`reference/exercise-04.md`](./reference/exercise-04.md)

---

## 练习 5（进阶）：`:Lazy sync` 幕后发生了什么

**题目**：回顾 README 的「第一次 `:Lazy sync` 体验」ASCII 图，回答：

1. `:Lazy sync` 等价于哪三个子命令的组合？
2. 如果你的队友更新了 `lazy-lock.json` 并 push 到 GitHub，你 pull 之后应该运行哪个命令来确保本地插件版本和他一致？
3. `lazy-lock.json` 应该 commit 到版本控制，还是加进 `.gitignore`？为什么？

**参考答案**：见 [`reference/exercise-05.md`](./reference/exercise-05.md)

---

## 如何使用本章代码

```bash
# 验证 init.lua 语法（教学示例，不依赖网络）
cd lazyvim/04-lazyvim-intro
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
# 预期：退出码 0，无报错（会打印 [demo] 提示信息，那是正常的）
```

做完所有练习后，进入 [第05章 配置目录架构](../05-config-architecture/)。
