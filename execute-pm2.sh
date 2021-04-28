#!/bin/bash

#Main program  
#Process the input options. Add options as needed.
#Run this script for start pm2.
#And check pm2 run or not.

Help()
{
   # Display Help
   echo "Usage: start-docker [OPTION]... [FILE]..."
   echo
   echo "options:"
   echo "   -n     pm2 application-name."
   echo "   -h     display this help and exit"   
   echo
   echo "Examples:"
   echo "   execute-pm2 -n application-name"
}

while getopts ":hn:" option; do
   case $option in
        h) # display Help
            Help
            exit;;

        n) # project path
            APP_NAME=${OPTARG};;

        :) printf "missing argument for option -%s\n" "${OPTARG}" >&2
            exit 1
            ;;      

        \?) # incorrect option
            echo "start-docker.sh: Invalid option"
            echo "Try 'execute-pm2 -h' for more information."
            exit 1;;   
   esac
done

if [[ -z ${APP_NAME} ]];then
    Help
    exit;
else
    APP_CHECK_NAME=$(pm2 describe ${APP_NAME} | grep name | grep app | awk NR-1 | awk NR-2 | awk -F' ' '{print $4}')
    if [[ ${APP_NAME} == ${APP_CHECK_NAME} ]];then
        ACTION=$(pm2 describe ${APP_NAME} | grep status | awk -F' ' '{print $4}')
        if [[ ${ACTION} == "online" ]];then
            echo "Your app executed successfully."
        elif [[ ${ACTION} == "stopped" ]];then
            echo "Your app executed stopped."
            exit 1;
        fi
    else 
        echo "Your application not exist."
        exit 1;
    fi
fi
