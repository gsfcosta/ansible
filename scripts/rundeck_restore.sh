#!/bin/bash
export RD_URL="http://localhost:4440"
export RD_URL="https://localhost:4443"
export RD_TOKEN="iBa5V7c9QCedCnEV1ryGKammfhpwhJeF"
export RD_BYPASS_URL="https://rundeck.edge.uol"
export RD_INSECURE_SSL="true"
RUNDECK_BASE="/var/lib/rundeck"
RUNDECK_CONF="/etc/rundeck"
FUNCAO=$1
RESTORE_BASE=$2
DATA=$3
PROJECT=$4
function projects(){
    FILTER=$(echo $PROJECT | grep "," )
    if [ $? -eq 0 ]; then
        IFS=',' read -r -a PROJECT <<< "$PROJECT"
        PROJ_NUM=${#PROJECTS@]}
    fi
    INIT=0
    while [ $INIT -lt $PROJ_NUM ]; do
        SEARCH=$(find $BKP_DIR/${PROJECT[$INIT]}/ -type f -name jobs_$DATA.xml)
        if [ $SEARCH -z ]; then
            echo "Invalid date ${PROJECT[$INIT]} or date not found"
        else
            rd jobs load -f $BKP_DIR/${PROJECT[$INIT]}/jobs_$DATA.xml -p ${PROJECT[$INIT]}
            case $? in
                0) echo "Restore project ${PROJECT[$INIT]} successful";;
                *) echo "Error $? in project ${PROJECT[$INIT]}";;
            esac
        fi
        let INIT=($INIT+1)
    done
}
function base(){
    BKP_DIR="/backup/files/base"
    IFS=',' read -r -a RESTORE_BASE <<< "$RESTORE_BASE"
    BASE_NUM=${#RESTORE_BASE[@]}
    INIT=0
    while [ $INIT -lt $BASE_NUM ]; do
        if [ ${RESTORE_BASE[$INIT]} -eq "ssh" ]; then
            SEARCH=$(find $BKP_DIR/ -type f -name ssh_$DATA.tar.gz)
            if [ $SEARCH -z ]; then
                echo "Invalid date ssh or date not found"
                exit 124
            else
                tar -xzvf ssh_$DATA.tar.gz $RUNDECK_BASE/.ssh
            fi
        else
            SEARCH=$(find $BKP_DIR/ -type f -name ${RESTORE_BASE[$INIT]}_$DATA.tar.gz)
            if [ $SEARCH -z ]; then
                echo "Invalid date ${RESTORE_BASE[$INIT]} or date not found"
                exit 124
            else
                tar -xzvf $BKP_DIR/${RESTORE_BASE[$INIT]}_$DATA.tar.gz $RUNDECK_BASE/${RESTORE_BASE[$INIT]}
            fi
        fi
        let INIT=($INIT+1)
    done
}
function etc(){
    BKP_DIR="/backup/files/etc"
    SEARCH=$(find $BKP_DIR/ -type f -name files_$DATA.tar.gz)
    if [ $SEARCH -z ]; then
        echo "Invalid date log or date not found"
        exit 124
    fi
    tar -xzvf $BKP_DIR/files_$DATA.tar.gz $RUNDECK_CONF
}
function all(){
    projects
    base
    etc
}
$FUNCAO