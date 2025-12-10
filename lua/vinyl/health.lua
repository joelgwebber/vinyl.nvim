local M = {}

local health = vim.health or require("health")
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local warn = health.warn or health.report_warn
local error = health.error or health.report_error
local info = health.info or health.report_info

function M.check()
	start("vinyl.nvim")

	-- Check Neovim version
	if vim.fn.has("nvim-0.8") == 1 then
		ok("Neovim >= 0.8")
	else
		error("Neovim >= 0.8 required")
	end

	-- Check backends
	start("Backends")

	-- Apple Music (macOS only)
	if vim.fn.has("mac") == 1 then
		ok("macOS detected - Apple Music backend available")
		-- Check if Music.app exists
		local music_app = vim.fn.isdirectory("/System/Applications/Music.app")
		if music_app == 1 then
			ok("Music.app found")
		else
			warn("Music.app not found at expected location")
		end
	else
		info("Not on macOS - Apple Music backend unavailable")
	end

	-- Spotify
	local spotify_state = require("vinyl.spotify.state")
	local tokens = spotify_state.load_tokens()
	local config = spotify_state.load_config()

	if tokens and config then
		ok("Spotify: authenticated")
		if tokens.expires_at then
			local expires = os.date("%Y-%m-%d %H:%M", tokens.expires_at)
			info("Spotify token expires: " .. expires)
		end
	elseif config and not tokens then
		warn("Spotify: configured but not authenticated (run :Vinyl spotify-login)")
	else
		info("Spotify: not configured (run :Vinyl spotify-login to set up)")
	end

	-- Check artwork support
	start("Artwork")

	local term = vim.env.TERM or ""
	local kitty_detected = term:find("kitty") or vim.env.KITTY_WINDOW_ID

	if kitty_detected then
		ok("Kitty terminal detected - artwork support available")
	else
		info("Kitty not detected (TERM=" .. term .. ") - artwork disabled")
		info("Album artwork requires Kitty terminal with graphics protocol")
	end

	-- Check optional integrations
	start("Library Browsing")

	local has_telescope = pcall(require, "telescope")
	local has_fzf = pcall(require, "fzf-lua")

	if has_telescope then
		ok("telescope.nvim available")
	elseif has_fzf then
		ok("fzf-lua available")
	else
		info("No fuzzy finder detected - will use vim.ui.select")
		info("Install telescope.nvim or fzf-lua for better library browsing")
	end
end

return M
