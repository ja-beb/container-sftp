FROM alpine:latest as build0
LABEL Maintainer="sean bourg <sean.bourg@gmail.com>"

# Import required files/folders
# COPY config /etc/ssh/sshd_config
# COPY ssh-keys /etc/ssh/keys
COPY container-entrypoint.sh /entrypoint.sh

RUN apk update; \
    apk upgrade; \
    apk add openssh; \
    chmod +x /entrypoint.sh; \
    ssh-keygen -A

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D"]
