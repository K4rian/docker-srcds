FROM k4rian/steamcmd:latest

LABEL maintainer="contact@k4rian.com"

# Half-Life 2: Deathmatch
ENV APPID 232370
ENV APPNAME hl2mp

COPY --chown=steam ./container_files /home/steam/gameserver
# Docker >=18.09.0:
#COPY --chown=$USERNAME ./container_files $SERVERDIR

WORKDIR $SERVERDIR

RUN chmod 755 *.sh

# SFTP
ENV SFTP_ENABLE 0
ENV SFTP_PWD NONE
ENV SFTP_PORT 50451
ENV SFTP_MAX_AUTH_TRIES 3
ENV SFTP_MAX_SESSIONS 1

USER root

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        sudo=1.8.27-1+deb10u1 \
        openssh-server=1:7.9p1-10+deb10u1 \
    && chown -R $USERNAME /etc/ssh \
    && { echo "${USERNAME}   ALL=(ALL:ALL) ALL"; \
         echo "${USERNAME}   ALL=NOPASSWD:/etc/init.d/ssh"; \
         echo "${USERNAME}   ALL=NOPASSWD:/usr/sbin/chpasswd"; \
       } >> /etc/sudoers \
    && service sudo restart

USER $USERNAME

ENTRYPOINT ["./srcds_launcher.sh"]