#!/bin/bash

# VARIÁVEIS DE ARQUIVOS

cp /etc/ansible/hosts /root/hosts.bkp
address=$(cat /tmp/arquivo.txt | sed -n 1p) 
usuario=$(cat /tmp/arquivo.txt | sed -n 2p) 
senha=$(cat /tmp/arquivo.txt | sed -n 3p) 
echo "[servico]" >> /etc/ansible/hosts
echo "$address" >> /etc/ansible/hosts
echo " " >> /etc/ansible/hosts
echo "[servico:vars]" >> /etc/ansible/hosts
echo "ansible_ssh_user=$usuario" >> /etc/ansible/hosts
echo "ansible_ssh_pass=$senha" >> /etc/ansible/hosts

dos2unix /etc/ansible/hosts

exit 0
