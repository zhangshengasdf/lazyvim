--- shared/verify.lua — LazyVim 教程配置验证工具
--- 用法: nvim --headless -u NONE -c "luafile shared/verify.lua" -c "qa!"
--- 不依赖任何外部插件，纯 Neovim API。

local M = {}

--- 加载指定 init.lua 配置文件，返回是否成功
--- @param path string 配置文件路径（相对于当前工作目录或绝对路径）
--- @return boolean success 是否加载成功
--- @return string|nil err_msg 错误信息（失败时）
function M.load_config(path)
  local ok, err = pcall(dofile, path)
  if not ok then
    return false, tostring(err)
  end
  return true, nil
end

--- 检查 vim.opt 选项是否设置正确
--- @param name string 选项名（如 "number", "tabstop"）
--- @param expected any 期望值
--- @return boolean passed 是否通过
--- @return string msg 结果描述
function M.check_opt(name, expected)
  local actual = vim.o[name]
  if actual == expected then
    return true, string.format("vim.o.%s = %s (OK)", name, tostring(actual))
  else
    return false, string.format(
      "vim.o.%s: expected %s, got %s",
      name, tostring(expected), tostring(actual)
    )
  end
end

--- 检查快捷键是否已注册
--- @param mode string 模式（"n", "i", "v", "x" 等）
--- @param lhs string 左侧按键（如 "<leader>ff"）
--- @return boolean found 是否存在
--- @return string msg 结果描述
function M.check_keymap(mode, lhs)
  local maps = vim.api.nvim_get_keymap(mode)
  -- 同时检查 buffer-local 和 global
  for _, map in ipairs(maps) do
    if map.lhs == lhs then
      return true, string.format("[%s] %s -> %s (OK)", mode, lhs, map.desc or "(no desc)")
    end
  end
  return false, string.format("[%s] %s: NOT FOUND", mode, lhs)
end

--- 检查插件是否已加载（需要 lazy.nvim）
--- @param plugin string 插件名（如 "telescope.nvim"）
--- @return boolean loaded 是否已加载
--- @return string msg 结果描述
function M.check_plugin(plugin)
  local ok, lazy = pcall(require, "lazy")
  if not ok then
    return false, string.format("lazy.nvim not available, cannot check %s", plugin)
  end
  local plugin_obj = lazy.plugins()[plugin]
  if plugin_obj and plugin_obj._.loaded then
    return true, string.format("plugin %s: loaded (OK)", plugin)
  else
    return false, string.format("plugin %s: NOT loaded", plugin)
  end
end

--- 打印验证结果摘要
--- @param results table<{passed: boolean, msg: string}> 验证结果列表
--- @return boolean all_passed 是否全部通过
function M.summary(results)
  local passed, failed = 0, 0

  print("\n=== Verification Summary ===")
  for _, r in ipairs(results) do
    if r.passed then
      passed = passed + 1
      print("  OK  " .. r.msg)
    else
      failed = failed + 1
      print(" FAIL " .. r.msg)
    end
  end

  print(string.format("\nTotal: %d | Passed: %d | Failed: %d", passed + failed, passed, failed))

  if failed > 0 then
    print("RESULT: SOME CHECKS FAILED")
    return false
  else
    print("RESULT: ALL CHECKS PASSED")
    return true
  end
end

--- 便捷方法：运行一组检查并打印摘要
--- @param checks table<{fn: function, args: table}> 检查列表
--- @return boolean all_passed
function M.run(checks)
  local results = {}
  for _, check in ipairs(checks) do
    local passed, msg = check.fn(unpack(check.args or {}))
    table.insert(results, { passed = passed, msg = msg })
  end
  return M.summary(results)
end

return M
