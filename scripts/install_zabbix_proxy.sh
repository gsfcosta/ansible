#!/bin/bash

# VARIÁVEIS DE ARQUIVOS

cp /etc/ansible/hosts /root/hosts.bkp
hostname=$(cat /tmp/arquivo.txt | sed -n 1p)
address=$(cat /tmp/arquivo.txt | sed -n 2p) 
usuario=$(cat /tmp/arquivo.txt | sed -n 3p)
senha=$(cat /tmp/arquivo.txt | sed -n 4p)
echo "[proxy]" >> /etc/ansible/hosts
echo "$hostname	ansible_host=$address" >> /etc/ansible/hosts
echo " " >> /etc/ansible/hosts
echo "[proxy:vars]" >> /etc/ansible/hosts
echo "ansible_ssh_user=$usuario" >> /etc/ansible/hosts
echo "ansible_ssh_pass=$senha" >> /etc/ansible/hosts

dos2unix /etc/ansible/hosts

exit 0
