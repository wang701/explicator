#!/bin/sh

input=$1
fn=$(basename -- "$1")
fn="${fn%.*}"

ffmpeg -loglevel warning \
  -i $1 -c copy -video_track_timescale 600 ${fn}_full.mp4
