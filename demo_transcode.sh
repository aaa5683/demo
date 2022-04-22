#!/bin/bash

# bash demo_transcode.sh /app/input/iu.mp4 /app/output_sr 1

INPUT_FILE=$1 #"input/iu.mp4"
OUTPUT_DIR=$2 #"output_tr"
OUTPUT_FILE_PREFIX_NAME=${INPUT_FILE//\// }
OUTPUT_FILE_PREFIX_NAME=(${OUTPUT_FILE_PREFIX_NAME//.mp4/ })
OUTPUT_FILE_PREFIX_NAME="${OUTPUT_FILE_PREFIX_NAME[${#OUTPUT_FILE_PREFIX_NAME[@]}-1]}_tr"
ENTER_FLAG=$3
if [[ ${ENTER_FLAG} == '' ]]
then
  ENTER_FLAG=0
else
  ENTER_FLAG=1
fi

cd /home/ubuntu/demo
rm -rf ${OUTPUT_DIR}
mkdir ${OUTPUT_DIR}

mkdir out

echo
echo "> Transcode & multiscaling with libx264"
if [[ ${ENTER_FLAG} == '1' ]]; then
  read ENTER
fi
time ffmpeg -hide_banner -i ${INPUT_FILE} \
  -filter_complex "split=4[a][b][c][d]" \
  -map "[a]" -s 1280x720 -c:v libx264 -c:a copy -r 60 -b:v 4M -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p60.mp4" \
  -map "[b]" -s 1280x720 -c:v libx264 -c:a copy -r 30 -b:v 3M -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p30.mp4" \
  -map "[c]" -s 848x480 -c:v libx264 -c:a copy -r 30 -b:v 2500K -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_480p30.mp4" \
  -map "[d]" -s 288x160 -c:v libx264 -c:a copy -r 30 -b:v 625k -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_288p30.mp4"

echo

ls -alht "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_*"