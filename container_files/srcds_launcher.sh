#!/bin/bash

APPSCRIPTFILE=$SERVERDIR/srcds_appscript.txt

# Starts the server
function server_start() {
  local start_params=""

  if [ ! -z "$1" ];
  then
    start_params="${@:1}"
  fi
  $SERVERDIR/srcds_run -game $APPNAME $start_params
}

# Downloads/updates the server files
function server_update() {
  $STEAMCMDDIR/steamcmd.sh +runscript $APPSCRIPTFILE
}

# Creates/writes the default install-update script
function write_default_script() {
  { echo "@ShutdownOnFailedCommand 1"; \
    echo "@NoPromptForPassword 1"; \
    echo "login anonymous"; \
    echo "force_install_dir $SERVERDIR"; \
    echo "app_update $APPID validate"; \
    echo "quit"; \
  } >$APPSCRIPTFILE
}

function main() {
  if [ ! -f $APPSCRIPTFILE ]; then
    write_default_script
  fi

  if [ ! -z "$1" ]; 
  then
    case "${1}" in
      # Starts the server
      -s|-start) 
        local start_params=""

        if [ ! -z "$2" ];
        then
          start_params="${@:2}"
        fi
        server_start $start_params
      ;;
      # Downloads/updates the server files and quit
      -u|-update) 
        server_update
      ;;
      # Changes ownership of all gameserver files to the current user
      -to|-takeown) 
        chown -R $USER $SERVERDIR
      ;;
      # Downloads/updates the server files then start the server
      *)
        server_update
        server_start "${@:1}"
      ;;
    esac
  else
    server_update
    server_start
  fi
}

main "$@"