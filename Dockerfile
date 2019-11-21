FROM k4rian/steamcmd:latest

LABEL maintainer="contact@k4rian.com"

ENV USERNAME steam
ENV SERVERDIR /home/steam/gameserver

# Half-Life 2: Deathmatch
ENV APPID 232370
ENV APPNAME hl2mp

COPY --chown=$USERNAME ./container_files $SERVERDIR

WORKDIR $SERVERDIR

RUN chmod 755 srcds_launcher.sh

ENTRYPOINT ["./srcds_launcher.sh"]