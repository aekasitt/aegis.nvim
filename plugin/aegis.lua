vim.api.nvim_create_user_command('AegisToggle', function()
	require('aegis').toggle()
end, { desc = 'Toggle Aegis plugin' })
