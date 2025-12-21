# CLAUDE.md

Development guide for vinyl.nvim.

## Overview

vinyl.nvim is a Neovim music controller supporting Apple Music (macOS) and Spotify. Key characteristics:
- Async I/O via `vim.system()` — never blocks the editor
- Backend abstraction — common interface for different music services
- Kitty graphics protocol for artwork — no external dependencies

## Directory Structure

```
vinyl.nvim/
├── plugin/
│   ├── commands.lua       # :Vinyl command with subcommand completion
│   └── keymaps.lua        # Default keymaps (<leader>m prefix)
├── lua/vinyl/
│   ├── init.lua           # Public API, backend selection, setup()
│   ├── config.lua         # Configuration defaults
│   ├── health.lua         # :checkhealth vinyl
│   ├── ui.lua             # Docked window rendering
│   ├── search.lua         # Library browser (Telescope/fzf-lua/vim.ui.select)
│   ├── highlights.lua     # Highlight group definitions
│   ├── backends/
│   │   ├── backend.lua    # Backend interface (abstract class with types)
│   │   ├── apple.lua      # Apple Music backend
│   │   ├── apple_player.lua # AppleScript execution
│   │   └── spotify.lua    # Spotify Web API backend
│   ├── spotify/
│   │   ├── auth.lua       # OAuth 2.0 flow
│   │   ├── api.lua        # HTTP client with rate limiting
│   │   ├── state.lua      # Token persistence (~/.local/share/nvim/vinyl/)
│   │   └── oauth_server.lua # Temporary HTTP server for OAuth callback
│   ├── artwork.lua        # Main artwork display logic
│   ├── artwork_preloader.lua # Queue artwork prefetching
│   ├── queue_artwork.lua  # Thumbnail rendering for queue
│   ├── kitty.lua          # Kitty graphics protocol implementation
│   ├── cache.lua          # Disk cache for artwork
│   ├── state_cache.lua    # In-memory state caching
│   ├── debouncer.lua      # Rate limiting utility
│   └── debug.lua          # Debug helpers
├── doc/vinyl.txt          # Vim help (canonical reference)
├── .stylua.toml
├── selene.toml
└── vim.yml                # Selene vim globals
```

## Key Patterns

### Backend Interface

All backends implement the interface in `backends/backend.lua`. Key methods:

```lua
backend.available()                    -- Can this backend be used?
backend.init(config)                   -- Initialize
backend.get_state_async(callback)      -- Get playback state
backend.play_pause(callback)           -- Toggle playback
backend.get_library_tracks_async(cb)   -- Fetch library
```

Capabilities are declared per-backend:
```lua
backend.capabilities = {
  playback_control = true,
  volume_control = true,  -- Spotify: device-dependent
  queue_shuffle_accurate = true,  -- Apple: false when shuffle on
  -- ...
}
```

### Async Pattern

All I/O uses callbacks. Error is second parameter:
```lua
backend.get_state_async(function(state, err)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end
  -- use state
end)
```

### UI Updates

The UI uses optimistic updates for responsiveness:
1. User action triggers immediate visual feedback
2. Backend command sent async
3. Next refresh cycle confirms actual state

## Code Style

- Tabs for indentation
- LuaDoc annotations (`---@class`, `---@param`, `---@return`)
- Error-first callbacks: `callback(result, err)`

```bash
stylua lua/ plugin/    # Format
selene lua/ plugin/    # Lint
```

## Common Tasks

### Adding a command

1. Add to `subcommands` table in `plugin/commands.lua`
2. Implement in `lua/vinyl/init.lua` or delegate to appropriate module

### Adding a backend capability

1. Add to `BackendCapabilities` type in `backends/backend.lua`
2. Implement in each backend that supports it
3. Check before use: `if backend.capabilities.new_feature then`

### Testing

```lua
:lua vim.print(require('vinyl').get_backend())
:lua require('vinyl').debug_backend()
:lua require('vinyl').debug_queue()
:checkhealth vinyl
```

## Beads

1. File/update issues for remaining work
Agents should proactively create issues for discovered bugs, TODOs, and follow-up tasks
Close completed issues and update status for in-progress work

2. Run quality gates (if applicable)
Tests, linters, builds - only if code changes were made
File P0 issues if builds are broken

3. Sync the issue tracker carefully
Work methodically to ensure local and remote issues merge safely
Handle git conflicts thoughtfully (sometimes accepting remote and re-importing)
Goal: clean reconciliation where no issues are lost

4. Verify clean state
All changes committed and pushed
No untracked files remain

5. Choose next work
Provide a formatted prompt for the next session with context

