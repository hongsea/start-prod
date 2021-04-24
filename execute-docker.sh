#!/bin/bash

#Main program  
#Process the input options. Add options as needed.
#Run this script for start docker compose.
#And check docker container run or not.
RED='\033[0;31m'
NC='\033[0m' 

check_root(){
    if [[ $(id -u) != 0 ]]; then
        echo -e "${RED}This script run as root.${NC}"
        exit;
    fi
}
check_root


Help()
{
   # Display Help
   echo "Usage: start-docker [OPTION]... [FILE]..."
   echo
   echo "options:"
   echo "   -c     docker compose file path."
   echo "   -d     docker compose file path with background running."
   echo "   -n     docker container name."
   echo "   -p     directory project path."
   echo "   -e     variable in docker compose file volume."
   echo "   -s     status docker compose [start/stop/restart/up/down]."
   echo "   -h     display this help and exit"
   echo
   echo "Examples:"
   echo "   execute-docker -d ./docker-compose.yml -p /home/project -e PROJECT_PATH -n webserver -s up"
}

Check(){
    if [[ ! -z ${STATUS} ]];then
        if [[ ${STATUS} == "start" || ${STATUS} == "stop" || ${STATUS} == "restart" || ${STATUS} == "up" || ${STATUS} == "down" ]];then
            if [[ ${STATUS} == "up" ]];then
                STATUS_DOCKER="${STATUS} -d";
            else
                STATUS_DOCKER="${STATUS}";
            fi
            
            if [[ ! -z ${DOCKER_COMPOSE_PATH} ]];then
                if [[ ! -f ${DOCKER_COMPOSE_PATH} ]];then
                    echo -e "${RED}argument option -d: No such file or directory${NC}"
                    Help
                    exit 1;
                fi
            fi

            if [[ ! -z ${DOCKER_COMPOSE_PATH_BACKGROUND} ]];then
                if [[ ! -f ${DOCKER_COMPOSE_PATH_BACKGROUND} ]];then
                    echo -e "${RED}argument option -d: No such file or directory${NC}"
                    Help
                    exit 1;
                fi
            fi

            if [[ ! -z ${PROJECT_PATH} ]];then
                if [[ ! -d ${PROJECT_PATH} ]];then
                    echo -e "${RED}argument option -p: No such file or directory${NC}"
                    Help
                    exit 1;
                fi
            fi            
        else
            echo -e "${RED}argument option -s: Invalid option${NC}"
            Help
            exit 1;
        fi
    fi
}

# Get the options
while getopts ":hp:he:hc:hd:hs:hn:" option; do
   case $option in
        h) # display Help
            Help
            exit;;

        p) # project path
            PROJECT_PATH=${OPTARG};;

        c) # docker path
            DOCKER_COMPOSE_PATH=${OPTARG};; 

        d) # docker path with background running
            DOCKER_COMPOSE_PATH_BACKGROUND=${OPTARG};; 

        n) # docker path with background running
            DOCKER_CONTAINER_NAME=${OPTARG};; 

        e) # enviroment variable
            DOCKER_VOLUME=${OPTARG};;

        s) # status variable
            STATUS=${OPTARG};;      

        :) printf "missing argument for option -%s\n" "${OPTARG}" >&2
            exit 1
            ;;            
        \?) # incorrect option
            echo "start-docker.sh: Invalid option"
            echo "Try 'start-docker.sh -h' for more information."
            exit 1;;
   esac
done

if [[ -z ${DOCKER_COMPOSE_PATH} && -z ${DOCKER_COMPOSE_PATH_BACKGROUND} && -z ${STATUS} ]];then
    Help
    echo "1"

elif [[ -z ${DOCKER_COMPOSE_PATH} && -z ${DOCKER_COMPOSE_PATH_BACKGROUND}  ]];then
    echo -e "${RED}Program required docker compose file path..!${NC}"
    Help
    exit 1;


