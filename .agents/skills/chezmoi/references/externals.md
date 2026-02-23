# Externals

Externals pull files and archives from URLs as if they were part of the source state. Declared in `.chezmoiexternal.toml` (or `.chezmoiexternal.yaml`/`.json`) or in files under `.chezmoiexternals/`.

## Types

| Type | Description |
|---|---|
| `file` | Download a single file |
| `archive` | Download and extract an archive (tar.gz, zip, etc.) |
| `archive-file` | Extract a single file from an archive |
| `git-repo` | Clone a git repository |

## Common Options

| Option | Type | Description |
|---|---|---|
| `type` | string | Required. One of: `file`, `archive`, `archive-file`, `git-repo` |
| `url` | string | Required. URL to download (supports templates) |
| `refreshPeriod` | duration | How often to re-download (e.g., `"168h"` = weekly) |
| `encrypted` | bool | Whether the downloaded content is encrypted |
| `filter.command` | string | Filter command to pipe content through |
| `filter.args` | list | Arguments for filter command |

## File Options

```toml
[".vim/autoload/plug.vim"]
    type = "file"
    url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    refreshPeriod = "168h"
    executable = true          # make file executable
```

| Option | Type | Description |
|---|---|---|
| `executable` | bool | Make file executable |

## Archive Options

```toml
[".oh-my-zsh"]
    type = "archive"
    url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"
    include = ["*/plugins/**"]
    exclude = ["*/test/**"]
```

| Option | Type | Description |
|---|---|---|
| `stripComponents` | int | Strip leading path components from archive entries |
| `exact` | bool | Remove files in target dir not in archive |
| `include` | list | Glob patterns to include |
| `exclude` | list | Glob patterns to exclude |
| `format` | string | Override auto-detected format (`tar`, `tar.gz`, `tgz`, `tar.bz2`, `tbz2`, `zip`) |

## Archive-File Options

Extract a single file from an archive:

```toml
[".local/bin/age"]
    type = "archive-file"
    url = "https://github.com/FiloSottile/age/releases/download/v1.1.1/age-v1.1.1-{{ .chezmoi.os }}-{{ .chezmoi.arch }}.tar.gz"
    path = "age/age"
    executable = true
```

| Option | Type | Description |
|---|---|---|
| `path` | string | Path of the file within the archive |
| `executable` | bool | Make extracted file executable |
| `stripComponents` | int | Strip leading path components before matching `path` |

## Git-Repo Options

```toml
[".tmux/plugins/tpm"]
    type = "git-repo"
    url = "https://github.com/tmux-plugins/tpm.git"
    refreshPeriod = "168h"
    pull.args = ["--ff-only"]
```

| Option | Type | Description |
|---|---|---|
| `clone.args` | list | Extra args for `git clone` |
| `pull.args` | list | Extra args for `git pull` |

## Template URLs

URLs support Go template syntax:

```toml
[".local/bin/tool"]
    type = "archive-file"
    url = "https://github.com/org/tool/releases/download/v1.0/tool-{{ .chezmoi.os }}-{{ .chezmoi.arch }}.tar.gz"
    path = "tool"
```

## GitHub API Example

```toml
["www/adminer/plugins"]
    type = "archive"
    url = "https://api.github.com/repos/vrana/adminer/tarball"
    refreshPeriod = "744h"
    stripComponents = 2
    include = ["*/plugins/**"]
```

## Multiple External Files

Organize additional externals in `.chezmoiexternals/` directory. Files are read in lexical order alongside `.chezmoiexternal.<format>`:

```
.chezmoiexternals/
├── editors.toml
├── shell-plugins.toml
└── tools.toml
```

## Refresh Behavior

- `refreshPeriod` controls how often chezmoi re-downloads
- Cached in `~/.cache/chezmoi/`
- Common values: `"168h"` (weekly), `"744h"` (monthly), `"24h"` (daily)
- Omit `refreshPeriod` to download once and cache forever
- Force refresh: `chezmoi apply --refresh-externals`
