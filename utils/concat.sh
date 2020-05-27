#!/bin/sh

fn=$1

ffmpeg -f concat -i list -c copy ${fn}.mp4
