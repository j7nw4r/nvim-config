-- Asynchronous CMake driver.
--
-- The old `<leader>C*` maps shelled out with `:!cmake -B build`, which blocks
-- the editor and drops the vcpkg toolchain file. A vcpkg manifest restore can
-- run for the better part of an hour, so every command here streams into a
-- scratch buffer and fills the quickfix list when it finishes.
--
-- Per-project settings come from `vim.g.cmake_*`, which a repo can set in its
-- own `.nvim.lua` (exrc is on; see lua/options.lua).
--
--   vim.g.cmake_configure_args  -- table of extra `-D...` flags
--   vim.g.cmake_build_dir       -- build directory name, default "build"
--   vim.g.cmake_generator        -- generator name, default Ninja when present

local M = {}

local OUTPUT_BUF_NAME = "cmake://output"

-- gcc/clang/MSVC diagnostics, plus the `file:line:col:` form ninja echoes.
local ERRORFORMAT = table.concat({
  "%f:%l:%c: %trror: %m",
  "%f:%l:%c: %tarning: %m",
  "%f:%l:%c: %tote: %m",
  "%f:%l: %trror: %m",
  "%f:%l: %tarning: %m",
  "%f(%l): %trror %*[^:]: %m",
  "%f(%l): %tarning %*[^:]: %m",
  "CMake Error at %f:%l%m",
  "CMake Warning at %f:%l%m",
  "%-G%.%#",
}, ",")

local job = nil

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "cmake" })
end

--- Return the directory to configure from.
---
--- A monorepo such as azure-sdk-for-cpp builds from the top: the repository
--- root holds CMakeLists.txt and vcpkg.json, while intermediate directories
--- (sdk/) hold neither. So the git root wins whenever it is a CMake project,
--- and only otherwise does the nearest CMakeLists.txt ancestor apply.
function M.root()
  local start = vim.api.nvim_buf_get_name(0)
  if start == "" then
    start = vim.uv.cwd()
  end

  local git = vim.fs.root(start, ".git")
  if git and vim.uv.fs_stat(git .. "/CMakeLists.txt") then
    return git
  end

  return vim.fs.root(start, "CMakeLists.txt") or git or vim.uv.cwd()
end

function M.build_dir()
  return M.root() .. "/" .. (vim.g.cmake_build_dir or "build")
end

--- Locate a vcpkg checkout and return its CMake toolchain file, or nil.
local function vcpkg_toolchain()
  local candidates = {}
  if vim.env.VCPKG_ROOT and vim.env.VCPKG_ROOT ~= "" then
    table.insert(candidates, vim.env.VCPKG_ROOT)
  end
  local on_path = vim.fn.exepath("vcpkg")
  if on_path ~= "" then
    table.insert(candidates, vim.fs.dirname(vim.uv.fs_realpath(on_path) or on_path))
  end
  table.insert(candidates, vim.fn.expand("~/vcpkg"))

  for _, dir in ipairs(candidates) do
    local toolchain = dir .. "/scripts/buildsystems/vcpkg.cmake"
    if vim.uv.fs_stat(toolchain) then
      return toolchain
    end
  end
  return nil
end

local function output_buf()
  local existing = vim.fn.bufnr(OUTPUT_BUF_NAME)
  if existing ~= -1 and vim.api.nvim_buf_is_valid(existing) then
    return existing
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, OUTPUT_BUF_NAME)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "cmakeoutput"
  return buf
end

--- Open the output buffer in a bottom split, unless it is already visible.
function M.open_output()
  local buf = output_buf()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  vim.cmd("botright 15split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.wo.number = false
  vim.wo.relativenumber = false
end

local function append(buf, lines)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local last = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_buf_set_lines(buf, last, last, false, lines)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
    end
  end
end

--- Run `cmd` in `cwd`, streaming output into the scratch buffer.
---
--- `validate` is optional. It receives the collected output lines after a
--- zero exit code and returns a warning string when the run only looks like a
--- success.
local function run(title, cmd, cwd, validate)
  if job then
    notify("A cmake job is already running. Use <leader>Cx to stop it.", vim.log.levels.WARN)
    return
  end

  local buf = output_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "$ cd " .. cwd,
    "$ " .. table.concat(cmd, " "),
    "",
  })
  M.open_output()

  local collected = {}
  local function on_output(_, data)
    if not data then
      return
    end
    local lines = vim.split(data:gsub("\r\n", "\n"):gsub("\r", "\n"), "\n", { trimempty = true })
    if #lines == 0 then
      return
    end
    vim.list_extend(collected, lines)
    vim.schedule(function()
      append(buf, lines)
    end)
  end

  notify(title .. ": started")
  job = vim.system(cmd, {
    cwd = cwd,
    text = true,
    stdout = on_output,
    stderr = on_output,
  }, function(result)
    job = nil
    vim.schedule(function()
      vim.fn.setqflist({}, " ", {
        title = title,
        lines = collected,
        efm = ERRORFORMAT,
      })
      if result.code == 0 then
        local warning = validate and validate(collected)
        if warning then
          notify(title .. ": " .. warning, vim.log.levels.WARN)
        else
          notify(title .. ": succeeded")
        end
      else
        notify(title .. ": failed (exit " .. result.code .. ")", vim.log.levels.ERROR)
        vim.cmd("copen")
      end
    end)
  end)
end

function M.stop()
  if not job then
    notify("No cmake job is running.")
    return
  end
  job:kill("sigterm")
  notify("Stopped the cmake job.", vim.log.levels.WARN)
end

