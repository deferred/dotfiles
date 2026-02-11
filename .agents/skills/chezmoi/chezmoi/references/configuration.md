# Configuration

## Location

`~/.config/chezmoi/chezmoi.<format>` where format is `toml`, `yaml`, `json`, or `jsonc`.

Override with `--config` and `--config-format` flags.

## Top-Level Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `sourceDir` | string | `~/.local/share/chezmoi` | Source directory path |
| `destDir` | string | `$HOME` | Destination directory |
| `cacheDir` | string | `~/.cache/chezmoi` | Cache directory |
| `encryption` | string | `""` | `"age"`, `"gpg"`, or `"transparent"` |
| `format` | string | `"json"` | Output format for dump/data |
| `mode` | string | `"file"` | `"file"` or `"symlink"` (symlink mode creates symlinks to source) |
| `color` | string | `"auto"` | `"auto"`, `"on"`, `"off"` |
| `verbose` | bool | `false` | Verbose output |
| `progress` | bool | `false` | Show progress bars |
| `interactive` | bool | `false` | Prompt for all changes |
| `pager` | string | `$PAGER` | Pager command |
| `umask` | int | system | File creation mask |
| `useBuiltinAge` | string | `"auto"` | `"auto"`, `"on"`, `"off"` |
| `useBuiltinGit` | string | `"auto"` | `"auto"`, `"on"`, `"off"` |
| `scriptEnv` | object | `{}` | Extra env vars for scripts/hooks |
| `env` | object | `{}` | Extra env vars for all commands |
| `workingTree` | string | `sourceDir` | Git working tree path |

## Sections

### [data]

Custom template data, accessible as `.key` in templates:

```toml
[data]
    email = "user@example.com"
    name = "John Doe"
    personal = true
```

### [git]

| Variable | Type | Default | Description |
|---|---|---|---|
| `autoAdd` | bool | `false` | Auto `git add` after source changes |
| `autoCommit` | bool | `false` | Auto `git commit` after changes |
| `autoPush` | bool | `false` | Auto `git push` after commit |
| `command` | string | `"git"` | Git command |
| `commitMessageTemplate` | string | `""` | Go template for commit message |
| `lfs` | bool | `false` | Enable Git LFS |

### [edit]

| Variable | Type | Default | Description |
|---|---|---|---|
| `command` | string | `$VISUAL`/`$EDITOR` | Editor command |
| `args` | list | `[]` | Editor arguments |
| `apply` | bool | `false` | Auto-apply after edit |
| `hardlink` | bool | `true` | Use hardlinks for editing |
| `watch` | bool | `false` | Watch for changes |
| `minDuration` | duration | `"1s"` | Minimum edit duration |

### [diff]

| Variable | Type | Default | Description |
|---|---|---|---|
| `command` | string | `""` | External diff command (e.g., `"delta"`) |
| `args` | list | `[]` | Diff command arguments |
| `exclude` | list | `[]` | Entry types to exclude |
| `pager` | string | `""` | Pager for diff output |
| `reverse` | bool | `false` | Reverse diff direction |
| `scriptContents` | bool | `true` | Show script contents in diff |

### [merge]

| Variable | Type | Default | Description |
|---|---|---|---|
| `command` | string | `"vimdiff"` | Merge tool command |
| `args` | list | `[]` | Merge tool arguments |

### [add]

| Variable | Type | Default | Description |
|---|---|---|---|
| `encrypt` | bool | `false` | Encrypt by default when adding |
| `secrets` | string | `"warning"` | `"ignore"`, `"warning"`, `"error"` |
| `templateSymlinks` | bool | `false` | Template symlinks when adding |

### [age]

| Variable | Type | Default | Description |
|---|---|---|---|
| `command` | string | `"age"` | age command |
| `identity` | string | `""` | Identity file path |
| `identities` | list | `[]` | Multiple identity files |
| `recipient` | string | `""` | Recipient public key |
| `recipients` | list | `[]` | Multiple recipients |
| `recipientsFile` | string | `""` | Recipients file path |
| `passphrase` | bool | `false` | Use passphrase encryption |
| `symmetric` | bool | `false` | Symmetric encryption |
| `suffix` | string | `".age"` | Encrypted file suffix |

### [gpg]

| Variable | Type | Default | Description |
|---|---|---|---|
| `command` | string | `"gpg"` | GPG command |
| `args` | list | `[]` | Extra GPG arguments |
| `recipient` | string | `""` | Recipient key ID |
| `recipients` | list | `[]` | Multiple recipients |
| `suffix` | string | `".asc"` | Encrypted file suffix |
| `symmetric` | bool | `false` | Symmetric encryption |

### [hooks]

Pre/post hooks for chezmoi commands:

```toml
[hooks.read-source-state.pre]
    command = "/path/to/script.sh"
    args = ["arg1"]

[hooks.apply.post]
    command = "notify-send"
    args = ["chezmoi", "apply complete"]
```

Hook points: `read-source-state`, `apply`, `init`, `add`, `edit`, `update`, `diff`, `status`, `verify`

### [interpreters]

Map file extensions to interpreters for scripts:

```toml
[interpreters.py]
    command = "python3"

[interpreters.ps1]
    command = "pwsh"
    args = ["-NoLogo"]
```

### [cd]

```toml
[cd]
    command = "zsh"
    args = []
```

### [status]

```toml
[status]
    exclude = ["scripts"]
    pathStyle = "relative"    # "absolute", "relative", "source-absolute", "source-relative"
```

### [update]

```toml
[update]
    apply = true
    command = "git"
    args = ["pull", "--autostash", "--rebase"]
    recurseSubmodules = true
```

### [template]

```toml
[template]
    options = ["missingkey=error"]    # Go template options
```

### Password manager sections

Each password manager has its own config section: `[onepassword]`, `[bitwarden]`, `[bitwardenSecrets]`, `[lastpass]`, `[pass]`, `[gopass]`, `[keepassxc]`, `[keeper]`, `[vault]`, `[dashlane]`, `[doppler]`, `[awsSecretsManager]`, `[azureKeyVault]`, `[pinentry]`, `[secret]`, and more.

Typically configure `command` and `args` for each.

## Example Config

```toml
sourceDir = "~/.local/share/chezmoi"
encryption = "age"

[data]
    email = "user@example.com"
    name = "John Doe"
    personal = true

[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "age1..."

[git]
    autoCommit = true
    autoPush = true

[edit]
    command = "nvim"

[diff]
    command = "delta"

[merge]
    command = "nvim"
    args = ["-d"]

[hooks.read-source-state.pre]
    command = ".local/share/chezmoi/.install-deps.sh"
```

## Config Template (.chezmoi.toml.tmpl)

Place in source root. Processed during `chezmoi init` to generate machine-specific config:

```gohtml
{{ $email := promptStringOnce . "email" "Email address" -}}
{{ $personal := promptBoolOnce . "personal" "Personal machine? (y/n)" -}}

sourceDir = "~/.local/share/chezmoi"

[data]
    email = {{ $email | quote }}
    personal = {{ $personal }}

{{ if $personal -}}
[git]
    autoPush = true
{{ end -}}
```

Using `promptStringOnce`/`promptBoolOnce` means values are cached after first run — safe to re-run `chezmoi init`.
