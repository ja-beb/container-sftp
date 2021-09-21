FROM alpine:latest as base
LABEL Maintainer="sean bourg <sean.bourg@gmail.com>"

COPY entrypoint.sh /entrypoint.sh
COPY ssh-files /ssh-files

RUN apk update; \
    apk upgrade; \
    apk add openssh; \
    chmod +x /entrypoint.sh; 

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]