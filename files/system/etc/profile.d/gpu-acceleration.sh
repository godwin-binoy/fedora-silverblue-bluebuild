#!/bin/sh
# Force Wayland and hardware acceleration across modern display layers
export INTEL_BATCH=1
export WEBKIT_DISABLE_COMPOSITING_MODE=0
export CLUTTER_ACTOR_NO_LAYOUT=1
export COGL_RENDERER=egl_wayland

# Intel ANV Vulkan optimizations
export ANV_QUEUE_THREAD_DISABLE=1

# Enable multi-threaded shader compiler pipelines within Mesa drivers
export thread_submit=true