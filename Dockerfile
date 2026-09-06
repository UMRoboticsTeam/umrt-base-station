FROM ros:humble-ros-base

RUN echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/umrt.asc] https://raw.githubusercontent.com/UMRoboticsTeam/umrt-apt-repo/main/ humble main" > /etc/apt/sources.list.d/umrt_source.list

RUN --mount=type=secret,id=apt_auth_conf,target=/etc/apt/auth.conf.d/umrt.conf \
    --mount=type=secret,id=apt_pubkey,target=/etc/apt/keyrings/umrt.asc,mode=0644 \
    set -e \
    && curl -vL https://deb.nodesource.com/setup_20.x | bash - \
    && sudo apt update && sudo apt install -y \
        less \
        nano \
        nodejs \
        iputils-ping \
        ros-humble-rviz2 \
        ros-humble-joy \
        ros-humble-joy-teleop \
        ros-humble-teleop-twist-joy \
        ros-humble-umrt-arm-joystick-operator=2.1.0-0jammy \
        ros-humble-foxglove-bridge \
        ros-humble-foxglove-msgs \
        ros-humble-foxglove-compressed-video-transport \
        ros-humble-network-bridge \
        ros-humble-usb-cam \
        ros-humble-vision-msgs \
        ros-humble-image-transport \
        ros-humble-image-transport-plugins \
        ros-humble-ffmpeg-image-transport \
        ros-humble-ffmpeg-image-transport-msgs \
        umrt-arm-firmware-lib \
    && rm -rf /var/lib/apt/lists/*

RUN bash -c "set -e && npm install -g tileserver-gl-light"

RUN sudo rm -f /etc/apt/sources.list.d/umrt_source.list
