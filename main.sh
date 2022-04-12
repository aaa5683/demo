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
    ffmpeg -i ${VIDEO_FILE} -vf "select='gt(scene,0.25)'" -vsync vfr "${FRAME_DIR}frame%5d.jpg"
    python3 src/display_image.py --path="${FRAME_DIR}"

    # 2. apply Custom SR(Super Resolution) and convert images.
    echo "2. Apply SR(Super Resolution) and Convert."
    SR_FRAME_DIR="data/sr_frame/"
    if [ -d ${SR_FRAME_DIR} ]
    then
      rm -rf ${SR_FRAME_DIR}
    fi
    mkdir ${SR_FRAME_DIR}


    ffmpeg -i data/frame/frame00001.jpg -i data/frame/frame00002.jpg -filter_complex vstack data/img_sr_result.jpg
#    ffmpeg -i frame00001.jpg -filter_complex "multiscale_xma=outputs=4: \
#      out_1_width=1280: out_1_height=720:  out_1_rate=full: \
#      out_2_width=848:  out_2_height=480:  out_2_rate=half: \
#      out_3_width=640:  out_3_height=360:  out_3_rate=half: \
#      out_4_width=288:  out_4_height=160:  out_4_rate=half  \
#      [a][b][c][d]; [a]split[aa][ab]; [ab]fps=30[abb]; \
#      [aa]xvbm_convert[aa1];[abb]xvbm_convert[abb1];[b]xvbm_convert[b1];[c]xvbm_convert[c1]; \
#      [d]xvbm_convert[d1]" \
#      -map "[aa1]"  -pix_fmt yuv420p -f rawvideo xil_dec_scale_720p60.png \
#      -map "[abb1]" -pix_fmt yuv420p -f rawvideo xil_dec_scale_720p30.jpeg \
#      -map "[b1]"   -pix_fmt yuv420p -f rawvideo xil_dec_scale_480p30.jpg \
#      -map "[c1]"   -pix_fmt yuv420p -f rawvideo xil_dec_scale_360p30.gif \
#      -map "[d1]"   -pix_fmt yuv420p -f rawvideo xil_dec_scale_288p30.png
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