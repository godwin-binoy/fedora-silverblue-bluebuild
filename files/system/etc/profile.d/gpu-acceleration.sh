#!/bin/sh
# Configure hardware-accelerated video decoding APIs
export LIBVA_DRIVER_NAME=iHD
export VDPAU_DRIVER=va_gl

# Enable multi-threaded shader compiler pipelines within Mesa drivers
export thread_submit=true

# Allow ANV Vulkan driver multi-threaded queue submit
export ANV_QUEUE_THREAD_DISABLE=0

# Modern Mesa Shader Cache optimizations to reduce disk wear & stuttering
export MESA_SHADER_CACHE_MAX_SIZE=4G
export MESA_DISK_CACHE_SINGLE_FILE=1
