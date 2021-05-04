#!/bin/bash

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check env file
if [[ ! -f './.env' ]]
then
    printf "\e[31mEnv file not found\e[0m\n"
    exit 1;
fi


# Load and check config
source ./.env
LOG_PATH="./logs/docker.log"
echo "" > ${LOG_PATH}


# ----------------------------- HEADER -----------------------------

Title() {
    printf "\n\e[1;46m ----- $1 ----- \e[0m\n"
}

Success() {
    printf "\e[32m$1\e[0m\n"
}

Error() {
    printf "\e[31m$1\e[0m\n"
}

Warning() {
    printf "\e[31;43m$1\e[0m\n"
}

Comment() {
    printf "\e[36m$1\e[0m\n"
}

Help() {
    printf "\e[2m$1\e[0m\n"
}

Ln() {
    printf "\n"
}

DoneOrError() {
    if [[ $1 -eq 0 ]]
    then
        Success 'done'
    else
        Error 'error'
        exit 1
    fi
}

Confirm () {
    Ln

    choice=""
    while [[ "$choice" != "n" ]] && [[ "$choice" != "y" ]]
    do
        printf "Do you want to continue ? (N/Y)"
        read choice
        choice=$(echo ${choice} | tr '[:upper:]' '[:lower:]')
    done

    if [[ "$choice" = "n" ]]; then
        Warning "Abort by user"
        exit 0
    fi

    Ln
}

ClearLogs() {
    echo "" > ${LOG_PATH}
}

# ----------------------------- NETWORK -----------------------------

NetworkExists() {
    if [[ "$(docker network ls --format '{{.Name}}' | grep $1\$)" ]]
    then
        return 0
    fi
    return 1
}

NetworkCreate() {
    printf "Creating network \e[1;33m$1\e[0m ... "
    if ! NetworkExists $1
    then
        docker network create $1 >> ${LOG_PATH} 2>&1
        if [[ $? -eq 0 ]]
        then
            Success "created"
        else
            Error "error"
            exit 1
        fi
    else
        Comment "exists"
    fi
}

NetworkRemove() {
    printf "Removing network \e[1;33m$1\e[0m ... "
    if NetworkExists $1
    then
        docker network rm $1 >> ${LOG_PATH} 2>&1
        if [[ $? -eq 0 ]]
        then
            Success "removed"
        else
            Error "error"
            exit 1
        fi
    else
        Comment "unknown"
    fi
}

# ----------------------------- VOLUME -----------------------------

VolumeExists() {
    if [[ "$(docker volume ls --format '{{.Name}}' | grep $1\$)" ]]
    then
        return 0
    fi
    return 1
}

VolumeCreate() {
    printf "Creating volume \e[1;33m$1\e[0m ... "
    if ! VolumeExists $1
    then
        docker volume create --name $1 >> ${LOG_PATH} 2>&1
        if [[ $? -eq 0 ]]
        then
            Success "created"
        else
            Error "error"
            exit 1
        fi
    else
        Comment "exists"
    fi
}

VolumeRemove() {
    printf "Removing volume \e[1;33m$1\e[0m ... "
    if VolumeExists $1
    then
        docker volume rm $1 >> ${LOG_PATH} 2>&1
        if [[ $? -eq 0 ]]
        then
            Success "removed"
        else
            Error "error"
            exit 1
        fi
    else
        Comment "unknown"
    fi
}

# ----------------------------- COMPOSE -----------------------------

ComposeUp() {
    printf "Composing \e[1;33mUp\e[0m ... "
    docker-compose -f compose.yml up -d >> ${LOG_PATH} 2>&1
    DoneOrError $?

#    docker exec ${COMPOSE_PROJECT_NAME}_nginx chown -Rf www-data:www-data /var/www/web
}

ComposeDown() {
    printf "Composing \e[1;33mDown\e[0m ... "
    docker-compose -f compose.yml down -v --remove-orphans >> ${LOG_PATH} 2>&1
    DoneOrError $?
}

# ----------------------------- INTERNAL -----------------------------

DoCreateNetworkAndVolumes() {
    NetworkCreate "${COMPOSE_NETWORK}"
    VolumeCreate "${COMPOSE_PROJECT_NAME}-docroot"
}

DoRemoveNetworkAndVolumes() {
    VolumeRemove "${COMPOSE_PROJECT_NAME}-docroot"
}

# ----------------------------- EXEC -----------------------------

case $1 in
    # -------------- UP --------------
    up)
        DoCreateNetworkAndVolumes
        ComposeUp
    ;;
    # ------------- DOWN -------------
    down)
        ComposeDown
    ;;
    # ------------- RESET ------------
    reset)
        Title "Resetting stack"
        Warning "All data will be lost !"
        Confirm

        ComposeDown
        DoRemoveNetworkAndVolumes

        sleep 5

        DoCreateNetworkAndVolumes
        ComposeUp
    ;;
    # ------------- HELP -------------
    *)
        Help "Usage: ./manage.sh [action]

  \e[0mup\e[2m      Create network and volumes and start containers.
  \e[0mdown\e[2m    Stop containers.
  \e[0mreset\e[2m   Recreate volumes and restart containers.
"
    ;;
esac
