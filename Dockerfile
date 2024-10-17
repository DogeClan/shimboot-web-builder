# Use a Debian base image
FROM debian:latest

# Install necessary packages for building and emulating
RUN apt-get update && \
    apt-get install -y \
    git \
    build-essential \
    binfmt-support \
    qemu-user-static \
    cmake \
    libjson-c-dev \
    libwebsockets-dev \
    libssl-dev \
    && apt-get clean

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

# Set the working directory
WORKDIR /opt/shimboot

# Expose the port ttyd will run on
EXPOSE 10000

# Start ttyd on port 10000 and execute the shimboot build command
CMD ["bash", "-c", "ttyd -p 10000 bash -c './build_complete.sh vorticon desktop=lxde'"]