elif [[ -z ${STATUS} ]];then
    echo -e "${RED}Program required status docker compose [start/stop/restart/down]..!${NC}"
    Help
    exit 1;    

elif [[ -z ${DOCKER_CONTAINER_NAME} ]];then
    echo -e "${RED}Program required docker container name..!${NC}"
    Help
    exit 1;       

elif [[ ! -z $DOCKER_VOLUME && -z $PROJECT_PATH ]];then 
    echo -e "${RED}Program required directory project path..!${NC}"
    Help
    exit 1;

elif [[ -z ${DOCKER_VOLUME} && ! -z ${PROJECT_PATH} ]];then 
    echo -e "${RED}Program required variable in docker compose file volume..!${NC}"
    Help
    exit 1;    

elif [[ ! -z ${DOCKER_VOLUME} && ! -z ${PROJECT_PATH} && ! -z ${DOCKER_COMPOSE_PATH} && ! -z ${STATUS} && ! -z ${DOCKER_CONTAINER_NAME} ]];then
    Check
    ${DOCKER_VOLUME}=${PROJECT_PATH} docker-compose -f ${DOCKER_COMPOSE_PATH} ${STATUS}

elif [[ ! -z ${DOCKER_VOLUME} && ! -z ${PROJECT_PATH} && ! -z ${DOCKER_COMPOSE_PATH_BACKGROUND} && ! -z ${STATUS} && ! -z ${DOCKER_CONTAINER_NAME} ]];then
    Check
    ${DOCKER_VOLUME}=${PROJECT_PATH} docker-compose -f ${DOCKER_COMPOSE_PATH_BACKGROUND} ${STATUS_DOCKER} &>/dev/null

    sleep 15
    CONTAINER_NAME=$(docker ps --filter "name=${DOCKER_CONTAINER_NAME}" --format "{{.Names}}")    
    if [[ ${CONTAINER_NAME} == ${DOCKER_CONTAINER_NAME} ]];then
        DOCKER_STATE=$(docker ps -a --filter "name=${CONTAINER_NAME}" --format "{{.State}}")
        if [[ ${DOCKER_STATE} == "running" ]];then
            echo "Your container executed successfully."
        elif [[ ${DOCKER_STATE} == "restarting" || ${DOCKER_STATE} == "exited" ]];then
            echo "Your container executed failed."
            exit 1;
        fi
    else
        echo "please check docker container name again in docker compose file."
        exit 1;        
    fi


elif [[ -z ${DOCKER_VOLUME} && -z ${PROJECT_PATH} && ! -z ${DOCKER_COMPOSE_PATH} && ! -z ${STATUS} && ! -z ${DOCKER_CONTAINER_NAME} ]];then
    Check
    docker-compose -f ${DOCKER_COMPOSE_PATH} ${STATUS}

elif [[ -z ${DOCKER_VOLUME} && -z ${PROJECT_PATH} && ! -z ${DOCKER_COMPOSE_PATH_BACKGROUND} && ! -z ${STATUS} && ! -z ${DOCKER_CONTAINER_NAME} ]];then
    Check
    docker-compose -f ${DOCKER_COMPOSE_PATH_BACKGROUND} ${STATUS_DOCKER} &>/dev/null

    sleep 15
    CONTAINER_NAME=$(docker ps --filter "name=${DOCKER_CONTAINER_NAME}" --format "{{.Names}}")    
    if [[ ${CONTAINER_NAME} == ${DOCKER_CONTAINER_NAME} ]];then
        DOCKER_STATE=$(docker ps -a --filter "name=${CONTAINER_NAME}" --format "{{.State}}")
        if [[ ${DOCKER_STATE} == "running" ]];then
            echo "Your container executed successfully."
        elif [[ ${DOCKER_STATE} == "restarting" || ${DOCKER_STATE} == "exited" ]];then
            echo "Your container executed failed."
            exit 1;
        fi
    else
        echo "please check docker container name again in docker compose file."
        exit 1;
    fi

fi