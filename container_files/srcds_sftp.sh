#!/bin/bash

SSHD_SERVICE=/etc/init.d/ssh
SSHD_CONFIG=/etc/ssh/sshd_config
SSHD_CONFIG_BAK=$SSHD_CONFIG.bak
CHPASSWD=/usr/sbin/chpasswd

function service_started() {
  result=0
  s_status=`ps aux | grep -v grep| grep -v "$0" | grep $SSHD_SERVICE| wc -l | awk '{print $1}'`

  if [ $s_status != "0" ];
  then 
    result=1
  fi
  return $result
}

function service_start() {
  result=0

  if [ $(service_started) = 1 ];
  then 
    sudo $SSHD_SERVICE start
    result=1
  fi

  return $result
}

function service_stop() {
  result=0

  if [ $(service_started) = 1 ];
  then 
    sudo $SSHD_SERVICE stop
    result=1
  fi

  return $result
}

function service_restart() {
  sudo $SSHD_SERVICE restart
  return $(service_started)
}

function first_setup() {
    sudo $CHPASSWD <<<"$USERNAME:$SFTP_PWD"
    unset SFTP_PWD

    cp $SSHD_CONFIG $SSHD_CONFIG_BAK
    { echo "Port ${SFTP_PORT}"; \
      echo "PasswordAuthentication yes"; \
      echo "PermitRootLogin no"; \
      echo "AllowUsers ${USERNAME}"; \
      echo "ChrootDirectory /home"; \
      echo "ForceCommand internal-sftp"; \
      echo "X11Forwarding no"; \
      echo "AllowTcpForwarding no"; \
      echo "MaxAuthTries ${SFTP_MAX_AUTH_TRIES}"; \
      echo "MaxSessions ${SFTP_MAX_SESSIONS}"; \
      echo "ChallengeResponseAuthentication no"; \
      echo "UsePAM yes"; \
      echo "PrintMotd no"; \
      echo "AcceptEnv LANG LC_*"; \
      echo "Subsystem       sftp    /usr/lib/openssh/sftp-server"; \
    } >$SSHD_CONFIG

    history -cw
}

function main() {
  if [ $SFTP_ENABLE = 1 ]; 
  then
    if [[ ( ! -f $SSHD_CONFIG_BAK ) && ( $SFTP_PWD != "NONE" ) ]];
    then
      first_setup
    fi
    service_restart
  else
    service_stop
  fi
}

main