# docker commands and options

enables containerization with feature sets as 
Flexible , Lightweight , Interchangeable , Portable , Scalable , Stackable

*image* container is launched by running an image (executable package that includes everything needed to run an application--the code, a runtime, libraries, environment variables, and configuration files).

*container* runtime instance of an image--what the image becomes in memory when executed (that is, an image with state, or a user process).

*services* different pieces of the app in a distributed application

*tasks* A single container running in a service. bears unique Id that numerically increment, up to the number of replicas defined in docker-compose.yml

*swarm*  joining multiple machines into a “Dockerized” cluster to make Multi-container, multi-machine applications

*stack* group of interrelated services that share dependencies, and can be orchestrated and scaled together.


## Docker commands 

Options:
      --config string      Location of client config files (default "/Users/altanaibisht/.docker")
  -D, --debug              Enable debug mode
  -H, --host list          Daemon socket(s) to connect to
  -l, --log-level string   Set the logging level ("debug"|"info"|"warn"|"error"|"fatal") (default "info")
      --tls                Use TLS; implied by --tlsverify
      --tlscacert string   Trust certs signed only by this CA (default "/Users/altanaibisht/.docker/ca.pem")
      --tlscert string     Path to TLS certificate file (default "/Users/altanaibisht/.docker/cert.pem")
      --tlskey string      Path to TLS key file (default "/Users/altanaibisht/.docker/key.pem")
      --tlsverify          Use TLS and verify the remote
  -v, --version            Print version information and quit

Management Commands:
  builder     Manage builds
  config      Manage Docker configs
  container   Manage containers
  image       Manage images
  network     Manage networks
  node        Manage Swarm nodes
  plugin      Manage plugins
  secret      Manage Docker secrets
  service     Manage services
  stack       Manage Docker stacks
  swarm       Manage Swarm
  system      Manage Docker
  trust       Manage trust on Docker images
  volume      Manage volumes

Commands:
  attach      Attach local standard input, output, and error streams to a running container
  build       Build an image from a Dockerfile
  commit      Create a new image from a container's changes
  cp          Copy files/folders between a container and the local filesystem
  create      Create a new container
  deploy      Deploy a new stack or update an existing stack
  diff        Inspect changes to files or directories on a container's filesystem
  events      Get real time events from the server
  exec        Run a command in a running container
  export      Export a container's filesystem as a tar archive
  history     Show the history of an image
  images      List images
  import      Import the contents from a tarball to create a filesystem image
  info        Display system-wide information
  inspect     Return low-level information on Docker objects
  kill        Kill one or more running containers
  load        Load an image from a tar archive or STDIN
  login       Log in to a Docker registry
  logout      Log out from a Docker registry
  logs        Fetch the logs of a container
  pause       Pause all processes within one or more containers
  port        List port mappings or a specific mapping for the container
  ps          List containers
  pull        Pull an image or a repository from a registry
  push        Push an image or a repository to a registry
  rename      Rename a container
  restart     Restart one or more containers
  rm          Remove one or more containers
  rmi         Remove one or more images
  run         Run a command in a new container
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  search      Search the Docker Hub for images
  start       Start one or more stopped containers
  stats       Display a live stream of container(s) resource usage statistics
  stop        Stop one or more running containers
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
  top         Display the running processes of a container
  unpause     Unpause all processes within one or more containers
  update      Update configuration of one or more containers
  version     Show the Docker version information
  wait        Block until one or more containers stop, then print their exit codes
  

see all docker images 
```
>docker-compose images
                 Container                           Repository              Tag         Image Id      Size  
-------------------------------------------------------------------------------------------------------------
caddy                                         stefanprodan/caddy          latest       655880563633   23.5 MB
heplify-server                                sipcapture/heplify-server   master       6d2746888c2d   21.5 MB
hepsub                                        sipcapture/hepsub           master       3ef6550c4bc6   86.4 MB
hom7-hep-influx_chronograf_1_85695a5e0e51     chronograf                  1.5-alpine   02ed2863e25b   42.5 MB
hom7-hep-influx_db_1_bc9424b78bf1             postgres                    11-alpine    5239fade3a90   68.6 MB
hom7-hep-influx_influxdb_1_8134158a7927       influxdb                    1.5-alpine   40e13f6ee02a   80.1 MB
hom7-hep-influx_kapacitor_1_bc614d9edcbc      kapacitor                   1.5-alpine   2a63b9d348df   70.2 MB
hom7-hep-influx_provisioning_1_9b5d152e5153   alpine                      latest       b7b28af77ffe   5.32 MB
hom7-hep-influx_telegraf_1_5b4901ddc8ef       telegraf                    1.5-alpine   aa8daabb3b1c   40.1 MB
homer-webapp                                  sipcapture/homer-app        master       87713ed4e74a   433 MB 
```

