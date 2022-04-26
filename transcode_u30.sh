#!/bin/bash

INPUT_FILE=$1
OUTPUT_DIR=$2
OUTPUT_FILE_PREFIX_NAME=$3

echo "= activating drm."

./drm_man --conf=conf.json --cred=cred.json

source /opt/xilinx/xcdr/setup.sh

FFMPEG_ARGS="-i ${INPUT_FILE} \
-filter_complex 'multiscale_xma=outputs=3: \
out_1_width=1280: out_1_height=720: out_1_rate=full: \
out_2_width=848:  out_2_height=480: out_2_rate=half: \
out_3_width=288:  out_3_height=160: out_3_rate=half \
[a][b][c]; [a]split[aa][ab];[ab]fps=30[abb]' \
-map '[aa]'  -b:v 4M    -c:v mpsoc_vcu_h264 -c:a copy -f mp4 -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p60.mp4 \
-map '[abb]' -b:v 3M    -c:v mpsoc_vcu_h264 -c:a copy -f mp4 -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p30.mp4 \
-map '[b]'   -b:v 2500K -c:v mpsoc_vcu_h264 -c:a copy -f mp4 -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_480p30.mp4 \
-map '[c]'   -b:v 625K  -c:v mpsoc_vcu_h264 -c:a copy -f mp4 -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_288p30.mp4"

#time docker exec -it demo ffmpeg -hide_banner -c:v mpsoc_vcu_h264 -i ${INPUT_FILE} \
#  -filter_complex "multiscale_xma=outputs=3: \
#  out_1_width=1280: out_1_height=720: out_1_rate=full: \
#  out_2_width=848:  out_2_height=480: out_2_rate=half: \
#  out_3_width=288:  out_3_height=160: out_3_rate=half \
#  [a][b][c]; [a]split[aa][ab];[ab]fps=30[abb]" \
#  -map "[aa]"  -b:v 4M    -c:v mpsoc_vcu_h264 -c:a copy -f mp4 -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p60.mp4" \
#  -map "[abb]" -b:v 3M    -c:v mpsoc_vcu_h264 -c:a copy -f mp4 -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_720p30.mp4" \
#  -map "[b]"   -b:v 2500K -c:v mpsoc_vcu_h264 -c:a copy -f mp4 -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_480p30.mp4" \
#  -map "[c]"   -b:v 625K  -c:v mpsoc_vcu_h264 -c:a copy -f mp4 -y "${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_288p30.mp4"

cmd="ffmpeg -hide_banner ${FFMPEG_ARGS}"

cmd_arr=(${cmd})
for i in ${!cmd_arr[@]}
do
  if [ ${cmd_arr[${i}]} == "-filter_complex" ] || [ ${cmd_arr[${i}]} == "-map" ] || [ ${cmd_arr[${i}]} == "out_1_width=1280:" ] || [ ${cmd_arr[${i}]} == "out_2_width=848:" ] || [ ${cmd_arr[${i}]} == "out_3_width=288:" ]; then
    cmd_arr[${i}]="\n\t ${cmd_arr[${i}]}"
  fi
done
cmd_pretty=${cmd_arr[@]}

echo
echo -e "= COMMAND \n> ${cmd_pretty}"
read ENTER
eval $cmd

killall drm_man
echo
echo "deactivating drm"

echo
echo "= results below ->"
ls -lht ${OUTPUT_DIR}

echo
echo "= finish"