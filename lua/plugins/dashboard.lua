-- Custom dashboard logo + entrance animation.
-- The logo is rendered by `tte` (terminal-text-effects,
-- https://github.com/ChrisBuilds/terminaltexteffects) inside a floating
-- terminal window overlaid on the snacks.nvim dashboard header, inspired by
-- dashboard-nvim's preview feature. Falls back to a static header when
-- `tte` isn't installed.
local logo = [[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
██████████████    ██████████    ██████████████    ██████████
          ████  ████      ████            ████  ████      ████
        ████    ████      ████          ████    ████      ████
      ████      ████      ████        ████      ████      ████
    ████        ████      ████      ████        ████      ████
  ████          ████      ████    ████          ████      ████
██████████████    ██████████    ██████████████    ██████████
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━]]

local header_lines = vim.split(vim.trim(logo), "\n", { plain = true })
local has_tte = vim.fn.executable("tte") == 1

-- tte animation styles; one is picked at random each time Neovim starts.
local subcommands = {
  "middleout --center-movement-speed 0.8 --full-movement-speed 0.2",
  "slide --merge --movement-speed 0.8",
  "beams --beam-delay 5 --beam-row-speed-range 20-60 --beam-column-speed-range 8-12",
}

math.randomseed(os.time())
local cmd = {
  "sh",
  "-c",
  "echo "
    .. vim.fn.shellescape(vim.trim(logo))
    .. " | tte --anchor-canvas s "
    .. subcommands[math.random(#subcommands)]
    .. " --final-gradient-direction diagonal",
}

-- Find the first run of at least `height` consecutive blank lines in `buf`
-- (i.e. the header padding reserved below) and return its 0-indexed start row.
local function find_header_row(buf, height)
  local all = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local run = 0
  for i, line in ipairs(all) do
    if vim.trim(line) == "" then
      run = run + 1
      if run >= height then
        return i - height
      end
    else
      run = 0
    end
  end
  return nil
end

-- Find the window/buffer showing the snacks dashboard, regardless of which
-- window currently has focus (e.g. when a directory arg opened an explorer
-- sidebar alongside it and stole focus).
local function find_dashboard_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "snacks_dashboard" then
      return win, buf
    end
  end
end

-- Open an unfocusable floating window over the dashboard header and play
-- the `tte` animation into it via a terminal job.
local function display_logo()
  local dash_win, dash_buf = find_dashboard_win()
  if not dash_win then
    return
  end

  local line_widths = vim.tbl_map(function(line)
    return vim.fn.strdisplaywidth(line)
  end, header_lines)
  local width = math.max(unpack(line_widths))
  local height = #header_lines + 1
  local row = find_header_row(dash_buf, #header_lines) or 2
  local col = math.floor((vim.api.nvim_win_get_width(dash_win) - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, false, {
    style = "minimal",
    relative = "win",
    win = dash_win,
    width = width,
    height = height,
    row = row,
    col = col,
    border = "none",
    focusable = false,
    noautocmd = true,
  })
  vim.api.nvim_set_option_value("winblend", 100, { scope = "local", win = win })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { scope = "local", buf = buf })

  vim.api.nvim_buf_call(buf, function()
    vim.fn.jobstart(cmd, {
      term = true,
      -- Close the overlay as soon as the animation finishes instead of
      -- leaving the terminal's "[Process exited 0]" message on screen.
      on_exit = function()
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end)
      end,
    })
  end)

  return { buf = buf, win = win, dash_buf = dash_buf }
end

local augroup = vim.api.nvim_create_augroup("dashboard_logo_animation", { clear = true })

if has_tte then
  vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = "SnacksDashboardOpened",
    desc = "Play the animated logo when the dashboard opens",
    callback = function()
      local logo_info = display_logo()
      if not logo_info then
        return
      end
      vim.api.nvim_create_autocmd("BufLeave", {
        group = augroup,
        once = true,
        buffer = logo_info.dash_buf,
        desc = "Close the animated logo window",
        callback = function()
          if vim.api.nvim_win_is_valid(logo_info.win) then
            vim.api.nvim_win_close(logo_info.win, true)
          end
        end,
      })
    end,
  })
end

return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      -- When `tte` is available, leave blank space for the animated overlay
      -- above; otherwise fall back to the static logo.
      opts.dashboard.preset.header = has_tte and string.rep("\n", #header_lines + 1) or logo
      return opts
    end,
  },
}
