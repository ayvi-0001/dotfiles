local wezterm = require "wezterm" --[[@as Wezterm]]

local M = {}

---@param config Config
---@return Config
function M.apply_to_config(config)
  local docker_domains = M.compute_exec_domains()

  if docker_domains then
    if not config.exec_domains then
      config.exec_domains = docker_domains
    else
      table.insert(config.exec_domains, docker_domains)
    end
  end

  wezterm.log_info("docker domains: ", config.exec_domains)
  return config
end

---@return {}
function M.docker_list()
  local containers = {}
  local _, stdout, _ = wezterm.run_child_process {
    "docker",
    "container",
    "ls",
    "--format",
    "{{.ID}}:{{.Names}}",
  }
  for _, line in ipairs(wezterm.split_by_newlines(stdout)) do
    local id, name = line:match "(.-):(.+)"
    if id and name then
      containers[id] = name
    end
  end
  return containers
end

---@param id string
---@return fun(id: string): string
function M.make_docker_label_func(id)
  ---@param name string
  ---@return string
  return function(name)
    local _, stdout, _ = wezterm.run_child_process {
      "docker",
      "inspect",
      "--format",
      "{{.State.Running}}",
      id,
    }
    local running = stdout == "true\n"
    local color = running and "Green" or "Red"
    return wezterm.format {
      { Foreground = { AnsiColor = color } },
      { Text = "docker container named " .. name },
    }
  end
end

---@param id string
---@return fun(cmd?: table?): string
function M.make_docker_fixup_func(id)
  ---@param cmd? table?
  ---@return table?
  return function(cmd)
    local entrypoint
    if cmd and cmd.args then
      entrypoint = cmd.args
    else
      entrypoint = { "bash" }
    end

    local wrapped = { "exec", "-it", id }

    local docker ---@type string
    if wezterm.target_triple == "x86_64-pc-windows-msvc" then
      docker = "C:/Program Files/Docker/Docker/resources/bin/docker.exe"
    else
      docker = "docker"
    end

    table.insert(wrapped, 1, docker)

    for _, arg in ipairs(entrypoint) do
      table.insert(wrapped, arg)
    end

    cmd.args = wrapped
    return cmd
  end
end

---@return ExecDomain[]
function M.compute_exec_domains()
  local exec_domains = {}
  for id, name in pairs(M.docker_list()) do
    local domain_name = "docker:" .. name
    local fixup_function = M.make_docker_fixup_func(id)
    local label = M.make_docker_label_func(id)
    table.insert(exec_domains, wezterm.exec_domain(domain_name, fixup_function, label))
  end
  return exec_domains
end

return M
