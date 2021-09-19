#!/bin/sh
# 
# Inital run for the SFTP docker container. 
# Responsible for creating user account with the proper UID/GID, setting a random password, adding authorized keys, and generating SSH keys.

## Set variables to default values if not present
SFTP_USERNAME$([[ -z "${SFTP_USERNAME}" ]] && echo 'sftp' || echo "${SFTP_USERNAME}")
SFTP_UID=$([[ -z "${SFTP_UID}" ]] && echo '1000' || echo "${SFTP_UID}")
SFTP_GID=$([[ -z "${SFTP_GID}" ]] && echo '1000' || echo "${SFTP_GID}")
if [ -z "${SFTP_PASSWORD}" ]
then
    apk add pwgen
    SFTP_PASSWORD=$(pwgen  -s1 32)
fi

# Add group, user and set password.
addgroup -g ${SFTP_GID} ${SFTP_USERNAME} 
adduser -G ${SFTP_USERNAME} -D -u ${SFTP_UID} ${SFTP_USERNAME}
echo "${SFTP_USERNAME}:$SFTP_PASSWORD" | chpasswd  > /dev/null  2>&1 

# Add ssh key
mkdir -p "/home/${SFTP_USERNAME}/.ssh" 

## Add authorized keys if present
if [ -z "${SFTP_AUTHORIZED_KEYS}" ];
then
    SFTP_AUTHORIZED_KEYS='Off'
else
    echo "${SFTP_AUTHORIZED_KEYS}" > "/home/${SFTP_USERNAME}/.ssh/authorized_keys"   
    SFTP_AUTHORIZED_KEYS='On'
fi

## Configure SSHD: generate keys or import user provided keys.
if [ -n "$(ls /root/ssh-keys/* 2> /dev/null)" ]
then
    KEY_SOURCE="User Provided"
    cp /root/config /etc/ssh/sshd_config 
    cp -R /root/ssh-keys /etc/ssh/keys
    chmod 400 /etc/ssh/keys/*

    # append keys to config file
    for keyfile in $(find /etc/ssh/keys -type f ! -name *.pub)
    do
        echo "HostKey ${keyfile}" >> /etc/ssh/sshd_config
    done
else
    KEY_SOURCE="System Generate"
    ssh-keygen -A
fi


## Display configuration details.
echo ""
echo -e '\e[32m'
echo '========================================'       
echo 'SFTP Server Started'
echo "USERNAME_______: ${SFTP_USERNAME}"
echo "PASSWORD_______: ${SFTP_PASSWORD}"
echo "UID/GID________: ${SFTP_UID}:${SFTP_GID}"
echo "AUTHORIZED_KEYS: ${SFTP_AUTHORIZED_KEYS}"
echo "SSL KEYS_______: ${KEY_SOURCE}"

if [ "User Provided" == "${KEY_SOURCE}" ]
then
    for keyfile in $(find /etc/ssh/keys -type f ! -name *.pub 2> /dev/null)
    do
        echo "                 * ${keyfile}"
    done
fi
echo '========================================'       
echo -e '\e[39m' 
echo ""  

## Unset sensitive variables.
unset SFTP_PASSWORD 
unset SFTP_AUTHORIZED_KEYS

## Execute the CMD from the Dockerfile.
exec "$@"