#!/bin/bash

# bash demo_transcode_u30.sh /app/input/iu.mp4 /app/output 1 1 1

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
    -v ${PWD}/demo/demo_transcode.sh:/app/demo_transcode.sh \
    -v ${PWD}/demo/demo_transcode_u30.sh:/app/demo_transcode_u30.sh \
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
  echo "> Transcode & Multiscale with U30"
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi

  echo
  echo "= activating drm."

  docker exec -it demo ./drm_man --conf=conf.json --cred=cred.json

  docker exec -it demo source /opt/xilinx/xcdr/setup.sh

  echo
  time docker exec -it demo ffmpeg -hide_banner -c:v mpsoc_vcu_h264 -i ${INPUT_FILE} \
    -filter_complex "multiscale_xma=outputs=3: \
    out_1_width=1280: out_1_height=720: out_1_rate=full: \
    out_2_width=848:  out_2_height=480: out_2_rate=half: \
    out_3_width=288:  out_3_height=160: out_3_rate=half \
    [a][b][c]; [a]split[aa][ab];[ab]fps=30[abb]" \
    -map "[aa]"  -b:v 4M    -c:v mpsoc_vcu_h264 -c:a copy -f mp4 -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p60.mp4" \
    -map "[abb]" -b:v 3M    -c:v mpsoc_vcu_h264 -c:a copy -f mp4 -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p30.mp4" \
    -map "[b]"   -b:v 2500K -c:v mpsoc_vcu_h264 -c:a copy -f mp4 -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_480p30.mp4" \
    -map "[c]"   -b:v 625K  -c:v mpsoc_vcu_h264 -c:a copy -f mp4 -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_288p30.mp4"

  killall drm_man
  echo "deactivating drm"
  echo

fi

echo "= finish."
sleep 3