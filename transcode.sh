#!/bin/bash

INPUT_FILE=$1
OUTPUT_DIR=$2
OUTPUT_FILE_PREFIX_NAME=$3

FFMPEG_ARGS="-i ${INPUT_FILE} \
-filter_complex 'split=4[a][b][c][d]' \
-map '[a]' -s 1280x720 -c:v libx264 -c:a copy -r 60 -b:v 4M -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p60.mp4 \
-map '[b]' -s 1280x720 -c:v libx264 -c:a copy -r 30 -b:v 3M -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p30.mp4 \
-map '[c]' -s 848x480 -c:v libx264 -c:a copy -r 30 -b:v 2500K -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_480p30.mp4 \
-map '[d]' -s 288x160 -c:v libx264 -c:a copy -r 30 -b:v 625k -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_288p30.mp4"

#time docker exec -it demo ffmpeg_nou30 -hide_banner -i ${INPUT_FILE} \
#  -filter_complex "split=4[a][b][c][d]" \
#  -map "[a]" -s 1280x720 -c:v libx264 -c:a copy -r 60 -b:v 4M -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p60.mp4" \
#  -map "[b]" -s 1280x720 -c:v libx264 -c:a copy -r 30 -b:v 3M -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p30.mp4" \
#  -map "[c]" -s 848x480 -c:v libx264 -c:a copy -r 30 -b:v 2500K -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_480p30.mp4" \
#  -map "[d]" -s 288x160 -c:v libx264 -c:a copy -r 30 -b:v 625k -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_288p30.mp4"

cmd="ffmpeg_nou30 -hide_banner ${FFMPEG_ARGS}"

cmd_arr=(${cmd})
for i in ${!cmd_arr[@]}
do
  if [ ${cmd_arr[${i}]} == "-filter_complex" ] || [ ${cmd_arr[${i}]} == "-map" ]; then
    cmd_arr[${i}]="\n\t\t${cmd_arr[${i}]}"
  fi
done
cmd_pretty=${cmd_arr[@]}

echo
echo -e "= COMMAND \n>  ${cmd_pretty}"
read ENTER
eval $cmd

echo
echo "= results below ->"
ls -lht ${OUTPUT_DIR}

echo
echo "= finish"