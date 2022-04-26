#!/bin/bash

# bash demo_transcode.sh /app/input/iu.mp4 /app/output 1 1 1

INPUT_FILE=$1 #"input/iu.mp4"
OUTPUT_DIR=$2 #"output"
OUTPUT_FILE_PREFIX_NAME=${INPUT_FILE//\// }
OUTPUT_FILE_PREFIX_NAME=(${OUTPUT_FILE_PREFIX_NAME//.mp4/ })
OUTPUT_FILE_PREFIX_NAME="${OUTPUT_FILE_PREFIX_NAME[${#OUTPUT_FILE_PREFIX_NAME[@]}-1]}_tr"
SETTING_FLAG=$3
TR_FLAG=$4
ENTER_FLAG=$5
if [[ ${ENTER_FLAG} == '' ]]
then
  ENTER_FLAG=0
else
  ENTER_FLAG=1
fi

cd /home/ubuntu/demo

if [[ ${SETTING_FLAG} == '1' ]]; then
  echo
  echo "> Remove containers below"
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi
  docker stop demo

  echo

  echo
  echo "> Create transcode container"
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi
  docker run --privileged -itd --rm --name demo \
    -v ${PWD}/demo/upscale.sh:/app/demo_transcode.sh \
    -v ${PWD}/demo/upscale.sh:/app/demo_transcode_u30.sh \
    -v ${PWD}/input:/app/input \
    -v ${PWD}/output:/app/output \
    -v ${PWD}/cred.json:/app/cred.json \
    --device=/dev/xclmgmt49408:/dev/xclmgmt49408 --device=/dev/dri/renderD128:/dev/dri/renderD128 sr-new

  echo

fi

echo
echo "> Show container list"
docker ps

if [[ ${TR_FLAG} == '1' ]]; then
  echo
  echo "> Transcode & multiscaling with libx264"
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi
  time docker exec -it demo bash /app/run.sh -hide_banner -i ${INPUT_FILE} \
    -filter_complex '"split=4[a][b][c][d]"' \
    -map '"[a]"' -s 1280x720 -c:v libx264 -c:a copy -r 60 -b:v 4M -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p60.mp4" \
    -map '"[b]"' -s 1280x720 -c:v libx264 -c:a copy -r 30 -b:v 3M -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p30.mp4" \
    -map '"[c]"' -s 848x480 -c:v libx264 -c:a copy -r 30 -b:v 2500K -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_480p30.mp4" \
    -map '"[d]"' -s 288x160 -c:v libx264 -c:a copy -r 30 -b:v 625k -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_288p30.mp4"

  echo

  ls -alht "${OUTPUT_DIR}"
fi