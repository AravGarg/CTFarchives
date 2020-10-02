#!/bin/sh
set -e

docker build -t mcu-builder .
docker run --rm --mount type=bind,source="$(pwd)"/,destination=/build mcu-builder sh -c "cd /build; ./build.sh"
