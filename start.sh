#!/bin/bash

MAPTILES_DIR="../maptiles"

if [ ! -d "$MAPTILES_DIR" ]; then
  echo "Directory $MAPTILES_DIR does not exist. Creating new folder"
  mkdir -p "$MAPTILES_DIR"
fi

docker run \
  --rm \
  -it \
  --name umrt-base-station \
  -v "$(realpath $MAPTILES_DIR)":/maptiles:ro \
  --net=host \
  --entrypoint /bin/bash \
  umrt-base-station