*see all docker container*
```
docker container ls
CONTAINER ID        IMAGE                              COMMAND                  CREATED             STATUS                    PORTS                                                                                            NAMES
cdd47095325f        telegraf:1.5-alpine                "/entrypoint.sh tele…"   About an hour ago   Up 14 minutes             0.0.0.0:8092->8092/udp, 0.0.0.0:8125->8125/udp, 8094/tcp                                         hom7-hep-influx_telegraf_1_5b4901ddc8ef
75f40d579b4a        sipcapture/heplify-server:master   "./heplify-server"       About an hour ago   Up 14 minutes             0.0.0.0:9060->9060/tcp, 0.0.0.0:9060->9060/udp, 9090/tcp                                         heplify-server
f65c80d771cf        sipcapture/homer-app:master        "/docker-entrypoint.…"   About an hour ago   Up 14 minutes             80/tcp, 443/tcp, 8001/tcp                                                                        homer-webapp
1a24d85268c0        postgres:11-alpine                 "docker-entrypoint.s…"   About an hour ago   Up 14 minutes (healthy)   5432/tcp                                                                                         hom7-hep-influx_db_1_bc9424b78bf1
966c3308317c        chronograf:1.5-alpine              "/entrypoint.sh chro…"   3 hours ago         Up 14 minutes             8888/tcp                                                                                         hom7-hep-influx_chronograf_1_85695a5e0e51
0bf6ed2aa83e        kapacitor:1.5-alpine               "/entrypoint.sh kapa…"   3 hours ago         Up 14 minutes             9092/tcp                                                                                         hom7-hep-influx_kapacitor_1_bc614d9edcbc
45990da3352f        influxdb:1.5-alpine                "/entrypoint.sh infl…"   3 hours ago         Up 14 minutes             8086/tcp                                                                                         hom7-hep-influx_influxdb_1_8134158a7927
71e5ee3f9ad9        stefanprodan/caddy                 "/sbin/tini -- caddy…"   3 hours ago         Up 14 minutes             0.0.0.0:3000->3000/tcp, 0.0.0.0:9080->9080/tcp, 0.0.0.0:9090->9090/tcp, 0.0.0.0:9093->9093/tcp   caddy
```

*see all open ports*
```
>ss -tulpen
Netid  State      Recv-Q Send-Q                                                                                        Local Address:Port                                                                                                       Peer Address:Port              
udp    UNCONN     0      0                                                                                                 127.0.0.1:323                                                                                                                   *:*                   users:(("chronyd",pid=483,fd=1)) ino:12818 sk:1 <->
udp    UNCONN     0      0                                                                                                         *:68                                                                                                                    *:*                   users:(("dhclient",pid=275,fd=6)) ino:11595 sk:2 <->
udp    UNCONN     0      0                                                                                                       ::1:323                                                                                                                  :::*                   users:(("chronyd",pid=483,fd=2)) ino:12819 sk:3 v6only:1 <->
udp    UNCONN     0      0                                                                                                        :::9060                                                                                                                 :::*                   users:(("heplify-server",pid=3709,fd=6)) ino:625301 sk:11 v6only:0 <->
udp    UNCONN     0      0                                                                               fe80::ea:dff:fee6:2a7c%eth0:546                                                                                                                  :::*                   users:(("dhclient",pid=357,fd=5)) ino:11816 sk:5 v6only:1 <->
tcp    LISTEN     0      80                                                                                                127.0.0.1:3306                                                                                                                  *:*                   users:(("mysqld",pid=21541,fd=17)) uid:110 ino:73470 sk:6 <->
tcp    LISTEN     0      128                                                                                                       *:80                                                                                                                    *:*                   users:(("node",pid=14410,fd=19)) ino:33365 sk:7 <->
tcp    LISTEN     0      128                                                                                                       *:22                                                                                                                    *:*                   users:(("sshd",pid=484,fd=3)) ino:12903 sk:8 <->
tcp    LISTEN     0      128                                                                                               127.0.0.1:5432                                                                                                                  *:*                   users:(("postgres",pid=18024,fd=3)) uid:109 ino:63751 sk:9 <->
tcp    LISTEN     0      128                                                                                                       *:443                                                                                                                   *:*                   users:(("node",pid=14410,fd=20)) ino:33366 sk:a <->
tcp    LISTEN     0      128                                                                                                      :::9060                                                                                                                 :::*                   users:(("heplify-server",pid=3709,fd=7)) ino:625302 sk:12 v6only:0 <->
tcp    LISTEN     0      128                                                                                                      :::9096                                                                                                                 :::*                   users:(("heplify-server",pid=3709,fd=3)) ino:625296 sk:13 v6only:0 <->
tcp    LISTEN     0      128                                                                                                      :::22                                                                                                                   :::*                   users:(("sshd",pid=484,fd=4)) ino:12905 sk:d v6only:1 <->

```

*see all docker processes*
```
>docker ps -a
CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS              PORTS                                                                                            NAMES
085e6d740c56        stefanprodan/caddy          "/sbin/tini -- caddy…"   About an hour ago   Created             0.0.0.0:3000->3000/tcp, 0.0.0.0:9080->9080/tcp, 0.0.0.0:9090->9090/tcp, 0.0.0.0:9093->9093/tcp   caddy
e72a9659ea1d        postgres:11-alpine          "docker-entrypoint.s…"   About an hour ago   Created             5432/tcp                                                                                         hom7-hep-influx_db_1_f0dfb2b2f2a9
cebb108938e4        influxdb:1.5-alpine         "/entrypoint.sh infl…"   About an hour ago   Created             8086/tcp                                                                                         hom7-hep-influx_influxdb_1_a2447b2e8064
ac929f263824        sipcapture/homer-kamailio   "/run.sh"                3 hours ago         Created                                                                                                              homer-kamailio
d06e043bfcfe        sipcapture/homer-webapp     "/run.sh"                3 hours ago         Created                                                                                                              homer-webapp
f42c71741107        sipcapture/homer-cron       "/run.sh"                3 hours ago         Up 3 hours          80/tcp                                                                                           homer-cron
0111765091ae        mysql:5.6                   "/run.sh"                3 hours ago         Up 2 hours          3306/tcp                                                                                         mysql

```
To see only ids use 
```
docker ps -aq
```

*Stoping docker containers*

stop all containers:
```
docker kill $(docker ps -q)
```
remove all containers
```
docker rm $(docker ps -a -q)
```
remove all docker images
```
docker rmi $(docker images -q)
```

To turn down all docker processed 
```
cd /home/admin/homer7-docker/heplify-server/hom7-hep-influx
docker-compose down
```

To clean all volumes, containers, images and networks
```
docker system prune -a -f
```
