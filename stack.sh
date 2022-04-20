#!/bin/bash

# ffmpeg -hide_banner -i output_sr/iu_4k.mp4 -i output_sr/iu_4k_sr.mp4 -c:v mpsoc_vcu_h264 -c:a copy -filter_complex hstack -y output_sr/iu_4k_hstack.mp4

echo "= start stack videos to compare."

source /opt/xilinx/xcdr/setup.sh

FFMPEG_ARGS=$@

cmd="/app/ffmpeg -hide_banner -y ${FFMPEG_ARGS}"
echo "= COMMAND ${cmd}"
eval $cmd
echo "= finish."

sleep 3
