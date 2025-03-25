# Container for the LowLevelDev environment
FROM ubuntu:latest

# Enable colors in the container shell
ENV TERM=xterm-256color
ENV ENVIRONMENT=lowleveldev

ENV USER_NAME=$ENVIRONMENT
ENV USER_HOME=/home/$USER_NAME
ENV HOME=$USER_HOME

# Cleanup recommended in Docker docs best practices.
RUN apt-get update -y && \
    apt-get install -y \
        curl \
        git \
        tmux \
        unzip \
        python3 \
        python3-poetry \
        build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "Done installing system packages."

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

# Zig
# Arduino?

# Free up UID 1000 and create dev user
# Also Create directories here since mounts in docker-compose.yml will create them as root
RUN userdel ubuntu && \
    useradd \
        --create-home \
        --user-group \
        --uid 1000 \
        --shell /bin/bash \
        --no-log-init \
        $USER_NAME && \
    mkdir --parents $USER_HOME/.local/bin && \
    echo "Done setting up $ENVIRONMENT Home."

COPY ./configs/bash/bashrc $USER_HOME/.bashrc
COPY ./configs/bash/profile $USER_HOME/.profile

ENV PATH="$USER_HOME/.cargo/bin:$PATH"

RUN chown --recursive $USER_NAME:$USER_NAME $USER_HOME

# Set the working directory in the container
WORKDIR $USER_HOME

USER $USER_NAME

