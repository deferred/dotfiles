---
name: chezmoi
description: Manage dotfiles with chezmoi. Covers source state file naming conventions (dot_, private_, executable_, encrypted_, run_, modify_, create_, symlink_, exact_), Go template syntax (.tmpl), .chezmoiexternal.toml externals, .chezmoiignore rules, run scripts, encryption (age/GPG), password manager integrations, and chezmoi configuration. Use when creating, editing, or debugging chezmoi-managed dotfiles, templates, scripts, externals, or ignore rules.
---

# chezmoi - Dotfiles Manager

## Core Model

chezmoi uses a **source state** (git repo at `~/.local/share/chezmoi`) that is computed into a **target state** and applied to the **destination** (`$HOME`). File metadata (permissions, encryption, template behavior) is encoded in source file names via prefixes and suffixes.

## Source Directory Structure

```
~/.local/share/chezmoi/           # source directory (git repo)
├── .chezmoi.toml.tmpl            # config template (prompts during init)
├── .chezmoidata.toml              # custom template data
├── .chezmoidata/                  # additional data files (lexical order)
├── .chezmoiexternal.toml          # external files/archives
├── .chezmoiexternals/             # additional external declarations
├── .chezmoiignore                 # ignore patterns (supports templates)
├── .chezmoiremove                 # patterns of files to remove on apply
├── .chezmoitemplates/             # partial templates for {{ template "name" }}
├── .chezmoiscripts/               # scripts directory (organizational)
├── .chezmoiversion                # minimum required chezmoi version
├── .chezmoiroot                   # redirect source root within repo
├── dot_zshrc                      # → ~/.zshrc
├── private_dot_ssh/               # → ~/.ssh/ (mode 0700)
├── executable_dot_local/bin/foo   # → ~/.local/bin/foo (+x)
└── run_onchange_before_install.sh.tmpl  # run script
```

## File Naming Quick Reference

Encode target file attributes using prefixes (order matters) and suffixes:

| Prefix | Effect |
|---|---|
| `dot_` | Leading `.` in target name |
| `private_` | `0600` file / `0700` dir |
| `readonly_` | Remove write permissions |
| `executable_` | Add execute bit |
| `encrypted_` | Encrypted in source |
| `empty_` | Keep file even if empty |
| `exact_` | (dirs) Remove unmanaged children |
| `create_` | Only create if missing |
| `modify_` | Script that modifies existing file (stdin = current contents) |
| `remove_` | Remove target |
| `symlink_` | Create symlink |
| `run_` | Execute as script |
| `once_` / `onchange_` | Script frequency |
| `before_` / `after_` | Script phase |
| `literal_` | Stop parsing prefixes |

| Suffix | Effect |
|---|---|
| `.tmpl` | Process as Go template |
| `.literal` | Stop parsing suffixes |

For full prefix ordering rules by target type, see [naming-conventions.md](references/naming-conventions.md).

## Templates

Files with `.tmpl` suffix or inside `.chezmoitemplates/` are processed as Go `text/template` with sprig functions.

```gohtml
{{- if eq .chezmoi.os "darwin" }}
export BROWSER="open"
{{- else }}
export BROWSER="xdg-open"
{{- end }}
```

Key variables: `.chezmoi.os`, `.chezmoi.arch`, `.chezmoi.hostname`, `.chezmoi.username`, `.chezmoi.homeDir`

Custom data defined in `[data]` config section or `.chezmoidata.*` files.

For complete template syntax, variables, and functions, see [templating.md](references/templating.md).

## Externals

Declare external files/archives in `.chezmoiexternal.toml`:

```toml
[".oh-my-zsh"]
    type = "archive"
    url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"
```

Types: `file`, `archive`, `archive-file`, `git-repo`. For all options, see [externals.md](references/externals.md).

## Scripts

Name scripts with `run_` prefix plus optional frequency and phase modifiers:

```
run_before_install.sh              # every apply, before other changes
run_once_after_setup.sh            # once ever, after changes
run_onchange_before_brew.sh.tmpl   # when content changes, before, templated
```

Scripts can be templates — useful for OS-conditional execution:

```bash
{{ if eq .chezmoi.os "darwin" -}}
#!/bin/bash
brew install ripgrep
{{ end -}}
```

## .chezmoiignore

Gitignore-style patterns with template support for conditional ignoring:

```
README.md
{{ if ne .chezmoi.os "darwin" }}
.config/karabiner
Library
{{ end }}
```

## Encryption

Configure in `chezmoi.toml`, add files with `chezmoi add --encrypt`:

```toml
encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "age1..."
```

## Password Managers

Use template functions to retrieve secrets (never stored in repo):

```gohtml
{{ onepasswordRead "op://vault/item/field" }}
{{ pass "path/to/secret" }}
{{ (bitwarden "item-id").login.password }}
{{ keyring "service" "user" }}
```

## Common Workflows

```bash
chezmoi add ~/.config/foo        # add file to source state
chezmoi add --encrypt ~/.ssh/key # add encrypted
chezmoi add --template ~/.git*   # add as template
chezmoi edit ~/.zshrc            # edit source, optionally auto-apply
chezmoi diff                     # preview pending changes
chezmoi apply                    # apply source → destination
chezmoi update                   # git pull + apply
chezmoi re-add                   # sync destination changes back to source
chezmoi chattr +executable file  # change source attributes
```

For all commands, see [commands.md](references/commands.md). For config file reference, see [configuration.md](references/configuration.md).

## Reference Files

- [Naming Conventions](references/naming-conventions.md) - Prefix ordering rules by target type, complete examples
- [Templating](references/templating.md) - Go template syntax, built-in variables, sprig functions, password managers
- [Commands](references/commands.md) - All chezmoi commands with usage
- [Configuration](references/configuration.md) - Config file structure, all sections and variables
- [Externals](references/externals.md) - `.chezmoiexternal.toml` types, options, examples
