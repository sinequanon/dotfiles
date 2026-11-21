# pi-bolt-local Configuration

This directory contains the pi-bolt-local agent configuration, synced from `work.dotfiles` using `scripts/sync-pi-bolt-local.sh`.

## Files

| File | Description |
|------|-------------|
| `.pi-bolt-local/agent/extensions/statusline.ts` | Standalone statusline extension (disabled npm:@netflix-internal/pi-agent to avoid blocking llama-local) |
| `.pi-bolt-local/agent/skills/humanizer/` | Humanizer skill for rewriting AI-sounding text |
| `.pi-bolt-local/agent/skills/no-ai-slop/` | No-ai-slop skill for editing drafts |
| `.pi-bolt-local/agent/AGENTS.md` | Generic agent instructions (filtered, no Netflix-specific content) |
| `.pi-bolt-local/agent/settings.json` | pi-bolt-local settings with llama-local configured |

## Sync Process

Run `scripts/sync-pi-bolt-local.sh` to copy configuration from `work.dotfiles` to personal dotfiles, then link into `~/.pi-bolt-local/agent/`:

```bash
# Preview changes
./scripts/sync-pi-bolt-local.sh --dry-run

# Apply sync and create links
./scripts/sync-pi-bolt-local.sh

# With git commit and push
./scripts/sync-pi-bolt-local.sh --push

# On a machine without work.dotfiles, just create links from existing repo files
./scripts/sync-pi-bolt-local.sh --link-only
```

## Key Differences from Dotfiles Pi Setup

- Uses `llama-local/local-gguf` instead of Netflix-specific models
- Excludes `@netflix-internal/pi-agent` package (which blocks llama-local)
- AGENTS.md filtered to remove domain-specific references

## Adding New Extensions or Skills

1. Add files to the appropriate subdirectory in `.pi-bolt-local/agent/` in work.dotfiles
2. Run `scripts/sync-pi-bolt-local.sh` to propagate changes to personal dotfiles
3. Run `pi reload` or restart pi-bolt

## Notes

- This is the source of truth - changes should be made in work.dotfiles first, then synced
- The sync script copies *from* work.dotfiles *to* personal dotfiles, then creates symlinks into `~/.pi-bolt-local/agent/`
- For new machines, clone this repo and run `./scripts/sync-pi-bolt-local.sh --link-only` after pulling
