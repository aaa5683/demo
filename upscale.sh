#!/bin/bash

# ffmpeg -hide_banner -i input/iu.mp4 -c:v mpsoc_vcu_h264 -c:a copy -filter_complex "scale=w=iw*6:h=ih*6" output/iu_4k.mp4 -y

echo "[INFO] start upscaling."

source /opt/xilinx/xcdr/setup.sh

FFMPEG_ARGS=$@
ARR=(${FFMPEG_ARGS})
for i in ${!ARR[@]}
do
  if [[ ${ARR[${i}]} == *"filter_complex"* ]]; then
    FILTER_IDX=$(( $((${i})) + $((1)) ))
    ARR[${FILTER_IDX}]="'${ARR[${FILTER_IDX}]}'"
  fi
done
FFMPEG_ARGS=${ARR[@]}

echo "[INFO] start upscaling with super resolution."

cmd="/app/ffmpeg -hide_banner -y ${FFMPEG_ARGS}"
echo "[INFO] COMMAND ${cmd}"
eval $cmd
echo "[INFO] finish."

sleep 3
