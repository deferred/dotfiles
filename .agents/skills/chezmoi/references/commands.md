# Commands

## Essential Workflow

| Command | Description |
|---|---|
| `chezmoi init [repo]` | Clone dotfiles repo, generate config from template. Use `--apply` to also apply |
| `chezmoi add <target>` | Add target file/dir to source state |
| `chezmoi apply [target...]` | Apply source state to destination. No args = apply all |
| `chezmoi diff [target...]` | Show diff between target state and destination |
| `chezmoi edit [target...]` | Edit source file(s) in `$EDITOR`. Use `--apply` to auto-apply after |
| `chezmoi update` | Pull latest from repo + apply. Combines `git pull` and `apply` |
| `chezmoi cd` | Open shell in source directory |
| `chezmoi git [-- args...]` | Run git in source directory |

## Adding Files

```bash
chezmoi add ~/.bashrc                  # add as regular file
chezmoi add --template ~/.gitconfig    # add as template (.tmpl)
chezmoi add --encrypt ~/.ssh/id_rsa   # add encrypted
chezmoi add --recursive ~/.config/app  # add directory recursively
chezmoi add --exact --recursive ~/.vim # add with exact_ prefix (remove unmanaged)
```

**Flags**: `--encrypt`, `--template`, `--recursive`, `--exact`, `--follow` (follow symlinks)

## Inspection

| Command | Description |
|---|---|
| `chezmoi status` | Show status of all managed entries (A=added, M=modified, D=deleted) |
| `chezmoi managed` | List all managed entries |
| `chezmoi managed --include=files` | List only managed files |
| `chezmoi managed --include=dirs` | List only managed directories |
| `chezmoi unmanaged` | List entries in `$HOME` not managed by chezmoi |
| `chezmoi cat <target>` | Print computed target contents (after template processing) |
| `chezmoi data` | Print all template data as JSON |
| `chezmoi dump [target]` | Dump target state structure as JSON/YAML |
| `chezmoi dump-config` | Print parsed config |
| `chezmoi cat-config` | Print raw config file |
| `chezmoi source-path <target>` | Print source path of a target |
| `chezmoi target-path <source>` | Print target path of a source entry |
| `chezmoi verify [target...]` | Exit 0 if destination matches target, exit 1 otherwise |
| `chezmoi doctor` | Diagnose system problems |
| `chezmoi ignored` | List ignored targets |

## Editing

| Command | Description |
|---|---|
| `chezmoi edit <target>` | Edit source file in `$EDITOR` |
| `chezmoi edit --apply <target>` | Edit and auto-apply |
| `chezmoi edit-config` | Edit `chezmoi.toml` |
| `chezmoi edit-config-template` | Edit `.chezmoi.toml.tmpl` |
| `chezmoi edit-encrypted <target>` | Decrypt, edit, re-encrypt in place |

## Management

| Command | Description |
|---|---|
| `chezmoi re-add [target...]` | Re-add modified destination files back to source |
| `chezmoi forget <target>` | Remove from source state only (keep destination) |
| `chezmoi remove <target>` | Remove from both source and destination |
| `chezmoi chattr <attrs> <target>` | Change source attributes |
| `chezmoi merge <target>` | Three-way merge for a conflicting file |
| `chezmoi merge-all` | Three-way merge for all conflicting files |

### chattr examples

```bash
chezmoi chattr +executable ~/.local/bin/script
chezmoi chattr +private,+readonly ~/.ssh/config
chezmoi chattr +template ~/.gitconfig
chezmoi chattr +encrypted ~/.env
chezmoi chattr -empty ~/.gitkeep
chezmoi chattr +create ~/.local/state/app/config
```

## Encryption

| Command | Description |
|---|---|
| `chezmoi encrypt <file>` | Encrypt a file to stdout |
| `chezmoi decrypt <file>` | Decrypt a file to stdout |
| `chezmoi age keygen` | Generate age key pair |

## Import/Export

| Command | Description |
|---|---|
| `chezmoi archive [--format=tar\|zip]` | Export target state as archive |
| `chezmoi import <archive>` | Import archive into source state |

## State

| Command | Description |
|---|---|
| `chezmoi state dump` | Dump state DB |
| `chezmoi state get-bucket <bucket> --key <key>` | Get state entry |
| `chezmoi state set-bucket <bucket> --key <key> --value <val>` | Set state entry |
| `chezmoi state delete-bucket <bucket>` | Delete state bucket |
| `chezmoi state reset` | Reset all state |

## Other

| Command | Description |
|---|---|
| `chezmoi execute-template <string>` | Render a template string |
| `chezmoi execute-template < file.tmpl` | Render a template file |
| `chezmoi completion bash\|zsh\|fish\|powershell` | Generate shell completions |
| `chezmoi upgrade` | Self-upgrade to latest version |
| `chezmoi purge` | Remove chezmoi config and source state |
| `chezmoi destroy` | Remove source, config, state, and managed targets |
| `chezmoi secret` | Interact with secret managers |
| `chezmoi docker` | Run chezmoi in Docker |

## Global Flags

| Flag | Description |
|---|---|
| `--verbose` / `-v` | Verbose output |
| `--dry-run` / `-n` | Dry run (no changes) |
| `--config <path>` | Override config file path |
| `--source <path>` | Override source directory |
| `--destination <path>` | Override destination directory |
| `--interactive` | Prompt for each change |
| `--debug` | Debug output |
| `--color auto\|on\|off` | Color output |
| `--no-pager` | Disable pager |
| `--exclude <types>` | Exclude entry types from apply/diff |
| `--include <types>` | Include only specified entry types |

### Entry types for --include / --exclude

`all`, `always`, `dirs`, `encrypted`, `externals`, `files`, `remove`, `scripts`, `symlinks`, `templates`
