FROM ros:humble-ros-base

ENV ROS_DOMAIN_ID=0
ENV ROS_LOCALHOST_ONLY=0
ENV RMW_IMPLEMENTATION="rmw_fastrtps_cpp" 
ENV BRIDGE_WORKSPACE="/usr"

RUN apt-get update && apt-get install -y --no-install-recommends \
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN set -x && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ZENOH_ARCH="x86_64-unknown-linux-gnu"; \
    elif [ "$ARCH" = "aarch64" ]; then ZENOH_ARCH="aarch64-unknown-linux-gnu"; \
    fi \
    && echo "$ARCH" \
    && echo "$ZENOH_ARCH" \ 
    && curl -fsSL -o /tmp/zenoh-bridge.zip "https://eclipse.org${ZENOH_ARCH}.zip" \
    && unzip /tmp/zenoh-bridge.zip -d /usr/bin/ \
    && chmod +x /usr/bin/zenoh-bridge-ros2dds \
    && rm -rf /tmp/zenoh-bridge.zip

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

RUN sudo rm -f /var/lib/apt/lists/*

COPY umrt_entrypoint.sh /umrt_entrypoint.sh
RUN chmod +x /umrt_entrypoint.sh

ENTRYPOINT ["/umrt_entrypoint.sh"]
