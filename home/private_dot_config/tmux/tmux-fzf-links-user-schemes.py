import re

from tmux_fzf_links.export import (
    OpenerType,
    PostHandledMatch,
    PreHandledMatch,
    SchemeEntry,
    colors,
    heuristic_find_file,
)
from tmux_fzf_links.errors_types import FailedResolvePath


URL_RGB = (139, 233, 253)
GIT_RGB = (255, 184, 108)
PYTHON_RGB = (80, 250, 123)
CODE_ERR_RGB = (255, 85, 85)


def rgb_text(rgb: tuple[int, int, int], text: str) -> str:
    return f"{colors.rgb_color(*rgb)}{text}{colors.reset_color}"


def git_post_handler(match: re.Match[str]) -> PostHandledMatch:
    server = match.group("server")
    repo = match.group("repo")
    return {"url": f"https://{server}/{repo}"}


git_scheme: SchemeEntry = {
    "tags": ("git",),
    "opener": OpenerType.BROWSER,
    "post_handler": git_post_handler,
    "pre_handler": lambda m: {
        "display_text": rgb_text(GIT_RGB, m.group(0)),
        "tag": "git",
    },
    "regex": [
        re.compile(
            r"(ssh://)?git@(?P<server>[^ \t\n\"\'\)\]\}]+)\:(?P<repo>[^ \.\t\n\"\'\)\]\}]+)"
        )
    ],
}


def code_error_pre_handler(match: re.Match[str]) -> PreHandledMatch | None:
    file = match.group("file")
    line = match.group("line")
    resolved_path = heuristic_find_file(file)

    if resolved_path is None:
        return None

    is_python = resolved_path.suffix == ".py"
    tag = "Python" if is_python else "code err."
    color = PYTHON_RGB if is_python else CODE_ERR_RGB

    return {
        "display_text": rgb_text(color, f"{file}, line {line}"),
        "tag": tag,
    }


def code_error_post_handler(match: re.Match[str]) -> PostHandledMatch:
    file = match.group("file")
    resolved_path = heuristic_find_file(file)

    if resolved_path is None:
        raise FailedResolvePath(f"could not resolve the path of: {file}")

    return {"file": str(resolved_path.resolve()), "line": match.group("line")}


code_error_scheme: SchemeEntry = {
    "tags": ("code err.", "Python"),
    "opener": OpenerType.EDITOR,
    "post_handler": code_error_post_handler,
    "pre_handler": code_error_pre_handler,
    "regex": [re.compile(r"File \"(?P<file>...*?)\"\, line (?P<line>[0-9]+)")],
}


url_scheme: SchemeEntry = {
    "tags": ("url",),
    "opener": OpenerType.BROWSER,
    "post_handler": None,
    "pre_handler": lambda m: {
        "display_text": rgb_text(URL_RGB, m.group(0)),
        "tag": "url",
    },
    "regex": [
        re.compile(
            r"https?://(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}[a-zA-Z0-9()]{1,6}\b[-a-zA-Z0-9()@:%_\+.~#?&//=]*"
        )
    ],
}


user_schemes: list[SchemeEntry] = [url_scheme, git_scheme, code_error_scheme]

rm_default_schemes: list[str] = []

__all__ = ["user_schemes", "rm_default_schemes"]
