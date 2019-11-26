docker-srcds (sftp)
=====

A base Docker image for Valve's [Source Dedicated Server](https://developer.valvesoftware.com/wiki/Source_Dedicated_Server) *(srcds)* with SFTP support based on [debian](https://hub.docker.com/_/debian/):[buster-slim](https://hub.docker.com/_/debian/?tab=tags&page=1&name=buster-slim). 



## Introduction 

It is recommended to read the [original documentation](https://github.com/K4rian/docker-srcds/tree/master) since this branch focus on the SFTP feature.



## Variants

The `srcds` image comes in two variants:

- :[latest](https://github.com/K4rian/docker-srcds/tree/master) — the base image.
- :__[sftp](https://github.com/K4rian/docker-srcds/tree/sftp)__ — the base image with SFTP support added.



## Environment variables

Five environment variables related to the __SFTP__ service can be tweaked when creating a container:
* __SFTP_ENABLE__ —  Enables the SFTP service *(`0`: off/`1`: on, default: `0`)*
* __SFTP_PWD__ — SFTP Password *(default: `NONE`)*
* __SFTP_PORT__ —  SFTP Port *(default: `50451`)*
* __SFTP_MAX_AUTH_TRIES__ — SFTP Max Authentication Tries *(default: `3`)*
* __SFTP_MAX_SESSIONS__ —  SFTP Max Concurrent Sessions *(default: `1`)*

__Important Notes__:                                                                     
— The __SFTP User__ is always `steam`.                                                   
— If `SFTP_ENABLE` is set to `0`, the service will not start.                            
— If the default password is used (`NONE`), the service will not start.                  
— It is __strongly recommended__ to use a password with a minimum of __16 characters__ mixing numbers, lowercases, uppercases and special characters.



## Example uses

__Example 1:__                                 
Setup and run a *CS:GO* Classic Competitive public server with SFTP support using the default port (`50451`):                  
— *You need a valid __[GSLT](https://steamcommunity.com/dev/managegameservers)__ token to make the server reachable*           
```
$ docker run -d \
    --name csgoserv \
    --net=host \
    -e APPID=740 \
    -e APPNAME=csgo \
    -e SFTP_ENABLE=1 \
    -e SFTP_PWD={STRONG_PASSWORD_WITHOUT_SPACE} \
    -i k4rian/srcds:sftp \
    -console \
    -secured \
    -usercon \
    -port 27015 \
    +game_type 0 \
    +game_mode 1 \
    +mapgroup mg_active \
    +map de_dust2 \
    +sv_setsteamaccount {GSLT_TOKEN}
```

__Example 2:__                                 
Same as above but using a different __SFTP port__ on the __host__ (`50451` -> `45100`):                
— *Because at least one port binding is given, we have to bind all of them since we can't use the `--net` option anymore*
```
$ docker run -d \
    --name csgoserv \
    -p 27015:27015/tcp \
    -p 27015:27015/udp \
    -p 45100:50451/tcp \
    -e APPID=740 \
    -e APPNAME=csgo \
    -e SFTP_ENABLE=1 \
    -e SFTP_PWD={STRONG_PASSWORD_WITHOUT_SPACE} \
    -i k4rian/srcds:sftp \
    -console \
    -secured \
    -usercon \
    -port 27015 \
    +game_type 0 \
    +game_mode 1 \
    +mapgroup mg_active \
    +map de_dust2 \
    +sv_setsteamaccount {GSLT_TOKEN}
```



## Manual build

__Requirements__:                               
— Docker >= __18.03.1__                         
— Git *(optional)*

Like any Docker image the building process is pretty straightforward: 

- Clone (or download) the GitHub repository to an empty folder on your local machine:
```
$ git clone -b sftp --single-branch https://github.com/K4rian/docker-srcds.git .
```

- Then run the following command inside the newly created folder:
```
$ docker build --no-cache -t srcds:sftp .
```



## License

[MIT](LICENSE)