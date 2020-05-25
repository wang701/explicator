#!/bin/bash

fn=$1 # first argument is the JSON label file

# text overlay
jq -r '.[] | .video + " " + .label' $fn | while read -r row; do
  vid_path=$(cut -d " " -f1 <<< "$row")
  label=$(cut -d " " -f2,3 <<< "$row")
  vid=$(basename $vid_path)
  vid_name="${vid%.*}"

  ffmpeg -y -i $vid -vf \
    drawtext="text='${label}': \
              fontcolor=white: \
              fontsize=24: \
              box=1: \
              boxcolor=black@0.5: \
              boxborderw=5: \
              x=0: y=text_h" \
              -codec:a copy ${vid_name}_txt.mp4
done

# merge all clips
#for f in *_txt.mp4 ; do echo file \'$f\' >> list.txt; done && ffmpeg -f concat
#  -safe 0 -i list.txt -c copy left_2019-07-15_19-15-00_labeled.mp4 && rm
#  list.txt
