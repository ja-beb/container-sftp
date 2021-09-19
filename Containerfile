FROM alpine:latest as base
LABEL Maintainer="sean bourg <sean.bourg@gmail.com>"

ARG VERSION=system

ENV VERSION="${VERSION}"

# Import required files/folders
COPY files/ /root

RUN apk update; \
    apk upgrade; \
    apk add openssh; \
    chmod +x /root/entrypoint.sh; 

EXPOSE 22

ENTRYPOINT ["/root/entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D"]
