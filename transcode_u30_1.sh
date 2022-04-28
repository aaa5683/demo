#!/bin/bash

INPUT_FILE=$1
OUTPUT_DIR=$2
OUTPUT_FILE_PREFIX_NAME=$3

echo "= activating drm."

./drm_man --conf=conf.json --cred=cred.json

source /opt/xilinx/xcdr/setup.sh

#FFMPEG_ARGS="-c:v mpsoc_vcu_h264 -i ${INPUT_FILE} -filter_complex 'multiscale_xma=outputs=1: out_1_width=3840: out_1_height=2160: out_1_rate=full [a]; asplit=outputs=1 aud' -map 'a' -cores 4 -c:v mpsoc_vcu_h264 -map 'aud' -c:a aac -f mp4 -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_4k_u30.mp4"
#FFMPEG_ARGS="-c:v mpsoc_vcu_h264 -i ${INPUT_FILE} -filter_complex 'multiscale_xma=outputs=1: out_1_width=3840: out_1_height=2160: out_1_rate=full [a]' -map '[a]' -cores 4 -c:v mpsoc_vcu_h264 -c:a aac -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_4k_u30.mp4"

FFMPEG_ARGS="-c:v mpsoc_vcu_h264 -i ${INPUT_FILE} \
-filter_complex 'multiscale_xma= outputs=4: \
out_1_width=1280: out_1_height=720: \
out_2_width=1920: out_2_height=1080: \
out_3_width=2560: out_3_height=1440: \
out_4_width=3840: out_4_height=2160 [a][b][c][d]; \
[a]split[aa][ab];[ab]fps=60[aba]; \
[b]split[ba][bb];[bb]fps=60[bba]; \
[c]split[ca][cb];[cb]fps=60[cba]; \
[d]split[da][db];[db]fps=60[dba]' \
-map '[aa]' -b:v 2.5M -c:v mpsoc_vcu_h264 -c:a aac -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_u30_720p30.mp4 \
-map '[aba]' -b:v 2.5M -c:v mpsoc_vcu_h264 -c:a aac -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_u30_720p60.mp4 \
-map '[ba]' -b:v 4M -c:v mpsoc_vcu_h264 -c:a aac -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_u30_1080p30.mp4 \
-map '[bba]' -b:v 4M -c:v mpsoc_vcu_h264 -c:a aac -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_u30_1080p60.mp4 \
-map '[ca]' -b:v 8M -c:v mpsoc_vcu_h264 -c:a aac -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_u30_1440p30.mp4 \
-map '[cba]' -b:v 8M -c:v mpsoc_vcu_h264 -c:a aac -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_u30_1440p60.mp4 \
-map '[da]' -b:v 10M -c:v mpsoc_vcu_h264 -c:a aac -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_u30_4k30.mp4 \
-map '[dba]' -b:v 10M -c:v mpsoc_vcu_h264 -c:a aac -y ${OUTPUT_DIR}/${OUTPUT_FILE_PREFIX_NAME}_u30_4k60.mp4"

cmd="time ffmpeg -hide_banner ${FFMPEG_ARGS}"

cmd_arr=(${cmd})
for i in ${!cmd_arr[@]}
do
  if [ ${cmd_arr[${i}]} == "-filter_complex" ] || [ ${cmd_arr[${i}]} == "-map" ] || [ ${cmd_arr[${i}]} == "-vf" ]; then
    cmd_arr[${i}]="\n\t\t${cmd_arr[${i}]}"
  fi
done
cmd_pretty=${cmd_arr[@]}

echo
echo -e "= COMMAND \n> ${cmd}"
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