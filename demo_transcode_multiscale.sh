#!/bin/bash

# bash demo_transcode_multiscale.sh /app/input/iu.mp4 /app/output 1 1 1

INPUT_FILE=$1 #"input/iu.mp4"
OUTPUT_DIR=$2 #"output"
OUTPUT_FILE_PREFIX_NAME=${INPUT_FILE//\// }
OUTPUT_FILE_PREFIX_NAME=(${OUTPUT_FILE_PREFIX_NAME//.mp4/ })
OUTPUT_FILE_PREFIX_NAME="${OUTPUT_FILE_PREFIX_NAME[${#OUTPUT_FILE_PREFIX_NAME[@]}-1]}_tr"
SETTING_FLAG=$3
TR_FLAG=$4
TR_U30_FLAG=$5

cd /home/ubuntu/demo

if [[ ${SETTING_FLAG} == '1' ]]; then
  sudo rm -rf output
  mkdir output

  echo
  echo "> Remove containers below"
  read ENTER
  docker stop demo

  echo
  echo "> Create transcode container"
  read ENTER
  docker run --privileged -itd --rm --name demo \
    -v ${PWD}/demo_transcode_multiscale.sh:/app/demo_transcode_multiscale.sh \
    -v ${PWD}/transcode_1.sh:/app/transcode.sh \
    -v ${PWD}/transcode_u30_1.sh:/app/transcode_u30.sh \
    -v ${PWD}/input:/app/input \
    -v ${PWD}/output:/app/output \
    -v ${PWD}/cred.json:/app/cred.json \
    --device=/dev/xclmgmt49408:/dev/xclmgmt49408 --device=/dev/dri/renderD128:/dev/dri/renderD128 sr-new

  docker exec -it demo apt-get install htop

fi

echo
echo "> Show container list"
docker ps


if [[ ${TR_FLAG} == '1' ]]; then
  echo
  echo "> Transcode & multiscaling with libx264"
  read ENTER

  docker exec -it demo bash /app/transcode.sh ${INPUT_FILE} ${OUTPUT_DIR} ${OUTPUT_FILE_PREFIX_NAME}

fi

if [[ ${TR_U30_FLAG} == '1' ]]; then
  echo
  echo "> Transcode & Multiscale with U30"
  read ENTER

  docker exec -it demo bash /app/transcode_u30.sh ${INPUT_FILE} ${OUTPUT_DIR} ${OUTPUT_FILE_PREFIX_NAME}

fi

echo
echo "> Finish all"

echo