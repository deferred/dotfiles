#!/usr/bin/env -S uv run --script

import os
import re
import sqlite3
import subprocess
import sys
import tempfile
from pathlib import Path


def pane_session_id(target: str) -> str | None:
    result = subprocess.run(
        ["tmux", "show-option", "-pqv", "-t", target, "@opencode-session-id"],
        capture_output=True,
        check=False,
        text=True,
    )
    return result.stdout.strip() if result.returncode == 0 else None


def matching_session(
    db: sqlite3.Connection, title: str, directory: str, tracked_id: str | None
) -> str | None:
    if not title.startswith("OC | "):
        return None

    name = title.removeprefix("OC | ")
    if name.endswith("…"):
        name = name[:-1]
    if not name:
        return None

    rows = db.execute(
        """SELECT id, directory FROM session
           WHERE parent_id IS NULL AND substr(title, 1, length(?)) = ?""",
        (name, name),
    ).fetchall()
    if tracked_id and any(row[0] == tracked_id for row in rows):
        return tracked_id

    local = [row[0] for row in rows if row[1] == directory]
    if len(local) == 1:
        return local[0]
    if len(rows) == 1:
        return rows[0][0]
    return None


def rewrite(lines: list[str], db: sqlite3.Connection) -> list[str]:
    updated = []
    for line in lines:
        fields = line.rstrip("\n").split("\t")
        if len(fields) != 11 or fields[0] != "pane" or fields[9] != "opencode":
            updated.append(line)
            continue

        target = f"{fields[1]}:{fields[2]}.{fields[5]}"
        directory = fields[7].removeprefix(":").replace("\\ ", " ")
        session_id = matching_session(db, fields[6], directory, pane_session_id(target))
        if session_id and re.fullmatch(r"ses_[A-Za-z0-9]+", session_id):
            fields[10] = f":opencode --session {session_id}"
        else:
            fields[10] = ":"
        updated.append("\t".join(fields) + "\n")
    return updated


def main(path: Path) -> None:
    data_home = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
    db_path = data_home / "opencode/opencode.db"
    if not db_path.is_file():
        return

    with sqlite3.connect(db_path.resolve().as_uri() + "?mode=ro", uri=True) as db:
        original = path.read_text()
        updated = "".join(rewrite(original.splitlines(keepends=True), db))

    if updated == original:
        return

    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as temporary:
        temporary.write(updated)
        temporary_path = Path(temporary.name)
    try:
        temporary_path.replace(path)
    finally:
        temporary_path.unlink(missing_ok=True)


if __name__ == "__main__":
    main(Path(sys.argv[1]))
