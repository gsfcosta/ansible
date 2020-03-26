#!/bin/bash

# VARIÁVEIS DE ARQUIVOS

ARQUIVO="/tmp/arquivo.csv"
PASTA_TEMP="/tmp"

usuario=$(cat $PASTA_TEMP/arquivo.txt | sed -n 1p)
senha=$(cat $PASTA_TEMP/arquivo.txt | sed -n 2p)

line=$(wc -l $ARQUIVO | cut -d' ' -f1)
let line=($line-1)
line1=0
cat $ARQUIVO | cut -d';' -f1 | sed '1d' > $PASTA_TEMP/hostname
INT=$(tr '\n' ';' < $PASTA_TEMP/hostname)
IFS=';' read -r -a HOSTNAME <<< "$INT"
cat $ARQUIVO | cut -d';' -f2 | sed '1d' > $PASTA_TEMP/address
INT=$(tr '\n' ';' < $PASTA_TEMP/address)
IFS=';' read -r -a ADDRESS <<< "$INT"

cp /etc/ansible/hosts /root/hosts.bkp

echo "[agent]" >> /etc/ansible/hosts
while (( $line1 != $line )); do
	echo "${HOSTNAME[$line1]}	ansible_host=${ADDRESS[$line1]}" >> /etc/ansible/hosts
	let line1=($line1+1)
done	

echo " " >> /etc/ansible/hosts
echo "[agent:vars]" >> /etc/ansible/hosts
echo "ansible_ssh_user=$usuario" >> /etc/ansible/hosts
echo "ansible_ssh_pass=$senha" >> /etc/ansible/hosts

dos2unix /etc/ansible/hosts

exit 0
