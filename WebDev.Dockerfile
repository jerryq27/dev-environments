# Container for the WebDev environment
FROM ubuntu:latest

# Enable colors in the container shell
ENV TERM=xterm-256color
ENV ENVIRONMENT=webdev

ENV USER_NAME=$ENVIRONMENT
ENV USER_HOME=/home/$USER_NAME
ENV HOME=$USER_HOME

ENV NODE_VERSION=22
ENV BUN_LOCATION=$USER_HOME/.bun
ENV NVM_LOCATION=$USER_HOME/.nvm

# Cleanup recommended in Docker docs best practices.
RUN apt-get update -y && \
    apt-get install -y \
        curl \
        git \
        tmux \
        unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "Done installing system packages."

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

# Install Node and Bun
RUN curl -fsSL https://bun.sh/install | bash && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    # Source nvm
    . $NVM_LOCATION/nvm.sh && \
    nvm install $NODE_VERSION && \
    # Source nvm again after install
    . $NVM_LOCATION/nvm.sh && \
    ln -s $BUN_LOCATION/bin/bun $USER_HOME/.local/bin/bun && \
    ln -s $(nvm which node) $USER_HOME/.local/bin/node && \
    ln -s $NVM_LOCATION/versions/node/$(node -v)/bin/npm $USER_HOME/.local/bin/npm && \
    ln -s $NVM_LOCATION/versions/node/$(node -v)/bin/npx $USER_HOME/.local/bin/npx && \
    # ln -s $(nvm which npm) $USER_HOME/.local/bin/npm && \
    # ln -s $(nvm which npx) $USER_HOME/.local/bin/npx && \
    echo "Done installing $ENVIRONMENT packages."

COPY ./configs/bash/bashrc $USER_HOME/.bashrc
COPY ./configs/bash/profile $USER_HOME/.profile

ENV PATH="$USER_HOME/.local/bin:$PATH"

RUN chown --recursive $USER_NAME:$USER_NAME $USER_HOME

# Set the working directory in the container
WORKDIR $USER_HOME

USER $USER_NAME

