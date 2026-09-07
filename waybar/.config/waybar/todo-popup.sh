#!/usr/bin/env bash

CLASS="io.github.alainm23.planify"
SPECIAL="todo"

if hyprctl clients -j | grep -Fq "$CLASS"; then
    hyprctl dispatch "hl.dsp.workspace.toggle_special(\"$SPECIAL\")"
    exit 0
fi

planify >/dev/null 2>&1 &

for _ in $(seq 1 100); do
    if hyprctl clients -j | grep -Fq "$CLASS"; then
        hyprctl dispatch "hl.dsp.workspace.toggle_special(\"$SPECIAL\")"
        exit 0
    fi
    sleep 0.05
done

echo "Could not find Planify window" >&2
exit 1
