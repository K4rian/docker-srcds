docker-srcds
=====

A base Docker image for Valve's [Source Dedicated Server](https://developer.valvesoftware.com/wiki/Source_Dedicated_Server) *(srcds)*. 



## Introduction 

This image is used to setup and run any __Source Dedicated Server__ including *Counter-Strike: Source/Global Offensive*, *Left 4 Dead 1/2*, *Team Fortress 2*, *Garry's Mod* and more.

The image is based on [k4rian/steamcmd](https://hub.docker.com/r/k4rian/steamcmd).



## Environment variables

Two environment variables must be tweaked when creating a container depending on which game server has to be installed:
* __APPID__ — Steam application identifier *(used by steamcmd)*
* __APPNAME__ — Game name acronym *(used by srcds)*

Default values will install a *Half-Life 2: Deathmatch* Dedicated Server.



## Startup script

A convenient script has been added to interact with `steamcmd` and `srcds` in various ways.
It will intercept the first passed argument and do the following:

- `-s|-start`    Starts the server using `srcds_run`                     
— *Will fail if the server files haven't previously been downloaded*

- `-u|-update`   Downloads/updates the server files using `steamcmd`            
— *Will also perform a validation on each downloaded file*

- `-to|takeown`  Recursively changes ownership of all server files to the `steam` user     
— *Useful if you have altered any file/folder permission outside the container*

- `{empty}`      Downloads/updates the server files then start the server                   
— *Equivalent to `-update` + `-start`*



## Example uses

__Example 1:__                                 
Setup and run a *CS:GO* Classic Competitive public server:       
— *You need a valid [GSLT](https://steamcommunity.com/dev/managegameservers) token to make the server reachable*           
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
    +sv_setsteamaccount {YOUR_GSLT_TOKEN_HERE}
```


__Example 2:__                                     
Download the *Left 4 Dead 2* Dedicated Server files to a named volume for further use:
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

If the server has permission issues with some files, we can create an ephemeral container to recursively change 
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
Create a named volume then setup and run a *Team Fortress 2* Dedicated Server:              
— *The startup script will perform a full update check on each container start* 
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
    +sv_pure 1
```



## Manual build

__Requirements__:                               
— Docker >= __18.03.1__                         
— Git *(optional)*

Like any Docker image the building process is pretty straightforward. 

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