# 练习 3 参考答案 — fzf-native 扩展

1. **错误**。fzf-native 是用 **C** 实现的，不是 Lua。
2. **正确**。`build = "make"` 会编译 C 代码，需要系统安装了 C 编译器（gcc/clang）。
3. **错误**。`pcall(telescope.load_extension, "fzf")` 用 pcall 保护，失败时静默返回，Telescope 会回退到默认排序器。
4. **正确**。fzf-native 的匹配算法和 `fzf` 命令行工具一样，支持连续字符匹配、大小写智能匹配。
5. **pcall 保护 load_extension**。如果 fzf-native 没编译成功（比如没装 C 编译器），pcall 让它静默失败，不会报错。Telescope 正常工作，只是用默认排序器。

**回到 [练习题](../README.md)**
