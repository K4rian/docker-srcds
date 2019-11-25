#!/bin/bash

bash "$SERVERDIR/srcds_sftp.sh"

APPSCRIPT_VALIDATE=$SERVERDIR/srcds_appscript_validate.txt
APPSCRIPT_UPDATE=$SERVERDIR/srcds_appscript_update.txt

# Starts the server
# (bool)  $1->$b_autoupdate    uses auto-update feature
# (str)   @:2->$s_startparams  srcds params (optional)
function server_start() {
  local b_autoupdate=$1
  local s_startparams=""

  if [ ! -z "$2" ];
  then
    s_startparams="${@:2}"
  fi

  if [ $b_autoupdate = true ]; 
  then
    $SERVERDIR/srcds_run -game $APPNAME -autoupdate -steam_dir $STEAMCMDDIR -steamcmd_script $APPSCRIPT_UPDATE $s_startparams
  else
    $SERVERDIR/srcds_run -game $APPNAME $s_startparams
  fi
}

# Downloads/updates the server files
# (bool)  $1->$b_validate  uses validate script
function server_update() {
  local b_validate=$1
  local s_scriptfile=$APPSCRIPT_UPDATE

  if [ $b_validate = true ]; 
  then
    s_scriptfile=$APPSCRIPT_VALIDATE
  fi

  $STEAMCMDDIR/steamcmd.sh +runscript $s_scriptfile
}

# - Downloads/updates and validate the server files if they don't already exist
# - Starts the server with the auto-update feature
# (var)  $@  srcds params (optional)
function server_startautoupdate() {
  if [ ! -x $SERVERDIR/srcds_run ]; then
    server_update true
  fi
  server_start true "$@"
}

# Writes the given script file
# (str)   $1->$s_scriptfile  script absolute path
# (bool)  $2->$b_validate    enables files validation
function write_script() {
  local s_scriptfile="$1"
  local b_validate=$2
  local s_valtext=""

  if [ $b_validate = true ]; 
  then
    s_valtext="validate"
  fi

  { echo "@ShutdownOnFailedCommand 1"; \
    echo "@NoPromptForPassword 1"; \
    echo "login anonymous"; \
    echo "force_install_dir $SERVERDIR"; \
    echo "app_update $APPID $s_valtext"; \
    echo "quit"; \
  } >$s_scriptfile
}

function main() {
  # Write each script file if they don't already exist
  if [ ! -f $APPSCRIPT_VALIDATE ]; then
    write_script $APPSCRIPT_VALIDATE true
  fi

  if [ ! -f $APPSCRIPT_UPDATE ]; then
    write_script $APPSCRIPT_UPDATE false
  fi

  if [ ! -z "$1" ]; 
  then
    case "${1}" in
      # Starts the server
      -s|-start) 
        local s_startparams=""

        if [ ! -z "$2" ];
        then
          s_startparams="${@:2}"
        fi
        server_start false $s_startparams
      ;;
      # Downloads/updates the server files then quit
      -u|-update) 
        server_update false
      ;;
      # Downloads/updates and validate the server files then quit
      -v|-validate) 
        server_update true
      ;;
      # Changes ownership of all gameserver files to the current user
      -to|-takeown) 
        chown -R $USER:$USER $SERVERDIR
      ;;
      # Downloads/updates and validate the server files if they don't already exist
      # then start the server with the auto-update feature
      *)
        server_startautoupdate "${@:1}"
      ;;
    esac
  else
    # Downloads/updates and validate the server files if they don't already exist
    # then start the server with the auto-update feature
    server_startautoupdate
  fi
}

main "$@"