<h2 align="center">DOCKER-COMPOSE / PM2</h1>

If your run command `docker-comose up -d` or` docker-comose up` you will see any logs indicating that this container is running or failed by specify command `docker ps`. It's fine, but when we want to do an automatic deployment like Github Action to a server that just loads the container when changing the code. The status on Github Action will show you the status passing, but we are not sure this container status is running or restarting or failing. This is how I see the problem, so I created this script to check for more containers on the server when we start or restart it.

You can run pm2 execute to make sure your application is online or stopped.

#### Download Docker execute

<details><summary>CLICK ME</summary>
<p>

```shell
wget https://raw.githubusercontent.com/hongsea/start-prod/master/execute-docker.sh && sudo mv execute-docker.sh /usr/bin/execute-docker && sudo chmod +x /usr/bin/execute-docker
```

</p>
</details>

#### Execute :

```
$~ sudo execute-docker -h
Usage: start-docker [OPTION]... [FILE]...

options:
-c     docker compose file path.
-d     docker compose file path with background running.
-n     docker container name.
-p     directory project path.
-e     variable in docker compose file volume.
-s     status docker compose [start/stop/restart/up/down].
-h     display this help and exit

Examples:
execute-docker -d ./docker-compose.yml -p /home/project -e PROJECT_PATH -n webserver -s up

```

*Note: This script work with only docker compose.*

#### Example :

You have a docker-compose that you want to work with a variable path like this:

```yml
version: '3'
services:
    webserver:
        image: nginx:alpine
        container_name: webserver
        restart: always
        ports:
            - "81:80"
            - "444:443"
        volumes:
            - "${DEV_PATH}:/var/www/app/"  
```
Run docker compose execute:

```sh
$~ sudo execute-docker -p /var/path/dev -e DEV_PATH -d ./docker-compose.yml -n webserver -s up
Your container executed successfully.
```

#### Download Pm2 execute

<details><summary>CLICK ME</summary>
<p>

```shell
wget https://raw.githubusercontent.com/hongsea/start-prod/master/execute-pm2.sh && sudo mv execute-pm2.sh /usr/bin/execute-pm2 && sudo chmod +x /usr/bin/execute-pm2
```

</p>
</details>

#### Execute :

```
$~ execute-pm2 -h
Usage: start-docker [OPTION]... [FILE]...

options:
-n     pm2 application-name.

Examples:
execute-pm2 -n application-names
```

#### Example :

```sh
$~ execute-pm2 -n app1
Your app executed successfully.
```