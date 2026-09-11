#######################################
# STAGE 1: The Build Cache and NPM
#######################################
FROM docker.io/library/node:20-slim AS builder

RUN npm install -g --production tileserver-gl-light \
    && npm cache clean --force
    
#######################################
# STAGE 2: The Final Export
#######################################
FROM ros:humble-ros-base

ENV ROS_DOMAIN_ID=0
ENV ROS_LOCALHOST_ONLY=0
ENV RMW_IMPLEMENTATION="rmw_fastrtps_cpp" 
ENV BRIDGE_WORKSPACE="/workspace/umrt-zenoh-bridge"

COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/local/lib/node_modules /usr/lib/node_modules

RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.eclipse.org/zenoh/debian-repo/zenoh-public-key | gpg --dearmor --yes --output /etc/apt/keyrings/zenoh-public-key.gpg \
    && echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/zenoh-public-key.gpg] https://download.eclipse.org/zenoh/debian-repo/ /" > /etc/apt/sources.list.d/zenoh.list \
    && echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/umrt.asc] https://raw.githubusercontent.com/UMRoboticsTeam/umrt-apt-repo/main/ humble main" > /etc/apt/sources.list.d/umrt_source.list \
    && echo '#!/bin/sh\nexit 0' > /usr/local/bin/systemctl && chmod +x /usr/local/bin/systemctl \
    && echo 'Acquire::Queue-Mode "host";' > /etc/apt/apt.conf.d/99parallel \
    && echo 'Acquire::http::Pipeline-Depth "5";' >> /etc/apt/apt.conf.d/99parallel
    
RUN --mount=type=secret,id=apt_auth_conf,target=/etc/apt/auth.conf.d/umrt.conf \
    --mount=type=secret,id=apt_pubkey,target=/etc/apt/keyrings/umrt.asc,mode=0644 \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
        less nano iputils-ping ros-humble-rviz2 \
        ros-humble-joy ros-humble-joy-teleop ros-humble-teleop-twist-joy \
        #ros-humble-umrt-arm-joystick-operator=2.1.0-0jammy \
        ros-humble-foxglove-bridge ros-humble-foxglove-msgs \
        ros-humble-foxglove-compressed-video-transport ros-humble-network-bridge ros-humble-usb-cam ros-humble-vision-msgs \
        ros-humble-image-transport ros-humble-image-transport-plugins ros-humble-ffmpeg-image-transport \
        ros-humble-ffmpeg-image-transport-msgs ros-humble-umrt-arm-ros-firmware zenoh-bridge-ros2dds=1.3.4 \ 
     && rm -rf /var/lib/apt/lists/* \
     && rm -f /etc/apt/sources.list.d/umrt_source.list
     
COPY umrt_entrypoint.sh /umrt_entrypoint.sh
COPY /tmp/joy.launch.py /opt/ros/humble/share/umrt-arm-ros-firmware/launch
RUN chmod +x /umrt_entrypoint.sh

ENTRYPOINT ["/umrt_entrypoint.sh"]
