
# Demo for SmartNIC

## Intro

- super resolution 4k

  - to get better quality 


- transcoding & multiscaling

  - to check how fast and cpu offload comparing softlib(libx264) and U30

## Test

### 1. SR(Super Resolution) 4k

```
$ bash demo_4k.sh /app/input/iu.mp4 640x360 /app/output_sr 1 1 1 0 1

# 결과물 확인
$ ls -alht ../output_sr
```

#### execute below in order
  1. create container
  2. show container list
  3. upscale 4k without sr
  4. upscale 4k with sr
  5. stack 2 videos horizontally
  6. you can play results of "5."

#### argumetns in order
  - $1 : input 파일
  - $2 : input 해상도
  - $3 : output 디렉토리
  - $4 : 컨테이너 생성부터?
  - $5 : sr 없이 upscale?
  - $6 : sr 같이 upscale?
  - $7 : 영상 수평으로 붙일?
  - $8 : 단계 별 enter 입력 요청?

### 2. Transcoding & Multiscaling

```
# with softlib(libx264)
$ bash demo_transcode.sh input/iu.mp4 output_tr 1

# with ? on u30
$ bash demo_transcode_u30.sh input/iu.mp4 output_tr 1
```

#### execute below in order
  1. create container
  2. show container list
  3. upscale 4k without sr
  4. upscale 4k with sr
  5. stack 2 videos horizontally