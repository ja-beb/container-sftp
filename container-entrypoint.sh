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

echo ""
echo -e '\e[32m'
echo '========================================'       
echo 'SFTP Server Started'
echo "USERNAME_______: ${SFTP_USERNAME}"
echo "PASSWORD_______: ${SFTP_PASSWORD}"
echo "UID/GID________: ${SFTP_UID}:${SFTP_GID}"
echo "AUTHORIZED_KEYS: ${SFTP_AUTHORIZED_KEYS}"
echo '========================================'       
echo -e '\e[39m' 
echo ""  

unset SFTP_PASSWORD 
unset SFTP_AUTHORIZED_KEYS

# Execute the CMD from the Dockerfile:
exec "$@"