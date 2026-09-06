FROM ros:humble-ros-base

ENV ROS_DOMAIN_ID=0
ENV ROS_LOCALHOST_ONLY=0
ENV RMW_IMPLEMENTATION="rmw_fastrtps_cpp" 

RUN echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/umrt.asc] https://raw.githubusercontent.com/UMRoboticsTeam/umrt-apt-repo/main/ humble main" > /etc/apt/sources.list.d/umrt_source.list


RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.eclipse.org/zenoh/debian-repo/zenoh-public-key | gpg --dearmor --yes --output /etc/apt/keyrings/zenoh-public-key.gpg \
    && cat /etc/apt/keyrings/zenoh-public-key.gpg
    && echo "deb [signed-by=/etc/apt/keyrings/zenoh-public-key.gpg] https://download.eclipse.org/zenoh/debian-repo/ /" > /etc/apt/sources.list.d/zenoh.list

RUN --mount=type=secret,id=apt_auth_conf,target=/etc/apt/auth.conf.d/umrt.conf \
    --mount=type=secret,id=apt_pubkey,target=/etc/apt/keyrings/umrt.asc,mode=0644 \
    set -e \
    && echo '#!/bin/sh\nextit 0' > /usr/bin/systemctl \
    && chmod =X /usr/bin/systemctl \
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
        zenoh-plugin-ros2dds \
    && rm -rf /var/lib/apt/lists/*

RUN bash -c "set -e && npm install -g tileserver-gl-light"

RUN sudo rm -f /etc/apt/sources.list.d/umrt_source.list

RUN sudo rm -f /var/lib/apt/lists/*

RUN BRIDGE_WORKSPACE=$(which zenoh-plugin-ros2dds) 

COPY umrt_entrypoint.sh /umrt_entrypoint.sh
RUN chmod +x /umrt_entrypoint.sh

ENTRYPOINT ["/umrt_entrypoint.sh"]
