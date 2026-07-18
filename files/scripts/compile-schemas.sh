#!/usr/bin/env bash
set -euo pipefail

# Compile any custom GNOME settings/dconf schema overrides before outputting image
if [ -d "/usr/share/glib-2.0/schemas" ]; then
    echo "Compiling GLib schemas..."
    glib-compile-schemas /usr/share/glib-2.0/schemas/
fi