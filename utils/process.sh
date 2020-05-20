#!/bin/sh

#################################################
#
#
# Script for batch downsizing ISOBlue HD videos
#
#
#################################################

t=600 # normal file duration
tt=1200 # corrupted file duration
fsize_min=1000000
logfile=process.log

echo "Processing begins ...\n"

for f in *.avi; do
  probe_dur=$(ffprobe -v error -show_format "$f" | grep "duration")
  probe_size=$(ffprobe -v error -show_format "$f" | grep "size")
  dur=$(echo "$probe_dur" | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')
  fsize=$(echo "$probe_size" | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')
  fn=$(echo "$f" | sed -e "s/.avi$//")
  if [ "$dur" != "" ]; then
    echo "\t$f lasts $dur seconds." | tee -a $logfile
    if [ "$dur" -ge "$t" ] && [ "$dur" -lt "$tt" ]; then # if normal
      fr=${fn}_fr.avi
      ff=${fn}_fin.mp4
      echo "\t\tReducing frame rate ..." | tee -a $logfile
      ffmpeg -y -r 30 -i $f  -r 10 $fr
      echo "\t\tDone." | tee -a $logfile
      echo "\t\tDown converting ..." | tee -a $logfile
      ffmpeg -y -i $fr -vf scale=iw/5:ih/5 $ff # down convert
      echo "\t\tDone." | tee -a $logfile
    elif [ "$dur" -ge "$tt" ]; then # if not normal
      fc=${fn}_cut.avi
      fr=${fn}_fr.avi
      ff=${fn}_fin.mp4
      echo "\t\tCutting ..." | tee -a $logfile
      ffmpeg -y -i $f -ss 00:10:00 -t 00:20:00 -async 1 $fc # cut
      echo "\t\tDone." | tee -a $logfile
      echo "\t\tReducing frame rate ..." | tee -a $logfile
      ffmpeg -y -r 30 -i $fc  -r 10 $fr
      echo "\t\tDone." | tee -a $logfile
      echo "\t\tDown converting ..." | tee -a $logfile
      ffmpeg -y -i $fr -vf scale=iw/5:ih/5 $ff # down convert
      echo "\t\tDone." | tee -a $logfile
    fi
  else
    echo "\t$f lasts N/A." | tee -a $logfile # skip single frame file
    if [ "$fsize" -gt "$fsize_min" ]; then
      fr=${fn}_fr.avi
      ff=${fn}_fin.mp4
      echo "\t\tSize meets requirement." | tee -a $logfile
      echo "\t\tReducing frame rate ..." | tee -a $logfile
      ffmpeg -y -r 30 -i $f  -r 10 $fr
      echo "\t\tDone." | tee -a $logfile
      echo "\t\tDown converting ..." | tee -a $logfile
      ffmpeg -y -i $fr -vf scale=iw/5:ih/5 $ff # down convert
      echo "\t\tDone." | tee -a $logfile
    else
      echo "\t\tSize too small. Skip."
    fi
  fi
done

echo "\nProcessing done."
