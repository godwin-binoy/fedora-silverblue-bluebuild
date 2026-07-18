#!/bin/sh
# Force Wayland and EGL hardware acceleration for compositor windows and toolkits
export Intel_BATCH=1
export WEBKIT_DISABLE_COMPOSITING_MODE=0
export CLUTTER_ACTOR_NO_LAYOUT=1
export COGL_RENDERER=egl_wayland
export MUTTER_DEBUG_FORCE_KMS_MODE=simple