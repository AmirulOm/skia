# Building skottie_tool
FROM debian:bullseye-slim as builder

RUN DEBIAN_FRONTEND=noninteractive apt update && apt dist-upgrade -yy
RUN DEBIAN_FRONTEND=noninteractive apt install -yy lsb-release python-is-python3 ninja-build build-essential git sudo 

COPY . /build
WORKDIR /build

# ignore error for emdks for mac/arm builds
RUN python tools/git-sync-deps || :
RUN sed -i 's/install $PACKAGES/install $PACKAGES -yy/g' tools/install_dependencies.sh
RUN tools/install_dependencies.sh

RUN bin/gn gen out/Docker
RUN ninja -C out/Docker/ -j $(nproc) skottie_tool

# multi-stage build
FROM debian:bullseye-slim
COPY --from=builder /build/out/Docker/skottie_tool /usr/local/bin/skottie_tool

RUN DEBIAN_FRONTEND=noninteractive apt update && apt dist-upgrade -yy
RUN DEBIAN_FRONTEND=noninteractive apt install -yy freeglut3-dev libfontconfig-dev libfreetype6-dev libgif-dev libgl1-mesa-dev libglu1-mesa-dev libharfbuzz-dev libicu-dev libjpeg-dev libpng-dev libwebp-dev


ENTRYPOINT ["skottie_tool"]