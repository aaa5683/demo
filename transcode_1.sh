#!/bin/bash

INPUT_FILE=$1
OUTPUT_DIR=$2
OUTPUT_FILE_PREFIX_NAME=$3

echo "= activating drm."

./drm_man --conf=conf.json --cred=cred.json

source /opt/xilinx/xcdr/setup.sh

FFMPEG_ARGS="-i ${INPUT_FILE} -vf 'scale=3840x2160:flags=lanczos' -c:v libx264 -c:a copy -r 60 -b:v 1M -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_4k.mp4"

cmd="ffmpeg_nou30 -hide_banner ${FFMPEG_ARGS}"

echo
echo -e "= COMMAND \n>  ${cmd}"
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