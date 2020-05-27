#!/bin/sh

input=$1
duration=$2

ffmpeg -i $1 -vf trim=0:$2,geq=0:128:128 -af atrim=0:$2,volume=0 \
  -video_track_timescale 600 $2sec.mp4
