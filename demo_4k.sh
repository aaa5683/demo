#!/bin/bash

get_times_for_4k() {
  input_resol=$1
  input_resol=(${input_resol//x/ })

  for i in {1..20}
  do
    new_resol_w=$(( ${input_resol[0]} * ${i} ))
    if [[ ${new_resol_w} -gt 3800 ]]
    then
      times=${i}
      break
    fi
  done

  echo ${times}
}

# bash demo_4k.sh /app/input/iu.mp4 640x360 /app/output_sr 1 1 1 1 1

INPUT_FILE=$1
INPUT_RESOL=$2
OUTPUT_DIR=$3
OUTPUT_FILE_NAME=${INPUT_FILE//\// }
OUTPUT_FILE_NAME=(${OUTPUT_FILE_NAME//.mp4/ })
SR_OUTPUT_FILE_NAME="${OUTPUT_FILE_NAME[${#OUTPUT_FILE_NAME[@]}-1]}_4k_sr.mp4"
NON_SR_OUTPUT_FILE_NAME="${OUTPUT_FILE_NAME[${#OUTPUT_FILE_NAME[@]}-1]}_4k.mp4"
STACK_OUTPUT_FILE_NAME="${OUTPUT_FILE_NAME[${#OUTPUT_FILE_NAME[@]}-1]}_4k_hstack.mp4"
SETTING_FLAG=$4
NON_SR_FLAG=$5
SR_FLAG=$6
STACK_FLAG=$7
ENTER_FLAG=$8
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
  TIMES=$(get_times_for_4k ${INPUT_RESOL})
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi
  time docker exec -it non_sr bash /app/upscale.sh -i ${INPUT_FILE} -c:v mpsoc_vcu_h264 -c:a copy -filter_complex "scale=w=iw*${TIMES}:h=ih*${TIMES}" "${OUTPUT_DIR}/${NON_SR_OUTPUT_FILE_NAME}" -y
  # real : 2m25s
fi

echo

if [[ ${SR_FLAG} == '1' ]]; then
  echo
  echo "> Upscale 4k with sr on sr container"
  TIMES=$(get_times_for_4k ${INPUT_RESOL})
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi
  time docker exec -it sr bash /app/upscale_with_sr.sh -i ${INPUT_FILE} -c:v mpsoc_vcu_h264 -c:a copy -filter_complex "scale_startrek=w=iw*${TIMES}:h=ih*${TIMES}:fpga=alveo:c=1" "${OUTPUT_DIR}/${SR_OUTPUT_FILE_NAME}" -y
  # real : 4m28s
fi

echo

if [[ ${STACK_FLAG} == '1' ]]; then
  echo
  echo "> Stack 2 videos"
  if [[ ${ENTER_FLAG} == '1' ]]; then
    read ENTER
  fi
  time docker exec -it sr /app/stack.sh -hide_banner -i "${OUTPUT_DIR}/${NON_SR_OUTPUT_FILE_NAME}" -i "${OUTPUT_DIR}/${SR_OUTPUT_FILE_NAME}" -filter_complex hstack -y "${OUTPUT_DIR}/${STACK_OUTPUT_FILE_NAME}"
fi
