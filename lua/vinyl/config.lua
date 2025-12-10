local M = {}

M.defaults = {
	update_interval = 2000,
	window = {
		width = 56, -- Increased to accommodate queue artwork (4x2) + text
	},
	artwork = {
		enabled = true, -- Enabled with docked window (more stable than floating)
		max_width_chars = 40, -- Maximum width in character cells
		max_height_chars = 20, -- Maximum height in character cells (half of width for square aspect ratio)
	},
	keymaps = {
		ui = {
			close = { "q", "<Esc>" },
			play_pause = "<Space>",
			next_track = "n",
			prev_track = "N",
			seek_forward = "l", -- 5 seconds
			seek_backward = "h", -- 5 seconds
			seek_forward_large = "L", -- 30 seconds
			seek_backward_large = "H", -- 30 seconds
			volume_up = "=",
			volume_down = "-",
			toggle_shuffle = "s",
			show_help = "?",
		},
	},
}

M.options = {}

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
