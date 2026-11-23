#!/bin/sh

icon=$1
target=$2

case "$icon" in
    "") kind="tmux session" ;;
    "") kind="zoxide entry" ;;
    *) exit 0 ;;
esac

printf '\nRemove %s "%s"? [y/N] ' "$kind" "$target"
IFS= read -r answer </dev/tty

case "$answer" in
    y | Y) ;;
    *) exit 0 ;;
esac

case "$icon" in
    "") tmux kill-session -t "$target" ;;
    "")
        case "$target" in
            "~/"*) target="$HOME/${target#\~/}" ;;
        esac
        zoxide remove -- "$target"
        ;;
esac
