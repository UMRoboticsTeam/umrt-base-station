echo [INFO - $(date +"%b %d %T")] Starting UMRT Basestation

echo [INFO - $(data +"%b %d %T")] Launching Zenoh Stack
exec /workspace/umrt-network-bridge-tests/scripts/run_zenoh_stack.sh base

echo [INFO - $(date +"%b %d %T")] Sourcing ros_entrypoint.sh
source /ros_entrypoint.sh

echo [INFO - $(date +"%b %d %T")] Launching Arm Fireware
ros2 launch umrt-arm-firmware-lib joy.launch.py
