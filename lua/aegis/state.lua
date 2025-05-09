-- lua/aegis/state.lua --

local zindex = 100
if pcall(require, 'which-key') then
  zindex = 1001
end

local M = {
  config = {
    excluded_modes = {},
    keyformat = {
      ['<BS>'] = '󰁮 ',
      ['<C>'] = 'Ctrl',
      ['<CR>'] = '󰘌',
      ['<D>'] = '⌘',
      ['<Down>'] = '󰁅',
      ['<Left>'] = '󰁍',
      ['<M>'] = 'Alt',
      ['<PageDown>'] = 'Page 󰁅',
      ['<PageUp>'] = 'Page 󰁝',
      ['<Right>'] = '󰁔',
      ['<Space>'] = '󱁐',
      ['<Up>'] = '󰁝',
    },
    maxkeys = 3,
    position = 'bottom-right',
    show_count = false,
    timeout = 3, -- in secs
    winhl = 'FloatBorder:Comment,Normal:CursorLineNr',
    winopts = {
      border = 'double',
      col = 0,
      focusable = false,
      height = 1,
      relative = 'editor',
      row = 1,
      style = 'minimal',
      zindex = zindex,
    },
  },
  extmark_id = nil,
  keys = {},
  w = 1,
}

return M
