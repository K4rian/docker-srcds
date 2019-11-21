FROM k4rian/steamcmd:latest

LABEL maintainer="contact@k4rian.com"

# Half-Life 2: Deathmatch
ENV APPID 232370
ENV APPNAME hl2mp

COPY --chown=$USERNAME ./container_files $SERVERDIR

WORKDIR $SERVERDIR

RUN chmod 755 srcds_launcher.sh

ENTRYPOINT ["./srcds_launcher.sh"]