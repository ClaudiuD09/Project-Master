#!/bin/sh
echo -ne '\033c\033]0;Project-DIS-Remake\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Project-DIS-Remake.x86_64" "$@"
