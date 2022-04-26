#!/bin/bash

# ffmpeg -hide_banner -i input/iu.mp4 -c:v mpsoc_vcu_h264 -c:a copy -filter_complex "scale_startrek=w=iw*6:h=ih*6:fpga=alveo:c=1" output/iu_4k_sr.mp4 -y

echo "= start upscaling with super resolution."

echo "= activating drm."

./drm_man --conf=conf.json --cred=cred.json

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

cmd="/app/ffmpeg -hide_banner -y ${FFMPEG_ARGS}"
cmd="/app/ffmpeg -hide_banner -y ${FFMPEG_ARGS}"
echo "= COMMAND ${cmd}"
read ENTER
eval $cmd

killall drm_man
echo "= deactivating drm."
echo "= finish."
sleep 3
