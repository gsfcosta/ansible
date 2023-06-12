#!/bin/bash
export RD_URL="http://localhost:4440"
export RD_URL="https://localhost:4443"
export RD_TOKEN="iBa5V7c9QCedCnEV1ryGKammfhpwhJeF"
export RD_BYPASS_URL="https://rundeck.domain"
export RD_INSECURE_SSL="true"
RUNDECK_BASE="/var/lib/rundeck"
RUNDECK_CONF="/etc/rundeck"
DATA=$(date +%d-%m-%Y)
FUNCAO=$1
PROJECTS=$(rd projects list | grep -v '^#' | tr '\n' ';' | sed 's/;;//g')
IFS=';' read -r -a PROJECTS <<< "$PROJECTS"
PROJ_NUM=${#PROJECTS[@]}

function projects(){
    INIT=0
    while [ $INIT -lt $PROJ_NUM ]; do
        BKP_DIR="/backup/jobs/${PROJECTS[$INIT]}"
        cd $BKP_DIR
        if [ $? -ne 0 ]; then
            mkdir -p $BKP_DIR
        fi
        rd jobs list -f $BKP_DIR/jobs_${DATA}.xml -p ${PROJECTS[$INIT]} 2> /dev/null
        case $? in
            0) echo "Backup project ${PROJECTS[$INIT]} successful";;
            *) echo "Backup: Error $? for project ${PROJECTS[$INIT]}";;
        esac
        let INIT=($INIT+1)
    done
}
function configuration(){
    INIT=0
    while [ $INIT -lt $PROJ_NUM ]; do
        BKP_DIR="/backup/projects_config/${PROJECTS[$INIT]}"
        cd $BKP_DIR
        if [ $? -ne 0 ]; then
            mkdir -p $BKP_DIR
        fi
        rd projects configure get -p ${PROJECTS[$INIT]} > $BKP_DIR/project_${DATA}.txt
        case $? in
            0) echo "Backup project ${PROJECTS[$INIT]} successful";;
            *) echo "Backup: Error $? for ${PROJECTS[$INIT]}";;
        esac
        let INIT=($INIT+1)
    done
}
function systeminfo(){
    rd system info > /backup/system_info_$DATA.txt
    case $? in
        0) echo "Backup system info successful";;
        *) echo "Error $? for system info backup";;
    esac
}
function users(){
    rd users list > /backup/users_$DATA.txt
    case $? in
        0) echo "Backup users successful";;
        *) echo "Error $? for users backup";;
    esac
}
function base(){
    BKP_DIR="/backup/files/base"
    cd $BKP_DIR
    if [ $? -ne 0 ]; then
        mkdir -p $BKP_DIR
    fi
    tar -czvf $BKP_DIR/logs_$DATA.tar.gz $RUNDECK_BASE/logs
    case $? in
        0) echo "Backup logs successful";;
        *) echo "Error $? for logs backup";;
    esac
    tar -czvf $BKP_DIR/var_$DATA.tar.gz $RUNDECK_BASE/var
    case $? in
        0) echo "Backup var successful";;
        *) echo "Error $? for var backup";;
    esac
    tar -czvf $BKP_DIR/ssh_$DATA.tar.gz $RUNDECK_BASE/.ssh
    case $? in
        0) echo "Backup ssh successful";;
        *) echo "Error $? for ssh backup";;
    esac
}
function etc(){
    BKP_DIR="/backup/files/etc"
    cd $BKP_DIR
    if [ $? -ne 0 ]; then
        mkdir -p $BKP_DIR
    fi
    tar -czvf $BKP_DIR/files_$DATA.tar.gz $RUNDECK_CONF
    case $? in
        0) echo "Backup etc successful";;
        *) echo "Error $? for etc backup";;
    esac
}
function all(){
    projects
    configuration
    systeminfo
    users
    base
    etc
}
$FUNCAO
