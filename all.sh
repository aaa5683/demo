#!/bin/bash

INPUT_FILE="input/iu.mp4"
OUTPUT_DIR="output_sr"
SETTING_FLAG=$1
NON_SR_FLAG=$2
SR_FLAG=$3
STACK_FLAG=$4

cd /home/bm100/sr-test

if [[ ${SETTING_FLAG} == '1' ]]; then
  echo
  echo "> Remove containers below"
  docker stop non_sr
  docker stop sr

  echo

  echo
  echo "> Create non_sr container"
  docker run --privileged -itd --rm --name non_sr \
    -v ${PWD}/demo/upscale.sh:/app/upscale.sh \
    -v ${PWD}/input:/app/input \
    -v ${PWD}/output_sr:/app/output_sr \
    -v ${PWD}/cred.json:/app/cred.json \
    --device=/dev/xclmgmt24065:/dev/xclmgmt24065 --device=/dev/dri/renderD128:/dev/dri/renderD128 sr-ubuntu

  echo

  echo
  echo "> Create sr container"
  docker run --privileged -itd --rm --name sr \
    -v ${PWD}/demo/upscale_with_sr.sh:/app/upscale_with_sr.sh \
    -v ${PWD}/demo/stack.sh:/app/stack.sh \
    -v ${PWD}/input:/app/input \
    -v ${PWD}/output_sr:/app/output_sr \
    -v ${PWD}/cred.json:/app/cred.json \
    --device=/dev/xclmgmt24065:/dev/xclmgmt24065 --device=/dev/dri/renderD128:/dev/dri/renderD128 sr-ubuntu
fi

echo
echo "> Show container list"
docker ps

if [[ ${NON_SR_FLAG} == '1' ]]; then
  echo
  echo "> Upscale 4k without sr on non_sr container"
  time docker exec -it non_sr bash /app/upscale.sh -i ${INPUT_FILE} -c:v copy -c:a copy -filter_complex "scale=w=iw*6:h=ih*6" "${OUTPUT_DIR}/iu_4k.mp4" -y
fi

echo

if [[ ${SR_FLAG} == '1' ]]; then
  echo
  echo "> Upscale 4k with sr on sr container"
  time docker exec -it sr bash /app/upscale_with_sr.sh -i input/iu.mp4 -c:v mpsoc_vcu_h264 -c:a copy -filter_complex "scale_startrek=w=iw*6:h=ih*6:fpga=alveo:c=1" "${OUTPUT_DIR}/iu_4k_sr.mp4" -y
fi

if [[ ${STACK_FLAG} == '1' ]]; then
  echo
  echo "> Stack 2 videos"
  time docker exec -it sr /app/stack.sh -hide_banner -i output_sr/iu_4k.mp4 -i output_sr/iu_4k_sr.mp4 -c:v mpsoc_vcu_h264 -c:a copy -filter_complex hstack -y output_sr/iu_4k_hstack.mp4
fi
