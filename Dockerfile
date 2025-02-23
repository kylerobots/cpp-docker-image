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

# Download a specific LLVM version to /opt/llvm and update the PATH.
ARG LLVM_VERSION=19.1.7
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    xz-utils \
    && curl -sSL "https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/LLVM-${LLVM_VERSION}-Linux-X64.tar.xz" -O \
    && tar xf LLVM-${LLVM_VERSION}-Linux-X64.tar.xz \
    && mv LLVM-${LLVM_VERSION}-Linux-X64 /opt/llvm \
    && rm LLVM-${LLVM_VERSION}-Linux-X64.tar.xz \
    && apt-get purge -y \
    curl \
    xz-utils \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
ENV PATH="$PATH:/opt/llvm/bin"

# Create a non-root user with sudo
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# 23.04 and onward introduces a non-root user called ubuntu that already uses
# the default UID. Delete it. One could just specify a different UID for the
# new user, but it causes issues when mounting WSL files/folders.
RUN userdel -r ubuntu \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*
USER $USERNAME
