# Templating

## When Files Are Treated as Templates

1. File has `.tmpl` suffix in source state
2. File is inside `.chezmoitemplates/` directory

## Syntax

Go `text/template` syntax, extended with [sprig](https://masterminds.github.io/sprig/) functions.

```gohtml
{{ .variable }}              # output variable
{{- .variable }}             # trim whitespace before
{{ .variable -}}             # trim whitespace after
{{- .variable -}}            # trim both sides
{{ /* comment */ }}           # comment

# conditionals
{{ if eq .chezmoi.os "darwin" }}mac{{ end }}
{{ if eq .chezmoi.os "darwin" }}mac{{ else if eq .chezmoi.os "linux" }}linux{{ else }}other{{ end }}

# range
{{ range .list }}{{ . }}{{ end }}

# variable assignment
{{ $email := "user@example.com" }}
{{ $name := output "git" "config" "user.name" | trim }}

# with (sets dot context)
{{ with .chezmoi }}OS: {{ .os }}, Arch: {{ .arch }}{{ end }}

# template inclusion
{{ template "header" . }}
```

## Built-in Variables

### .chezmoi namespace

| Variable | Example | Description |
|---|---|---|
| `.chezmoi.os` | `"darwin"`, `"linux"`, `"windows"` | Operating system |
| `.chezmoi.arch` | `"amd64"`, `"arm64"` | Architecture |
| `.chezmoi.hostname` | `"macbook"` | Short hostname |
| `.chezmoi.fqdnHostname` | `"macbook.local"` | Fully qualified hostname |
| `.chezmoi.username` | `"john"` | Current user |
| `.chezmoi.uid` | `"501"` | User ID (Unix) |
| `.chezmoi.gid` | `"20"` | Group ID (Unix) |
| `.chezmoi.homeDir` | `"/home/john"` | Home directory |
| `.chezmoi.sourceDir` | `"/home/john/.local/share/chezmoi"` | Source directory |
| `.chezmoi.cacheDir` | `"/home/john/.cache/chezmoi"` | Cache directory |
| `.chezmoi.configFile` | `"/home/john/.config/chezmoi/chezmoi.toml"` | Config file path |
| `.chezmoi.executable` | `"/usr/bin/chezmoi"` | chezmoi binary path |
| `.chezmoi.version.major` | `2` | chezmoi major version |
| `.chezmoi.version.minor` | `40` | chezmoi minor version |
| `.chezmoi.kernel` | (Linux only) | Kernel info object |
| `.chezmoi.osRelease` | (Linux only) | `/etc/os-release` data |

### Custom data

Defined in config `[data]` section or `.chezmoidata.*` files. Accessed directly:

```toml
# chezmoi.toml
[data]
    email = "user@example.com"
    name = "John Doe"
```

```gohtml
{{ .email }}  {{ .name }}
```

## Data Source Priority (later overwrites earlier)

1. `.chezmoi.*` built-in variables
2. `.chezmoidata.<format>` files (alphabetical by filename)
3. `.chezmoidata/` directory files (alphabetical)
4. `[data]` section in config file

## Template Functions

### Prompts (used in `.chezmoi.toml.tmpl` for init)

```gohtml
{{ $email := promptStringOnce . "email" "What is your email" }}
{{ $personal := promptBoolOnce . "personal" "Is this a personal machine" }}
{{ $age := promptIntOnce . "age" "Enter age" }}
{{ $choice := promptChoiceOnce . "editor" "Preferred editor" (list "vim" "emacs" "code") }}
```

`promptStringOnce` only prompts if value not already set — safe to re-run `chezmoi init`.

### Command execution

```gohtml
{{ output "command" "arg1" "arg2" }}          # run command, return stdout
{{ output "command" "arg1" "arg2" | trim }}    # trim trailing newline
```

### File system

```gohtml
{{ stat "/path/to/file" }}                     # file info
{{ glob "/path/to/*.conf" }}                   # glob for files
{{ include "filename" }}                       # include source file contents
{{ joinPath .chezmoi.homeDir ".config" "app" }}  # join path segments
{{ lookPath "binary" }}                        # find binary in PATH (empty if not found)
```

### Environment

```gohtml
{{ env "HOME" }}                               # read env var
{{ env "EDITOR" | default "vim" }}             # with fallback
```

### Password Manager Functions

```gohtml
# 1Password
{{ onepasswordRead "op://vault/item/field" }}
{{ (onepasswordDetailsFields "item").password.value }}
{{ onepasswordDocument "document-id" }}

# Bitwarden
{{ (bitwarden "item").login.password }}
{{ (bitwarden "item").login.username }}

# Bitwarden Secrets Manager
{{ (bitwardenSecrets "secret-id").value }}

# LastPass
{{ (index (lastpass "entry") 0).password }}

# KeePassXC
{{ (keepassxc "entry").Password }}
{{ keepassxcAttribute "entry" "custom-attr" }}

# Pass
{{ pass "path/to/entry" }}

# Gopass
{{ gopass "path/to/secret" }}

# HashiCorp Vault
{{ (vault "secret/data/item").data.password }}

# Dashlane
{{ (dashlane "entry").password }}

# Doppler
{{ doppler "SECRET_NAME" }}

# AWS Secrets Manager
{{ (awsSecretsManager "secret-name").password }}

# Azure Key Vault
{{ azureKeyVault "secret-name" }}

# Generic keyring
{{ keyring "service" "user" }}
```

### String functions (sprig)

```gohtml
{{ "hello" | upper }}          # HELLO
{{ "HELLO" | lower }}          # hello
{{ "hello" | title }}          # Hello
{{ "  hi  " | trim }}          # hi
{{ "hello" | replace "l" "r"}} # herro
{{ "hello" | contains "ell" }} # true
{{ "hello" | hasPrefix "he" }} # true
{{ "hello" | hasSuffix "lo" }} # true
{{ "a,b,c" | split "," }}     # list
{{ list "a" "b" | join "," }} # a,b
{{ "value" | quote }}          # "value" (with quotes)
{{ "value" | squote }}         # 'value'
```

### Conditional helpers

```gohtml
{{ if eq .chezmoi.os "darwin" }}mac{{ end }}
{{ if ne .chezmoi.os "windows" }}unix{{ end }}
{{ if and (eq .chezmoi.os "linux") (eq .chezmoi.arch "amd64") }}linux-amd64{{ end }}
{{ if or (eq .chezmoi.os "darwin") (eq .chezmoi.os "linux") }}unix-like{{ end }}
{{ if not (lookPath "brew") }}# brew not installed{{ end }}
```

## Partial Templates (.chezmoitemplates/)

Create reusable template fragments in `.chezmoitemplates/`:

```
.chezmoitemplates/
├── header              # no .tmpl suffix needed here
├── ssh-config-block
└── git-aliases
```

Use in other templates:

```gohtml
{{ template "header" . }}
{{ template "ssh-config-block" . }}
```

## Config Template (.chezmoi.toml.tmpl)

Processed during `chezmoi init` to generate machine-specific config:

```gohtml
{{ $email := promptStringOnce . "email" "Email address" -}}
{{ $personal := promptBoolOnce . "personal" "Personal machine? (y/n)" -}}

[data]
    email = {{ $email | quote }}
    personal = {{ $personal }}

{{ if $personal -}}
[git]
    autoPush = true
{{ end -}}
```

## Testing Templates

```bash
# test a template string
chezmoi execute-template '{{ .chezmoi.os }}'
chezmoi execute-template '{{ output "hostname" | trim }}'

# test a file
chezmoi cat ~/.bashrc

# print all template data
chezmoi data
```
