docker-srcds
=====

A base Docker image for Valve's [Source Dedicated Server](https://developer.valvesoftware.com/wiki/Source_Dedicated_Server) *(srcds)* based on [debian](https://hub.docker.com/_/debian/):[buster-slim](https://hub.docker.com/_/debian/?tab=tags&page=1&name=buster-slim). 



## Introduction 

This image is used to setup and run any __Source Dedicated Server__ including *Counter-Strike: Source/Global Offensive*, *Left 4 Dead 1/2*, *Team Fortress 2*, *Garry's Mod* and more.



## Variants

The `srcds` image comes in two variants:

- :__[latest](https://github.com/K4rian/docker-srcds/tree/master)__ — the base image.
- :[sftp](https://github.com/K4rian/docker-srcds/tree/sftp) — the base image with SFTP support added.



## Environment variables

Two environment variables must be tweaked when creating a container depending on which game server has to be installed:
* __APPID__ — Steam application identifier *(used by steamcmd)*
* __APPNAME__ — Game name acronym *(used by srcds)*

Default values will setup a *Half-Life 2: Deathmatch* Dedicated Server.



## Startup script arguments

A convenient script has been added to interact with `steamcmd` and `srcds` in various ways.
It will intercept the first passed argument and do the following:

- `-s|-start`
  - Starts the server using `srcds_run`  
  - *Will fail if the server files haven't previously been downloaded*
- `-u|-update`
  - Downloads/updates the server files using `steamcmd`
- `-v|-validate`
  - Downloads/updates and validate the server files using `steamcmd` 
- `-to|takeown`
  - Recursively changes ownership of all server files to the `steam` user
  - *Useful if you have altered any file permission outside the container file system*
- `[none]`
  - Downloads/updates the server files if they haven't previously been downloaded
  - Starts the server in auto-update mode (using `-autoupdate`, `-steam_dir` and `-steamcmd_script` arguments)



## Example uses

__Example 1:__                                 
Setup and run a *CS:GO* Classic Competitive public server:           
— *Since no recognized argument is passed to the startup script, the server will start using the auto-update feature and also auto-restart if it crashes*     
— *You need a valid __[GSLT](https://steamcommunity.com/dev/managegameservers)__ token to make the server reachable*           
```
$ docker run -d \
    --name csgoserv \
    --net=host \
    -e APPID=740 \
    -e APPNAME=csgo \
    -i k4rian/srcds \
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
Download and validate the *Left 4 Dead 2* Dedicated Server files to a named volume for further use:       
— *The container will be deleted immediately after the task completed*             
— *Notice the `-validate` argument passed to the startup script* 
```
$ docker run --rm \
    -e APPID=222860 \
    -e APPNAME=left4dead2 \
    -v l4d2serv_data:/home/steam \
    -i k4rian/srcds \
    -validate
```

Now we can create a named container to start the server (in co-op mode) using the previously created volume:         
— *Since the `-start` argument is given, the startup script won't trigger any update* 
```
$ docker run -d \
    --name l4d2serv \
    --net=host \
    -e APPID=222860 \
    -e APPNAME=left4dead2 \
    -v l4d2serv_data:/home/steam \
    -i k4rian/srcds \
    -start \
    -console \
    -secure \
    -port 27015 \
    +map c1m1_hotel \
    +maxplayers 4
```

If we want to perform a manually update (__without__ validating the files), we can use an ephemeral container to handle the task:                    
— *The container will be deleted immediately after the task completed*             
— *Notice the `-update` argument passed to the startup script* 
```
$ docker run --rm \
    -e APPID=222860 \
    -e APPNAME=left4dead2 \
    -v l4d2serv_data:/home/steam \
    -i k4rian/srcds \
    -update
```

Finally, if the server has permission issues with some files, we can use an ephemeral container again to recursively change 
ownership of all server files:                  
— *The container will be deleted immediately after the task completed*             
— *Notice the `-takeown` argument passed to the startup script* 
```
$ docker run --rm \
    -v l4d2serv_data:/home/steam \
    -i k4rian/srcds \
    -takeown
```


__Example 3:__                                  
Setup and run a *Team Fortress 2* Dedicated Server and store all the files inside a named volume created on the fly:              
— *The startup script will perform a update check (without validation) on each start*            
— *You need a valid __[GSLT](https://steamcommunity.com/dev/managegameservers)__ token to make the server reachable*           
```
$ docker run -d \
    --name tf2serv \
    --net=host \
    -e APPID=232250 \
    -e APPNAME=tf \
    -v tf2serv_data:/home/steam \
    -i k4rian/srcds \
    -console \
    -secure \
    -timeout 0 \
    -port 27015 \
    +randommap \
    +maxplayers 24 \
    +sv_pure 1 \
    +sv_setsteamaccount {GSLT_TOKEN}
```



## Manual build

__Requirements__:                               
— Docker >= __18.03.1__                         
— Git *(optional)*

Like any Docker image the building process is pretty straightforward: 

- Clone (or download) the GitHub repository to an empty folder on your local machine:
```
$ git clone https://github.com/K4rian/docker-srcds.git .
```

- Then run the following command inside the newly created folder:
```
$ docker build --no-cache -t srcds .
```



## License

[MIT](LICENSE)