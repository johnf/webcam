#!/bin/sh

RESOLUTION=1600x1200
V4L=/dev/video0

FFSERVER=`pgrep -x ffserver`
FFCLIENT=`pgrep -x ffmpeg`
TUNNEL6=`pgrep -f 6tunnel.\*8081`

if [ "x$FFCLIENT" != x ]; then
  echo "ffmpeg client running as $FFCLIENT, please stop."
  exit 1
fi

if [ "x$FFSERVER" != x ]; then
  echo "ffserver running at $FFSERVER, killing."
  kill -9 $FFSERVER
fi
echo "ffserver starting"
ffserver

sleep 5

if [ "x$TUNNEL6" != x ]; then
  echo "6tunnel running at $TUNNEL6, killing."
  kill -9 $TUNNEL6
fi
echo "6tunnel starting"
6tunnel -6 8080 -4 127.0.0.1 8081

echo
echo

sleep 1;
ffmpeg -s $RESOLUTION -f video4linux2 -i $V4L http://localhost:8081/webcam.ffm
