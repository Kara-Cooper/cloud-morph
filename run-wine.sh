#!/usr/bin/env bash
cd winvm
docker build -t syncwine .
docker rm -f appvm

# Sync local wine
#docker run -v ~/.wine:/rpath/wine --volume winecfg:/root/.wine syncwine bash -c 'cp -rf /rpath/wine/* /root/.wine'
#docker run -v ~/.wine:/rpath --volume winecfg:/root/.wine syncwine bash -c 'bash -c'

if [ $(uname -s) == "Darwin" ]
then
    echo "Spawn container on Mac"
    docker run -d --privileged --rm --name "appvm" \
    --mount type=bind,source="$(pwd)"/apps,target=/apps \
    --mount type=bind,source="$(pwd)"/supervisord.conf,target=/etc/supervisor/conf.d/supervisord.conf  \
    --env "apppath=$1" \
    --env "appfile=$2" \
    --env "appname=$3" \
    --env "hwkey=$4" \
    --env "screenwidth=$5" \
    --env "screenheight=$6" \
    --env "wineoptions=$7" \
    --env "vglrun=$8" \
    --env "dockerhost=host.docker.internal" \
    --env "DISPLAY=:99" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="/usr/lib/x86_64-linux-gnu/libXv.so.1:/usr/lib/x86_64-linux-gnu/libXv.so.1" \
    --volume "winecfg:/root/.wine" syncwine supervisord
else 
    echo "Spawn container on Linux"

    #xhost +local:root
    nvidia-docker run -t -d --privileged --rm --name "appvm" \
    --runtime=nvidia \
    -e XAUTHORITY -e NVIDIA_DRIVER_CAPABILITIES=all \
    --mount type=bind,source="$(pwd)"/apps,target=/apps \
    --mount type=bind,source="$(pwd)"/supervisord.conf,target=/etc/supervisor/conf.d/supervisord.conf  \
    --network=host \
    --env "apppath=$1" \
    --env "appfile=$2" \
    --env "appname=$3" \
    --env "hwkey=$4" \
    --env "screenwidth=$5" \
    --env "screenheight=$6" \
    --env "wineoptions=$7" \
    --env "vglrun=$8" \
    --env "dockerhost=127.0.0.1" \
    --env "DISPLAY=$DISPLAY" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="/usr/lib/x86_64-linux-gnu/libXv.so.1:/usr/lib/x86_64-linux-gnu/libXv.so.1" \
    --volume "winecfg:/root/.wine" syncwine supervisord
    #xhost -local:root # resetting permissions
fi


