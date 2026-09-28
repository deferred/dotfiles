#!/usr/bin/env bash
# Fit each window layout to its window size.
# Called by tmux-resurrect post-restore hook.
#
# restored layouts keep the pane size from save time, while the window keeps
# its current size; tmux sees no size change and leaves the panes too small
tmux list-windows -a -F '#{window_id} #{window_width} #{window_height} #{window_layout}' |
	while read -r id width height layout; do
		# layout format is "checksum,WxH,x,y,..."
		size=${layout#*,}
		size=${size%%,*}
		[ "$size" = "${width}x${height}" ] && continue
		# resizing to the same size still rebuilds the layout
		tmux resize-window -t "$id" -x "$width" -y "$height"
		# resize-window sets window-size to manual; restore the global value
		tmux set-option -uw -t "$id" window-size
	done
