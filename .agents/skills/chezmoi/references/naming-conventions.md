# Naming Conventions

## Prefix Ordering by Target Type

Prefixes must appear in the specified order. Each target type allows a specific set:

| Target Type | Prefix Order |
|---|---|
| Directory | `remove_`, `external_`, `exact_`, `private_`, `readonly_`, `dot_` |
| Regular file | `encrypted_`, `private_`, `readonly_`, `empty_`, `executable_`, `dot_` |
| Create file | `create_`, `encrypted_`, `private_`, `readonly_`, `empty_`, `executable_`, `dot_` |
| Modify file | `modify_`, `encrypted_`, `private_`, `readonly_`, `executable_`, `dot_` |
| Remove entry | `remove_`, `dot_` |
| Script | `run_`, `once_` or `onchange_`, `before_` or `after_` |
| Symlink | `symlink_`, `dot_` |

## Suffix Rules

| Suffix | Allowed on |
|---|---|
| `.tmpl` | Regular file, create file, modify file, script, symlink |
| `.literal` | Any (stops further suffix parsing) |

## Prefix Reference

| Prefix | Description |
|---|---|
| `dot_` | Replaced with `.` in target name. `dot_bashrc` → `.bashrc` |
| `private_` | File: `0600`. Directory: `0700`. Removes group+world permissions |
| `readonly_` | Removes all write permission bits |
| `executable_` | Adds execute permission bits |
| `encrypted_` | File is encrypted in source state (decrypted on apply) |
| `empty_` | Preserve file even if empty. Without this, empty files are removed |
| `exact_` | Directories only. Removes any children not managed by chezmoi |
| `create_` | Only create if target doesn't exist. Never overwrites |
| `modify_` | Contents are a script. Receives current target on stdin, stdout becomes new contents |
| `remove_` | Remove the target file/symlink or empty directory |
| `symlink_` | Contents are the symlink target path |
| `run_` | Execute as a script |
| `once_` | Script runs only once (tracked in state DB by content hash) |
| `onchange_` | Script re-runs only when content changes (tracked by content hash) |
| `before_` | Script runs before apply phase |
| `after_` | Script runs after apply phase |
| `external_` | Directory attribute parsing is ignored for children |
| `literal_` | Stop parsing further prefixes. Everything after is literal filename |

## Examples

### Files

```
dot_bashrc                                    → ~/.bashrc
private_dot_ssh/                              → ~/.ssh/ (0700)
private_dot_config/                           → ~/.config/ (0700)
encrypted_private_dot_env                     → ~/.env (encrypted, 0600)
readonly_dot_profile                          → ~/.profile (no write)
empty_dot_gitkeep                             → ~/.gitkeep (kept even if empty)
executable_dot_local/bin/myscript             → ~/.local/bin/myscript (+x)
private_readonly_executable_dot_local/bin/sec → ~/.local/bin/sec (0500)
create_dot_gitconfig                          → ~/.gitconfig (only if missing)
symlink_dot_vim                               → ~/.vim (symlink, contents = target path)
remove_dot_old_config                         → removes ~/.old_config
literal_dot_file                              → .file (literal_ stops parsing)
```

### Directories

```
dot_config/                → ~/.config/
exact_dot_config/app/      → ~/.config/app/ (removes unmanaged files)
private_dot_ssh/           → ~/.ssh/ (0700)
external_dot_oh-my-zsh/    → ~/.oh-my-zsh/ (children not attr-parsed)
```

### Scripts

```
run_install.sh                         → runs every apply
run_before_install.sh                  → runs before apply, every time
run_after_configure.sh                 → runs after apply, every time
run_once_setup.sh                      → runs once ever
run_once_before_install.sh             → runs once, before apply
run_onchange_install.sh                → re-runs when content changes
run_onchange_before_brew.sh.tmpl       → re-runs before, when content changes, templated
run_onchange_after_defaults.sh.tmpl    → re-runs after, when content changes, templated
```

### Templates

```
dot_gitconfig.tmpl                     → ~/.gitconfig (templated)
private_dot_env.tmpl                   → ~/.env (private + templated)
encrypted_dot_secrets.tmpl             → ~/.secrets (encrypted + templated)
```

## Modify Scripts

Modify scripts receive current file contents on stdin and output new contents on stdout:

```bash
#!/bin/bash
# modify_private_dot_config/app/config

# read current contents
current=$(cat)

# append if line not present
if ! echo "$current" | grep -q "setting=value"; then
    echo "$current"
    echo "setting=value"
else
    echo "$current"
fi
```

## Using chattr

Change attributes without renaming files manually:

```bash
chezmoi chattr +executable ~/.local/bin/script
chezmoi chattr +private ~/.ssh/config
chezmoi chattr +template ~/.gitconfig
chezmoi chattr +encrypted ~/.env
chezmoi chattr -empty ~/.gitkeep     # remove empty attribute
```
