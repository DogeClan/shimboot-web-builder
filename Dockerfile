# Use a Debian base image
FROM --platform=linux/arm64 debian:latest

# Install necessary packages for building, emulating, and serving files
RUN apt-get update && \
    apt-get install -y \
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
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone the shimboot repository
RUN git clone https://github.com/ading2210/shimboot.git /opt/shimboot

# Install ttyd from its GitHub repository
RUN git clone https://github.com/tsl0922/ttyd.git /opt/ttyd && \
    cd /opt/ttyd && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install

# Create a directory for the built images and configure nginx
RUN mkdir -p /opt/shimboot/images && \
    echo "server { listen 80; root /opt/shimboot/images; autoindex on; }" > /etc/nginx/sites-available/default

# Set the working directory
WORKDIR /opt/shimboot

# Expose the ports for ttyd and nginx
EXPOSE 10000 80

# Start Nginx in the background, and then execute the shimboot build command
CMD service nginx start && ttyd -p 10000 bash -c './build_complete.sh octopus desktop=xfce && cp /tmp/shimboot/data/shimboot_octopus.bin /tmp/shimboot/images/ && tar -cvzf /tmp/shimboot/images/octopus_image.tar.gz -C /tmp/shimboot/images shimboot_octopus.bin'
