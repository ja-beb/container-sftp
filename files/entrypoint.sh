#!/bin/sh
# 
# Inital run for the SFTP docker container. 
# Responsible for creating user account with the proper UID/GID, 
# setting a random password and adding authorized keys.
#
if [ -z "${SFTP_USERNAME}" ]
then
  SFTP_USERNAME='SFTP'
fi

if [ -z "${SFTP_PASSWORD}" ]
then
    apk add pwgen
    SFTP_PASSWORD=$(pwgen  -s1 32)
fi

# Set default UID & GID
KEY_SOURCE=""
SFTP_UID=$([[ -z "${SFTP_UID}" ]] && echo '1000' || echo "${SFTP_UID}")
SFTP_GID=$([[ -z "${SFTP_GID}" ]] && echo '1000' || echo "${SFTP_GID}")

# Add user
addgroup -g ${SFTP_GID} ${SFTP_USERNAME} 
adduser -G ${SFTP_USERNAME} -D -u ${SFTP_UID} ${SFTP_USERNAME}

echo "${SFTP_USERNAME}:$SFTP_PASSWORD" | chpasswd  > /dev/null  2>&1 

# Add ssh key
mkdir -p "/home/${SFTP_USERNAME}/.ssh" 

# Add authorized keys if present
if [ -z "${SFTP_AUTHORIZED_KEYS}" ];
then
    SFTP_AUTHORIZED_KEYS='Off'
else
    echo "${SFTP_AUTHORIZED_KEYS}" > "/home/${SFTP_USERNAME}/.ssh/authorized_keys"   
    SFTP_AUTHORIZED_KEYS='On'
fi

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

echo ""
echo -e '\e[32m'
echo '========================================'       
echo 'SFTP Server Started'
echo "USERNAME_______: ${SFTP_USERNAME}"
echo "PASSWORD_______: ${SFTP_PASSWORD}"
echo "UID/GID________: ${SFTP_UID}:${SFTP_GID}"
echo "AUTHORIZED_KEYS: ${SFTP_AUTHORIZED_KEYS}"
echo "SSL KEYS_______: ${KEY_SOURCE}"
for keyfile in $(find /etc/ssh/keys -type f ! -name *.pub 2> /dev/null)
do
    echo "                 * ${keyfile}"
done
echo '========================================'       
echo -e '\e[39m' 
echo ""  

unset SFTP_PASSWORD 
unset SFTP_AUTHORIZED_KEYS

# Execute the CMD from the Dockerfile:
exec "$@"