--- Configure the project. Always exports compile_commands.json, because that
--- is the only thing clangd reads. clangd finds it in `<root>/build/` on its
--- own, so no symlink is needed.
function M.configure(extra)
  local root = M.root()
  local cmd = {
    "cmake",
    "-S",
    root,
    "-B",
    M.build_dir(),
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
  }

  local generator = vim.g.cmake_generator
  if generator == nil and vim.fn.executable("ninja") == 1 then
    generator = "Ninja"
  end
  if generator then
    table.insert(cmd, "-G")
    table.insert(cmd, generator)
  end

  -- vcpkg manifest mode: without the toolchain file, cmake never restores the
  -- dependencies listed in vcpkg.json and configure fails on the first
  -- find_package.
  if vim.uv.fs_stat(root .. "/vcpkg.json") then
    local toolchain = vcpkg_toolchain()
    if toolchain then
      table.insert(cmd, "-DCMAKE_TOOLCHAIN_FILE=" .. toolchain)
    else
      notify("vcpkg.json found but no vcpkg checkout. Set VCPKG_ROOT.", vim.log.levels.WARN)
    end
  end

  vim.list_extend(cmd, vim.g.cmake_configure_args or {})
  vim.list_extend(cmd, extra or {})
  run("configure", cmd, root)
end

function M.build(target)
  local cmd = { "cmake", "--build", M.build_dir(), "--parallel" }
  if target and target ~= "" then
    table.insert(cmd, "--target")
    table.insert(cmd, target)
  end
  run(target and ("build " .. target) or "build", cmd, M.root())
end

function M.test(filter)
  local cmd = { "ctest", "--test-dir", M.build_dir(), "--output-on-failure" }
  if filter and filter ~= "" then
    table.insert(cmd, "-R")
    table.insert(cmd, filter)
  end

  -- ctest exits 0 when -R matches nothing, so a typo in the regex would
  -- otherwise report a passing run. Read the output instead of the code.
  run("ctest", cmd, M.root(), function(lines)
    for _, line in ipairs(lines) do
      if line:match("No tests were found") then
        return "no test matched the filter"
      end
    end
    return nil
  end)
end

--- Prompt for a target, completing on the targets cmake reports.
function M.build_prompt()
  local targets = {}
  local listing = vim.system(
    { "cmake", "--build", M.build_dir(), "--target", "help" },
    { text = true }
  ):wait()
  if listing.code == 0 then
    for line in (listing.stdout or ""):gmatch("[^\n]+") do
      local name = line:match("^%.%.%.%s+(%S+)") or line:match("^(%S+):")
      if name then
        table.insert(targets, name)
      end
    end
  end

  if #targets == 0 then
    vim.ui.input({ prompt = "Target: " }, function(target)
      if target then
        M.build(target)
      end
    end)
    return
  end

  vim.ui.select(targets, { prompt = "Target" }, function(target)
    if target then
      M.build(target)
    end
  end)
end

--- List the executables the build produced.
---
--- Ninja knows exactly which outputs come from an executable link rule, so ask
--- it rather than guessing from the file mode. A `find` sweep also picks up
--- CMake's compiler probes and, in a tree with a Rust component, every cargo
--- build script.
local function executables(dir)
  local binaries = {}

  if vim.uv.fs_stat(dir .. "/build.ninja") and vim.fn.executable("ninja") == 1 then
    local listing = vim.system({ "ninja", "-C", dir, "-t", "targets", "all" }, { text = true }):wait()
    if listing.code == 0 then
      for line in (listing.stdout or ""):gmatch("[^\n]+") do
        local output, rule = line:match("^(.-):%s*(%S+)$")
        if output and rule and rule:match("EXECUTABLE_LINKER") and not output:match("%.cmake$") then
          local path = vim.startswith(output, "/") and output or (dir .. "/" .. output)
          if vim.uv.fs_stat(path) then
            table.insert(binaries, path)
          end
        end
      end
      return binaries
    end
  end

  -- Makefile generators and anything else: fall back to the file mode.
  for _, path in ipairs(vim.fn.systemlist({ "find", dir, "-type", "f", "-perm", "-u+x" })) do
    local skip = path:match("/CMakeFiles/")
      or path:match("/cargo/")
      or path:match("%.o$")
      or path:match("%.a$")
      or path:match("%.dylib$")
      or path:match("%.so$")
      or path:match("%.cmake$")
      or path:match("%.lock$")
    if not skip then
      table.insert(binaries, path)
    end
  end
  return binaries
end

--- Pick an executable under the build directory and run it in a terminal.
function M.run_binary()
  local dir = M.build_dir()
  local binaries = executables(dir)

  if #binaries == 0 then
    notify("No executables under " .. dir, vim.log.levels.WARN)
    return
  end

  vim.ui.select(binaries, {
    prompt = "Run",
    format_item = function(path)
      return path:sub(#dir + 2)
    end,
  }, function(path)
    if path then
      vim.cmd("botright 15split | terminal " .. vim.fn.fnameescape(path))
    end
  end)
end

function M.setup()
  local command = vim.api.nvim_create_user_command
  command("CMakeConfigure", function(opts)
    M.configure(opts.fargs)
  end, { nargs = "*", desc = "Configure the project (async)" })
  command("CMakeBuild", function(opts)
    M.build(opts.args)
  end, { nargs = "?", desc = "Build the project (async)" })
  command("CMakeTest", function(opts)
    M.test(opts.args)
  end, { nargs = "?", desc = "Run ctest (async)" })
  command("CMakeStop", M.stop, { desc = "Stop the running cmake job" })
  command("CMakeOutput", M.open_output, { desc = "Open the cmake output buffer" })
  command("CMakeRoot", function()
    notify("root: " .. M.root() .. "\nbuild: " .. M.build_dir())
  end, { desc = "Show the detected project and build directory" })
end

return M
