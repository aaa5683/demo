#!/bin/bash

# bash demo_transcode_multiscale.sh /app/input/iu.mp4 /app/output 1 1 1 1

INPUT_FILE=$1 #"input/iu.mp4"
OUTPUT_DIR=$2 #"output"
OUTPUT_FILE_PREFIX_NAME=${INPUT_FILE//\// }
OUTPUT_FILE_PREFIX_NAME=(${OUTPUT_FILE_PREFIX_NAME//.mp4/ })
OUTPUT_FILE_PREFIX_NAME="${OUTPUT_FILE_PREFIX_NAME[${#OUTPUT_FILE_PREFIX_NAME[@]}-1]}_tr"
SETTING_FLAG=$3
TR_FLAG=$4
TR_U30_FLAG=$5
ENTER_FLAG=$6
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
    -v ${PWD}/demo_transcode_multiscale.sh:/app/demo_transcode_multiscale.sh \
    -v ${PWD}/transcode.sh:/app/transcode.sh \
    -v ${PWD}/transcode_u30.sh:/app/transcode_u30.sh \
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

  echo
  time docker exec -it demo bash /app/transcode.sh ${INPUT_FILE} ${OUTPUT_DIR} ${OUTPUT_FILE_PREFIX_NAME}

fi

echo

if [[ ${TR_U30_FLAG} == '1' ]]; then
  echo
  echo "> Transcode & Multiscale with U30"
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi

  echo
  time docker exec -it demo bash /app/transcode_u30.sh ${INPUT_FILE} ${OUTPUT_DIR} ${OUTPUT_FILE_PREFIX_NAME}

fi

echo
echo "> Finish all"