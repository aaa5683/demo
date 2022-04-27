#!/bin/bash

INPUT_FILE=$1
OUTPUT_DIR=$2
OUTPUT_FILE_PREFIX_NAME=$3

echo "= activating drm."

./drm_man --conf=conf.json --cred=cred.json

source /opt/xilinx/xcdr/setup.sh

#FFMPEG_ARGS="-c:v mpsoc_vcu_h264 -i ${INPUT_FILE} -filter_complex 'multiscale_xma=outputs=1: out_1_width=3840: out_1_height=2160: out_1_rate=full [a]; asplit=outputs=1 aud' -map 'a' -cores 4 -c:v mpsoc_vcu_h264 -map 'aud' -c:a aac -f mp4 -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_4k_u30.mp4"
#FFMPEG_ARGS="-c:v mpsoc_vcu_h264 -i ${INPUT_FILE} -filter_complex 'multiscale_xma=outputs=1: out_1_width=3840: out_1_height=2160: out_1_rate=full [a]' -map '[a]' -cores 4 -c:v mpsoc_vcu_h264 -c:a aac -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_4k_u30.mp4"
FFMPEG_ARGS="-i ${INPUT_FILE} \
-filter_complex 'multiscale_xma=outputs=1: out_1_width=1280: out_1_height=720: out_1_rate=full [a]' \
-map '[a]' -cores 4 -b:v 1M -c:v mpsoc_vcu_h264 -c:a copy -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_u30_720p30.mp4"

cmd="ffmpeg -hide_banner ${FFMPEG_ARGS}"

echo
echo -e "= COMMAND \n> ${cmd}"
read ENTER
eval $cmd

killall drm_man
echo
echo "= deactivating drm"

echo
echo "= results below ->"
ls -lht ${OUTPUT_DIR}

echo
echo "= finish"