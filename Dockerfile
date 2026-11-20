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

# Copying files from node
COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/local/lib/node_modules /usr/lib/node_modules

# Public key has been downloaded using
#   curl -fsSL https://download.eclipse.org/zenoh/debian-repo/zenoh-public-key | gpg --dearmor --yes --output ./files/zenoh-public-key.gpg
# on October 31st, 2026
COPY ./files/zenoh-public-key.gpg /etc/apt/keyrings/zenoh-public-key.gpg

# Copy APT configuration files
COPY ./files/99parallel /etc/apt/apt.conf.d/99parallel

# Installing Packages
RUN mkdir -p /etc/apt/keyrings \
    && echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/zenoh-public-key.gpg] https://download.eclipse.org/zenoh/debian-repo/ /" > /etc/apt/sources.list.d/zenoh.list \
    && echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/umrt.asc] https://raw.githubusercontent.com/UMRoboticsTeam/umrt-apt-repo/main/ humble main" > /etc/apt/sources.list.d/umrt_source.list \
    && echo '#!/bin/sh\nexit 0' > /usr/local/bin/systemctl && chmod +x /usr/local/bin/systemctl
    
RUN --mount=type=secret,id=apt_auth_conf,target=/etc/apt/auth.conf.d/umrt.conf \
    --mount=type=secret,id=apt_pubkey,target=/etc/apt/keyrings/umrt.asc,mode=0644 \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
        iputils-ping \
	less \
	nano \
	ros-humble-ffmpeg-image-transport \
	ros-humble-ffmpeg-image-transport-msgs \
	ros-humble-foxglove-bridge \
	ros-humble-foxglove-compressed-video-transport \
	ros-humble-foxglove-msgs \
	ros-humble-image-transport \
	ros-humble-image-transport-plugins \
	ros-humble-joy \
	ros-humble-joy-teleop \
	ros-humble-network-bridge \
	ros-humble-rviz2 \
	ros-humble-teleop-twist-joy \
	#ros-humble-umrt-arm-joystick-operator=2.1.0-0jammy \
	ros-humble-umrt-arm-ros-firmware \
	ros-humble-usb-cam \
	ros-humble-vision-msgs \
	zenoh-bridge-ros2dds=1.3.4 \
     && rm -rf /var/lib/apt/lists/* \
     && rm -f /etc/apt/sources.list.d/umrt_source.list \
     && rm -f /etc/apt/sources.list.d/*
     
COPY umrt_entrypoint.sh /umrt_entrypoint.sh
RUN chmod +x /umrt_entrypoint.sh

ENTRYPOINT ["/umrt_entrypoint.sh"]
