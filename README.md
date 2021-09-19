# Container SFTP

Container for a small Alpine linux sftp server. Useful for developing and testing projects that need access to resources via SFTP.

## Generate keys
To provide SSL keys to the container create a folder at the location files/ssh-keys and place the keys there. The following code segment creates the folder and generates both RSSA and EdDSA SHA-2 keys.

```
$ mkdir files/ssh-keys
$ ssh-keygen -t ed25519 -f files/ssh-keys/ssh_host-ed25519_key < /dev/null
$ ssh-keygen -t rsa -b 4096 -f files/ssh-keys/ssh_host-rsa_key < /dev/null
```

## Using Container with Podman 

### Building the Contianer

Building the container should is straight forward. Just invoke either the podman build or docker build command.

```
$ podman build --rm -t sftp-server -f ./Containerfile .
```

### Running the container.

The following command will run the SFTP container on port 2022 using current user's information and the optional mapping to a local directory. 

```
$ AUTHORIZED_KEYS=$(cat ~/.ssh/id_rsa.pub) 
$ podman run -p 2022:22 --name "sftp-server" \
    -e SFTP_AUTHORIZED_KEYS="${AUTHORIZED_KEYS}" \
    -e SFTP_USERNAME="${USER}" \
    -e SFTP_UID=$(id -u) \
    -e SFTP_GID=$(id -g) \
    -v ./local:"/home/${SFTP_USERNAME}" \
    "sftp-server-instance" 
```

## Using the Container with Docker & Docker Compose

### Building the Container

The provided file `docker.env` uses current user information to create the docker image. You can modify these values if necessary.

```
$ set -a
$ source docker.env
$ docker-compose build
$ docker-compuse up -d
```
