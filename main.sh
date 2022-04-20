#!/bin/bash

TASK=$1

case ${TASK} in
  img)

    VIDEO_DIR="data/video/"
    VIDEO_FILE="${VIDEO_DIR}iu_concert.mp4"
    FRAME_DIR="data/frame/"
    if [ -d ${FRAME_DIR} ]
    then
      rm -rf ${FRAME_DIR}
    fi
    mkdir ${FRAME_DIR}

    # 1. extract frames from video considering scene changes (0.25 means that have more than 25% of changes compared to previous)
    echo "1. Extract frames from video considering scene changes."
    time ffmpeg -hide_banner -y -i ${VIDEO_FILE} -vf "select='gt(scene,0.25)'" -vsync vfr "${FRAME_DIR}frame%5d.png"
    # python3 src/display_image.py --path="${FRAME_DIR}"
    # or ls -alh

    # 2. apply Custom SR(Super Resolution) and convert images.
    echo "2. Apply SR(Super Resolution) and Convert."
    SR_FRAME_DIR="data/sr_frame/"
    if [ -d ${SR_FRAME_DIR} ]
    then
      rm -rf ${SR_FRAME_DIR}
    fi
    mkdir ${SR_FRAME_DIR}

    NEW_FRAME_DIR_PREFIX='data/new_frame'
    NEW_RESOL=('640:360' '1280:720' '1920:1080')
    NEW_FRAME_DIR_POSTFIX=()
    NEW_FRAME_DIR=()
    for r in ${NEW_RESOL[@]}
    do
      TMP=(`echo ${r} | tr ":" "x" `)
      NEW_FRAME_DIR_POSTFIX+=(${TMP})
      NEW_FRAME_DIR+=("${NEW_FRAME_DIR_PREFIX}_${TMP}")
      if [ -d "${NEW_FRAME_DIR_PREFIX}_${TMP}" ]
      then
        rm -rf "${NEW_FRAME_DIR_PREFIX}_${TMP}"
      fi
      mkdir "${NEW_FRAME_DIR_PREFIX}_${TMP}"
    done

    for i in ${FRAME_DIR}*
    do
      FRAME_NAME=(`echo ${i} | cut -d "/" -f3 | cut -d "." -f1 `)
      echo ${FRAME_NAME}
      time ffmpeg -hide_banner -loglevel error -y -i ${i} -filter_complex "split=3[d][u1][u2]; [d]scale=${NEW_RESOL[0]}[d_s]; [u1]scale=${NEW_RESOL[1]}[u1_s]; [u2]scale=${NEW_RESOL[2]}[u2_s]" \
        -map "[d_s]" "${NEW_FRAME_DIR[0]}/${FRAME_NAME}_${NEW_FRAME_DIR_POSTFIX[0]}.jpg" \
        -map "[u1_s]" "${NEW_FRAME_DIR[1]}/${FRAME_NAME}_${NEW_FRAME_DIR_POSTFIX[1]}.jpg" \
        -map "[u2_s]" "${NEW_FRAME_DIR[2]}/${FRAME_NAME}_${NEW_FRAME_DIR_POSTFIX[2]}.jpg"
    done

    ;;

  video)
    echo "video"
    ;;
  4k_streaming)
    echo "4k_streaming"
    ;;
  *)
    echo "[ERROR] Invalid Task : choose [img, video, 4k_streaming]"
    ;;
esac