### Exemple

FROM multiarch/debian-debootstrap:arm64-stretch-slim

ENV ARCH arm64
ENV S6OVERLAY_RELEASE https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-aarch64.tar.gz

COPY install.sh /usr/local/bin/install.sh
COPY VERSION /etc/docker-pi-hole-version
ENV PIHOLE_INSTALL /root/ph_install.sh

RUN bash -ex install.sh 2>&1 && \
    rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

ENTRYPOINT [ "/s6-init" ]

ADD s6/debian-root /
COPY s6/service /usr/local/bin/service

# php config start passes special ENVs into
ENV PHP_ENV_CONFIG '/etc/lighttpd/conf-enabled/15-fastcgi-php.conf'
ENV PHP_ERROR_LOG '/var/log/lighttpd/error.log'
COPY ./start.sh /
COPY ./bash_functions.sh /

# IPv6 disable flag for networks/devices that do not support it
ENV IPv6 True

EXPOSE 53 53/udp
EXPOSE 67/udp
EXPOSE 80
EXPOSE 443

ENV S6_LOGGING 0
ENV S6_KEEP_ENV 1
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

ENV ServerIP 0.0.0.0
ENV FTL_CMD no-daemon
ENV DNSMASQ_USER root

ENV VERSION v5.0
ENV PATH /opt/pihole:${PATH}

LABEL image="pihole/pihole:v5.0_arm64"
LABEL maintainer="adam@diginc.us"
LABEL url="https://www.github.com/pi-hole/docker-pi-hole"

HEALTHCHECK CMD dig +norecurse +retry=0 @127.0.0.1 pi.hole || exit 1

SHELL ["/bin/bash", "-c"]
