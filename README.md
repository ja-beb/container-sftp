# Container SFTP

Container for a small Alpine linux sftp server. Useful for developing and testing projects that need access to resources via SFTP.

## Building Contianer

Building the container should is straight forward. Just invoke either the podman build or docker build command.

```
$ podman build --rm -t sftp-server -f ./Containerfile .
```

## Running the container.

The following command will run the SFTP container using current user's information and the optional mapping to a local directory. 

This instance is running on the non-standard port 2022 which can be mapped to any port necessary.

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

## Testing SFTP

```
$ sftp -P 2022 localhost
```