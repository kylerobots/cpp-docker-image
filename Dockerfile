# Use just a single OS for now.
FROM ubuntu:24.04

# Use single versions of gcc and Ninja for now.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Download a specific CMake version to /opt/cmake and update the PATH.
ARG CMAKE_VERSION=3.31.5
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    software-properties-common \
    && curl -sSL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh" -O \
    && curl -sSL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-SHA-256.txt" -O \
    && sha256sum -c --ignore-missing "cmake-${CMAKE_VERSION}-SHA-256.txt" \
    && mkdir -p /opt/cmake \
    && sh "cmake-${CMAKE_VERSION}-linux-x86_64.sh" --prefix=/opt/cmake --skip-license \
    && rm cmake-${CMAKE_VERSION}-SHA-256.txt \
    && rm cmake-${CMAKE_VERSION}-linux-x86_64.sh \
    && apt-get purge -y \
    curl \
    software-properties-common \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
ENV PATH="$PATH:/opt/cmake/bin"

# Install a specific LLVM version
# ARG LLVM_VERSION=llvmorg-19.1.7
# # RUN ls /opt/cmake
# RUN git clone --depth 1 --branch ${LLVM_VERSION} https://github.com/llvm/llvm-project.git /opt/llvm \
#     && cmake -S /opt/llvm/llvm -B /opt/llvm/build -G Ninja -D CMAKE_BUILD_TYPE=Release -D LLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lldb;lld" \
# Run regression checks to make sure things work.
# && cmake --build /opt/llvm/build --target check-llvm --parallel \
# && cmake --build /opt/llvm/build --target install --parallel
