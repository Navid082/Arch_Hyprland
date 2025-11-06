#!/bin/bash
FILE="$HOME/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
grim -g "$(slurp)" "$FILE" && swappy -f "$FILE"
