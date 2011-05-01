#! /bin/sh

# Get the dependencies.
sudo apt-get remove -y ffmpeg x264 libx264-dev lame-ffmpeg
sudo apt-get update
sudo apt-get install build-essential git-core checkinstall yasm texi2html libfaac-dev \
    libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev \
    libvorbis-dev libx11-dev libxfixes-dev libxvidcore-dev zlib1g-dev

mkdir ~/ffmpeg-build

# Get x264
cd ~/ffmpeg-build
if [ ! -x x264 ]; then
	git clone git://git.videolan.org/x264
	cd x264
else
	cd x264
	git update
fi
./configure
make
sudo checkinstall --pkgname=x264 --default --pkgversion="3:$(./version.sh | \
    awk -F'[" ]' '/POINT/{print $4"+git"$5}')" --backup=no --deldoc=yes

# Get lame
sudo apt-get remove libmp3lame-dev
sudo apt-get install nasm
cd ~/ffmpeg-build
if [ ! -x lame-3.98.4 ]; then
	wget http://downloads.sourceforge.net/project/lame/lame/3.98.4/lame-3.98.4.tar.gz
	tar xzvf lame-3.98.4.tar.gz
fi
cd lame-3.98.4
./configure --enable-nasm --disable-shared
make
sudo checkinstall --pkgname=lame-ffmpeg --pkgversion="3.98.4" --backup=no --default \
    --deldoc=yes

# Get webm
cd ~/ffmpeg-build
if [ ! -x libvpx ]; then
	git clone git://review.webmproject.org/libvpx
	cd libvpx
else
	cd libvpx
	git update
fi
./configure
make
sudo checkinstall --pkgname=libvpx --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no \
    --default --deldoc=yes

FFMPEG=ffmpeg-0.7-rc1
cd ~/ffmpeg-build
if [ ! -x $FFMPEG ]; then
	wget http://www.ffmpeg.org/releases/$FFMPEG.tar.bz2
	tar -jxvf $FFMPEG.tar.bz2
fi
cd $FFMPEG
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc \
    --enable-libfaac --enable-libopencore-amrnb --enable-libopencore-amrwb \
    --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid \
    --enable-x11grab  --enable-libmp3lame --enable-libvpx
make
sudo checkinstall --pkgname=ffmpeg --pkgversion="5:$(./version.sh)" --backup=no \
    --deldoc=yes --default
hash x264 ffmpeg ffplay ffprobe
