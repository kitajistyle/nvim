local patched = false

-- Highlight every occurrence of the live search term in the preview pane,
-- not just the single match fzf-lua highlights by default.
local function ensure_grep_preview_highlight_all()
  if patched then return end
  patched = true

  local ok_builtin, builtin = pcall(require, "fzf-lua.previewer.builtin")
  local ok_grep, mgrep = pcall(require, "fzf-lua.providers.grep")
  local ok_utils, futils = pcall(require, "fzf-lua.utils")
  if not (ok_builtin and ok_grep and ok_utils) then return end

  local orig_preview_buf_post = builtin.buffer_or_file.preview_buf_post

  function builtin.buffer_or_file:preview_buf_post(entry, min_winopts)
    orig_preview_buf_post(self, entry, min_winopts)

    local ok, err = pcall(function()
      local regex = self.opts.__ACT_TO == mgrep.grep and FzfLua.get_info().query
          or self.opts.__ACT_TO == mgrep.live_grep and self.opts.search
          or nil
      if not regex or #regex == 0 then return end

      local winid = self.win and self.win.preview_winid
      if not winid or not vim.api.nvim_win_is_valid(winid) then return end

      self._all_match_ids = self._all_match_ids or {}
      for _, id in ipairs(self._all_match_ids) do
        pcall(vim.fn.matchdelete, id, winid)
      end
      self._all_match_ids = {}

      local case_sensitive = regex:lower() ~= regex
      local magic = futils.regex_to_magic(regex)
      local pattern = case_sensitive and magic or ("\\c" .. magic)
      local hlgroup = (self.win.hls and self.win.hls.search) or "Search"

      local mok, id = pcall(vim.fn.matchadd, hlgroup, pattern, 11, -1, { window = winid })
      if mok and type(id) == "number" then
        table.insert(self._all_match_ids, id)
      end
    end)
    if not ok then
      vim.schedule(function()
        vim.notify("fzf-lua grep preview highlight failed: " .. tostring(err), vim.log.levels.WARN)
      end)
    end
  end
end

local function grep_by_file(opts)
  ensure_grep_preview_highlight_all()
  opts = opts or {}
  opts.rg_opts = "--no-heading --color=never --smart-case --count-matches"
  opts.actions = {
    ["enter"] = function(selected)
      for _, entry in ipairs(selected) do
        local path = entry:match("^([^:]+):")
        if path then vim.cmd.edit(vim.fn.fnameescape(path)) end
      end
    end,
  }
  return opts
end

return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      winopts = {
        width = 1,
        height = 1,
        row = 0.5,
        col = 0.5,
      },
    },
    keys = {
      {
        "<leader>/",
        function() LazyVim.pick.open("live_grep", grep_by_file()) end,
        desc = "Grep (Root Dir, by file)",
      },
      {
        "<leader>sg",
        function() LazyVim.pick.open("live_grep", grep_by_file()) end,
        desc = "Grep (Root Dir, by file)",
      },
      {
        "<leader>sG",
        function() LazyVim.pick.open("live_grep", grep_by_file({ root = false })) end,
        desc = "Grep (cwd, by file)",
      },
    },
  },
}
