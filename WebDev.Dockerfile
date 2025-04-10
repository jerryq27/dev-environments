# Container for the WebDev environment
FROM ubuntu:latest

# Enable colors in the container shell
ENV TERM=xterm-256color
ENV ENVIRONMENT=webdev
ENV USER_NAME=$ENVIRONMENT
ENV USER_HOME=/home/$USER_NAME

# Cleanup recommended in Docker docs best practices.
RUN apt-get update -y && \
    apt-get install -y \
        curl \
        git \
        tmux \
        neovim \
        python3 \
        python3-poetry \
        ruby-full \
        sqlite3 \
        unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -fsSL https://bun.sh/install | bash && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    \. "$HOME/.nvm/nvm.sh" && \
    nvm install --lts && \
    ln -s $(which node) /bin/node && \
    ln -s $(which npm) /bin/npm && \
    echo "Done installing system packages."

# Update default user, also create directories here since mounts in docker-compose.yml will create them as root
RUN usermod --login $USER_NAME ubuntu && \
    groupmod --new-name $USER_NAME ubuntu && \
    usermod --home $USER_HOME --move-home $USER_NAME && \
    mkdir --parents \
        $USER_HOME/.local/bin \
        $USER_HOME/.cache &&\
    mv $HOME/.nvm $USER_HOME/ && \
    mv $HOME/.bun $USER_HOME/ && \
    echo "Done updating user."

ENV PATH="$PATH:$USER_HOME/.bun/bin"

COPY ./configs/bash/.bashrc $USER_HOME/.bashrc
COPY ./configs/bash/.profile $USER_HOME/.profile

RUN chown --recursive $USER_NAME:$USER_NAME $USER_HOME --verbose

# Set the working directory in the container
WORKDIR $USER_HOME

USER $USER_NAME

