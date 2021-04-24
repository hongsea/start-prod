#!/bin/bash

#Main program  
#Process the input options. Add options as needed.
#Run this script for start docker compose.
#And check docker container run or not.
RED='\033[0;31m'
NC='\033[0m' 

Help()
{
   # Display Help
   echo "Usage: start-docker [OPTION]... [FILE]..."
   echo
   echo "options:"
   echo "-d     docker compose file path."
   echo "-p     directory project path."
   echo "-e     variable in docker compose file volume."
   echo "-s     status docker compose [start/stop/restart/down]."
   echo "-h     display this help and exit"
   echo
   echo "Examples:"
   echo "   start-docker -d ./docker-compose.yml -p /home/project -e PROJECT_PATH -s up"
}

Check(){
    if [[ ! -z ${STATUS} ]];then
        if [[ ${STATUS} == "up" || ${STATUS} == "start" || ${STATUS} == "restart" || ${STATUS} == "down" ]];then
            if [[ ! -f ${DOCKER_COMPOSE_PATH} ]];then
                echo -e "${RED}argument option -d: No such file or directory${NC}"
                Help
                exit 1;
            fi

            if [[ ! -d ${PROJECT_PATH} ]];then
                echo -e "${RED}argument option -p: No such file or directory${NC}"
                Help
                exit 1;
            fi
        else
            echo -e "${RED}argument option -s: Invalid option${NC}"
            Help
            exit 1;
        fi
    fi
}

# Get the options
while getopts ":hp:he:hd:hs:" option; do
   case $option in
        h) # display Help
            Help
            exit;;

        p) # project path
            PROJECT_PATH=${OPTARG};;

        d) # docker path
            DOCKER_COMPOSE_PATH=${OPTARG};; 

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

if [[ -z ${DOCKER_COMPOSE_PATH} && -z ${STATUS} ]];then
    Help
    exit 1

elif [[ -z ${DOCKER_COMPOSE_PATH} ]];then
    echo -e "${RED}Program required docker compose file path..!${NC}"
    Help
    exit 1

elif [[ -z ${STATUS} ]];then
    echo -e "${RED}Program required status docker compose [start/stop/restart/down]..!${NC}"
    Help
    exit 1    

elif [[ ! -z $DOCKER_VOLUME && -z $PROJECT_PATH ]];then 
    echo -e "${RED}Program required directory project path..!${NC}"
    Help
    exit 1

elif [[ -z ${DOCKER_VOLUME} && ! -z ${PROJECT_PATH} ]];then 
    echo -e "${RED}Program required variable in docker compose file volume..!${NC}"
    Help
    exit 1    

elif [[ ! -z ${DOCKER_VOLUME} && ! -z ${PROJECT_PATH} && ! -z ${DOCKER_COMPOSE_PATH} && ! -z ${STATUS} ]];then
    Check
    echo "${DOCKER_VOLUME}=${PROJECT_PATH} docker-compose -f ${DOCKER_COMPOSE_PATH} ${STATUS}"

elif [[ -z ${DOCKER_VOLUME} && -z ${PROJECT_PATH} && ! -z ${DOCKER_COMPOSE_PATH} && ! -z ${STATUS} ]];then
    Check
    echo "docker-compose -f ${DOCKER_COMPOSE_PATH} ${STATUS}"
fi

