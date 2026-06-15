# 练习 4 参考答案 — 安装步骤排序

**正确顺序**：**C → B → D → A → E**

```
C. 备份旧配置（mv ~/.config/nvim{,.bak}）
   ↓
B. clone LazyVim starter 到 ~/.config/nvim
   ↓
D. 第一次启动 nvim（自动 bootstrap lazy.nvim + 下载插件）
   ↓
A. 运行 :LazyHealth 检查健康状态
   ↓
E. 运行 :Lazy sync 同步插件版本
```

**为什么是这个顺序**：

1. **C 必须最先**：不备份就装，旧配置被覆盖或冲突，回不去。
2. **B 在 D 之前**：starter 仓库要先 clone 到位，`nvim` 才能读到 `init.lua`。
3. **D 触发自动下载**：第一次启动时 `init.lua` 的 bootstrap 会 clone lazy.nvim，然后 lazy.nvim 按锁定文件安装插件。
4. **A 在 D 之后**：插件装完才能跑健康检查（有些检查依赖插件已加载）。
5. **E 最后**：`:Lazy sync` 会更新 `lazy-lock.json`，确保版本是最新的。其实 starter 已经带了锁定文件，这步是可选的"刷新"。

**回到 [练习题](../README.md)**
