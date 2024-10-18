# Use a Debian base image for the specified architecture
FROM debian:latest

# Install necessary packages for building, emulating, and serving files
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    git \
    fdisk \
    build-essential \
    binfmt-support \
    qemu-user-static \
    cmake \
    libjson-c-dev \
    libwebsockets-dev \
    libssl-dev \
    nginx \
    wget \
    python3 \
    unzip \
    zip \
    debootstrap \
    cpio \
    binwalk \
    pcregrep \
    kmod \
    pv \
    lz4 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone the shimboot repository
RUN git clone https://github.com/ading2210/shimboot.git /tmp/shimboot

# Install ttyd from its GitHub repository
RUN git clone https://github.com/tsl0922/ttyd.git /tmp/ttyd && \
    cd /tmp/ttyd && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install

# Create a directory for the built images and configure nginx
RUN mkdir -p /tmp/shimboot/images && \
    echo "server { listen 80; root /tmp/shimboot/images; autoindex on; }" > /etc/nginx/sites-available/default && \
    [ -L /etc/nginx/sites-enabled/default ] || ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Set the working directory
WORKDIR /tmp/shimboot

# Expose the ports for ttyd and nginx
EXPOSE 10000 80

# Start Nginx in the background and then execute the build process
CMD bash -c "service nginx start && ttyd -p 10000 /bin/bash -c './build_complete.sh octopus desktop=xfce && cp data/shimboot_octopus.bin /tmp/shimboot/images/ && tar -cvzf /tmp/shimboot/images/octopus_image.tar.gz -C /tmp/shimboot/images shimboot_octopus.bin'"
