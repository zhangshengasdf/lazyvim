# 项目 1 练习 — 全栈 TypeScript 配置

> 做练习前先读完 [项目 README](../README.md)。
> 练习答案先自己想，实在不会再看参考。

---

## 练习 1：添加 Vue 支持

**题目**：你想在同一个配置中支持 Vue 3 + TypeScript 项目。

已知：
- Vue 的语言服务器是 `vue-language-server`（Mason 包名：`vue-language-server`）
- Vue 文件类型是 `vue`
- 格式化器用 prettier
- linter 用 eslint

**要求**：
1. 写出在 `lsp.lua` 中追加 Vue LSP 的配置（用 extend 模式）
2. 写出在 `formatting.lua` 中追加 Vue 文件格式化器的配置
3. 写出在 `linting.lua` 中追加 Vue 文件 linter 的配置
4. 写出在 `extra.lua` 的 Treesitter 中追加 `vue` 解析器的配置

**提示**：
- Vue LSP 需要单独配置 `init_options`（Vue 插件路径）
- 用 `opts = function(_, opts)` extend 模式
- 不要覆盖已有的 vtsls 和 eslint 配置

---

## 练习 2：自定义格式化器

**题目**：你的团队决定不用 prettier，改用 **biome**（一个更快的 JS/TS 格式化器+linter）。

已知：
- biome 的 CLI 命令是 `biome`
- 它同时做格式化和 linting（替代 prettier + eslint）
- Mason 包名：`biome`

**要求**：
1. 写出修改 `formatting.lua` 的配置，让 TS/JS 文件用 biome 而非 prettier
2. 写出修改 `linting.lua` 的配置，让 TS/JS 文件用 biome 而非 eslint
3. 这个修改会影响其他文件类型（CSS、HTML）的格式化器吗？为什么？

**提示**：
- 用 `opts.formatters_by_ft.typescript = { "biome" }` 替换
- biome 选项通过 `prepend_args` 传给 CLI
- CSS/HTML 等文件类型仍然用 prettier（biome 不支持）

---

## 练习 3：添加测试运行器

**题目**：你想在 Neovim 里直接运行 Jest 测试，不用切换到终端。

已知：
- neotest 插件可以在 Neovim 里运行测试
- neotest-jest 适配器支持 Jest
- LazyVim 有 neotest Extra（`lazyvim.plugins.extras.test.core`）

**要求**：
1. 写出在 `extra.lua` 中追加 neotest + neotest-jest 的 spec
2. 设置快捷键 `<leader>tt`（运行最近的测试）和 `<leader>tf`（运行当前文件的测试）
3. 用 `keys` 懒加载（测试运行器不需要启动时加载）

**提示**：
- neotest 的 spec 格式：`{ "nvim-neotest/neotest", dependencies = { "marilari88/neotest-jest" } }`
- 快捷键用 `function() require("neotest").run.run() end` 模式
- 所有快捷键必须带 `desc`

---

## 如何使用本项目代码

```bash
cd lazyvim/projects/01-ts-fullstack

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/config/options.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/lsp.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/formatting.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/linting.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/extra.lua" -c 'qa!'
# 预期：全部退出码 0

# 真实环境部署：
# cp -r lua/config ~/.config/nvim/lua/config
# cp -r lua/plugins ~/.config/nvim/lua/plugins
# nvim → :Lazy sync → 打开 .ts 文件 → 测试 gd / <leader>cf / 保存自动格式化
```

做完所有练习后，进入 [项目 2：Python 后端配置](../02-python-backend/)。

---

## 相关章节

本项目的练习涉及以下章节的知识，遇到困难时回去复习：

| 练习 | 涉及章节 | 核心知识点 |
|------|----------|-----------|
| 练习 1 | Ch12（LSP）、Ch11（Treesitter） | extend 模式追加服务器和解析器 |
| 练习 2 | Ch14（格式化）、Ch14（检查） | formatters_by_ft / linters_by_ft 替换 |
| 练习 3 | Ch16（DAP）、Ch17（插件模式） | keys 懒加载、dependencies 配置 |
