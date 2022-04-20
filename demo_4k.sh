#!/bin/bash

INPUT_FILE="input/iu.mp4"
OUTPUT_DIR="output_sr"
SETTING_FLAG=$1
NON_SR_FLAG=$2
SR_FLAG=$3
STACK_FLAG=$4
ENTER_FLAG=$5
if [[ ${ENTER_FLAG} == '' ]]
then
  ENTER_FLAG=0
else
  ENTER_FLAG=1
fi

cd /home/bm100/sr-test

if [[ ${SETTING_FLAG} == '1' ]]; then
  echo
  echo "> Remove containers below"
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi
  docker stop non_sr
  docker stop sr

  echo

  echo
  echo "> Create non_sr container"
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi
  docker run --privileged -itd --rm --name non_sr \
    -v ${PWD}/demo/upscale.sh:/app/upscale.sh \
    -v ${PWD}/input:/app/input \
    -v ${PWD}/output_sr:/app/output_sr \
    -v ${PWD}/cred.json:/app/cred.json \
    --device=/dev/xclmgmt24065:/dev/xclmgmt24065 --device=/dev/dri/renderD128:/dev/dri/renderD128 sr-ubuntu

  echo

  echo
  echo "> Create sr container"
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi
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
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi
  time docker exec -it non_sr bash /app/upscale.sh -i ${INPUT_FILE} -filter_complex "scale=w=iw*6:h=ih*6" "${OUTPUT_DIR}/iu_4k.mp4" -y
fi

echo

if [[ ${SR_FLAG} == '1' ]]; then
  echo
  echo "> Upscale 4k with sr on sr container"
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi
  time docker exec -it sr bash /app/upscale_with_sr.sh -i ${INPUT_FILE} -c:v mpsoc_vcu_h264 -c:a copy -filter_complex "scale_startrek=w=iw*6:h=ih*6:fpga=alveo:c=1" "${OUTPUT_DIR}/iu_4k_sr.mp4" -y
fi

if [[ ${STACK_FLAG} == '1' ]]; then
  echo
  echo "> Stack 2 videos"
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi
  time docker exec -it sr /app/stack.sh -hide_banner -i "${OUTPUT_DIR}/iu_4k.mp4" -i "${OUTPUT_DIR}/iu_4k_sr.mp4" -filter_complex hstack -y "${OUTPUT_DIR}/iu_4k_hstack.mp4"
fi
