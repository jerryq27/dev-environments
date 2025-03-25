# Portable Dev Environments

I enjoy playing around with a variety of tools and languages. Installing packages on multiple machines
became a pain, so I learned Docker to utilize containers and create images with the those packages. This
keeps my machines clean and gives me a portable setup for development.

So now I just follow these steps with every project:

1. Create/Use a Dockerfile to create an image with all the necessary packages
1. Create a `docker-compose.yml` file in the project directory that uses the image
1. Add project-specific settings in the compose file (ports, volumes, etc.)


## Creating a Dockerfile & Building the Image

> These are just rules and naming conventions I set for myself to follow

The Dockerfiles are meant to be generic for a development environment. That's why I start from an Ubuntu image,
and install the appropriate packages there. Why not start from something like `node:latest`? Maybe I want to use
Yarn, Bun, etc. or all of them at the same time. It's just much easier to start from a bare bones Ubuntu image.

Things to keep in mind with writing the Dockerfile:

1. All commands are ran as `root` and files created will be owned by `root`
1. Note where packages install things and which envnironment variables they use
1. Create a new user with a `$UID:$GID` that matches the host system user's `$UID:$GID`
1. Update `$PATH` or link package binaries to the new user's `.local/bin/` directory
1. Copy any user-specific configuration files (like `.bashrc`) into the new user's Home
1. Ensure `$PATH` includes that directory through the Dockerfile or something like `.profile`
1. Make sure the new user is the owner of their Home directory
1. Switch from root to the new user

The image name follows the format `env_$ENVIRONMENT`, for example `env_webdev`.

Building the image:

```sh
docker build -t $ENV_NAME:$VERSION -f $DOCKERFILE .
```

## Creating the Compose file

Each project will have a `docker-compose.yml` file for project-specifc settings.

Things to keep in mind with writing the compose file:

1. Container name is prefixed with `project_` or `work_`
1. Use locally built image with `pull_policy: missing`
1. Ensure I can drop into a bash session with `stdin_open: true` and `tty: true`
1. Copy project files into the user's Home folder

Bare minimum compose file:
```yml
services:
  $PROJECT:
    container_name: project_$PROJECT
    image: env_$IMAGE
    pull_policy: missing
    stdin_open: true
    tty: true
    volumes:
      - ./:/home/$USER/app/
```

Running the container:

```sh
docker compose up -d
docker exec -it $CONTAINER_NAME bash --login 
```

> Running `bash --login` in the container ensures that something like `.bashrc` gets sourced.

