-- lua/aegis/utils.lua --

local M = {}
local state = require 'aegis.state'

local is_mouse = function(x)
  return x:match 'Mouse' or x:match 'Scroll' or x:match 'Drag' or x:match 'Release'
end

local format_mapping = function(str)
  local keyformat = state.config.keyformat

  local str1 = string.match(str, '<(.-)>')
  if not str1 then
    return str
  end

  local before, after = string.match(str1, '([^%-]+)%-(.+)')

  if before then
    before = '<' .. before .. '>'
    before = keyformat[before] or before
    str1 = before .. ' + ' .. string.lower(after)
  end

  local str2 = string.match(str, '>(.+)')
  return str1 .. (str2 and (' ' .. str2) or '')
end

M.gen_winconfig = function()
  local lines = vim.o.lines
  local cols = vim.o.columns
  state.config.winopts.width = state.width

  local pos = state.config.position

  if string.find(pos, 'bottom') then
    state.config.winopts.row = lines - 4 - 1  -- -1 for zero-based indexing or border
  end

  if pos == 'top-right' then
    state.config.winopts.col = cols - state.width - 3
  elseif pos == 'top-center' or pos == 'bottom-center' then
    state.config.winopts.col = math.floor(cols / 2) - math.floor(state.width / 2)
  elseif pos == 'bottom-right' then
    state.config.winopts.col = cols - state.width - 3
  end
end

local update_window_width = function()
  local keyslen = #state.keys
  state.width = keyslen + 1 + (2 * keyslen) -- 2 spaces around each key

  for _, v in ipairs(state.keys) do
    state.width = state.width + vim.fn.strwidth(v.txt)
  end

  M.gen_winconfig()
  if state.window then
    vim.api.nvim_win_set_config(state.window, state.config.winopts)
  end
end

M.draw = function()
  local virt_txts = require 'aegis.interface'()

  if not state.extmark_id then
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, { ' ' })
  end

  local opts = { virt_text = virt_txts, virt_text_pos = 'overlay', id = state.extmark_id }
  local id = vim.api.nvim_buf_set_extmark(state.buf, state.ns, 0, 1, opts)

  if not state.extmark_id then
    state.extmark_id = id
  end
end

M.redraw = function()
  update_window_width()
  M.draw()
end

M.clear_and_close = function()
  state.keys = {}
  M.redraw()
  if state.window then
    local tmp = state.window
    state.window = nil
    vim.api.nvim_win_close(tmp, true)
  end
end

M.parse_key = function(char)
  local opts = state.config

  if vim.tbl_contains(opts.excluded_modes, vim.api.nvim_get_mode().mode) then
    if state.window then
      M.clear_and_close()
    end
    return
  end

  local key = vim.fn.keytrans(char)

  if is_mouse(key) or key == '' then
    return
  end

  key = opts.keyformat[key] or key
  key = format_mapping(key)

  local arrlen = #state.keys
  local last_key = state.keys[arrlen]

  if opts.show_count and last_key and key == last_key.key then
    local count = (last_key.count or 1) + 1

    state.keys[arrlen] = {
      key = key,
      txt = count .. ' ' .. key,
      count = count,
    }
  else
    if arrlen == opts.maxkeys then
      table.remove(state.keys, 1)
    end

    table.insert(state.keys, { key = key, txt = key })
  end

  M.redraw()
end

return M
