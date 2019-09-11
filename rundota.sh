# This is for non-debian distros, that put steam in the right place
#DOTA2_DIR="${HOME}/.local/share/Steam/steamapps/common/dota 2 beta"
DOTA2_DIR="${HOME}/.steam/steam/steamapps/common/dota 2 beta"
DOTA2_BIN="${DOTA2_DIR}/game/bin/linuxsteamrt64/dota2"
DOTA2_BENCH_CSV="${DOTA2_DIR}/game/dota/Source2Bench.csv"
if [ -z "$TRACE" ]; then
    TRACE='valve'
fi

# These are set in the shell script used to launch dota2 on Linux. Since that
# also messes with LD_LIBRARY_PATH and LD_PRELOAD we don't call that, but we
# want their thread settings
ulimit -n 2048
ulimit -Ss 1024

export STEAM_RUNTIME=0

# Force the use of two libraries that will either not be installed or will
# conflict with system installed versions
export LD_PRELOAD="${HOME}/.local/share/Steam/ubuntu12_32/steam-runtime/amd64/lib/x86_64-linux-gnu/libudev.so.0 ${HOME}/.local/share/Steam/ubuntu12_32/steam-runtime/amd64/lib/x86_64-linux-gnu/libpng12.so.0 $LD_PRELOAD"

# Set the graphics to high
FLAGS="${FLAGS} -autoconfig_level 3"

# Don't limit the framerate
FLAGS="${FLAGS} +fps_max 0"

# Fullscreen 1920x1080
FLAGS="${FLAGS} -fs -w 1920 -h 1080"

# Show the framerate
FLAGS="${FLAGS} +con_enable 1 +demo_pause -console"

# Run the time demo and quit as soon as finished
if [ $TRACE == "valve" ]; then
    DOTA2_TRACE_FILE=2203598540
    FLAGS="${FLAGS} +timedemo ${DOTA2_TRACE_FILE} +timedemo_start 80000 +timedemo_end 85000 -testscript_inline \"Test_WaitForCheckPoint DemoPlaybackFinished; quit\""
else  # PTS trace
    DOTA2_TRACE_FILE=1971360796
    FLAGS="${FLAGS} +timedemo ${DOTA2_TRACE_FILE} +timedemo_start 50000 +timedemo_end 51000 -testscript_inline \"Test_WaitForCheckPoint DemoPlaybackFinished; quit\""
fi

# Make it work with APITrace
#FLAGS="${FLAGS} -gl_disable_buffer_storage -gl_disable_compressed_texture_pixel_storage"

export DISPLAY=:0
export MESA_LOADER_DRIVER_OVERRIDE=iris

# export ENABLE_VULKAN_RENDERDOC_CAPTURE=1
# export VK_INSTANCE_LAYERS=VK_LAYER_RENDERDOC_Capture
# export VK_INSTANCE_LAYERS=VK_LAYER_MESA_overlay
# export VK_LAYER_MESA_OVERLAY_CONFIG=help
# export ENABLE_MESA_LAYER=1
# export VK_INSTANCE_LAYERS=VK_LAYER_LUNARG_vktrace

# source ~/dev/wip/usr/setup_env.sh

# Start dota2 and set it to kill on shell exit
api=vulkan
# for api in gl vulkan; do
#     for _ in `seq 1 5`; do
        # Gathering trace
        # apitrace trace -o ~/dota2.trace "${DOTA2_BIN}" ${FLAGS} "-${api}" --gl_apitrace -gl_disable_buffer_storage -gl_disable_compressed_texture_pixel_storage -gl_disable_binary_shaders

        # Performance run
        # "${DOTA2_BIN}" ${FLAGS} "-${api}" &> /dev/null
        renderdoccmd capture "${DOTA2_BIN}" ${FLAGS} \"-${api}\" -vulkan_disable_steam_shader_cache # &> /dev/null
        # if [ $? = "0" ]; then break; fi
        echo -n "${api}: "
        tail -2 "${DOTA2_BENCH_CSV}" | head -1 | awk '{print $2}' | tr -d ','
    # done
# done
