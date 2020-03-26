#!/bin/bash

# VARIÁVEIS DE ARQUIVOS

KEY="/tmp/key"
PLAYBOOK="/etc/ansible/playbooks/adicionar_usuario.yml"

cp /root/adicionar_usuario_incompleto.yml $PLAYBOOK
cp /etc/ansible/hosts /root/hosts.bkp

chmod 755 $PLAYBOOK

PASS=$(cat $KEY)
user=$(cat /tmp/access | sed -n 1p)
password=$(cat /tmp/access | sed -n 2p)
echo "[adduser]" >> /etc/ansible/hosts
for line in $(cat /tmp/arquivo.txt); do
	echo $line >> /etc/ansible/hosts
done
echo " " >> /etc/ansible/hosts
echo "[adduser:vars]" >> /etc/ansible/hosts
echo "ansible_ssh_user=$user" >> /etc/ansible/hosts
echo "ansible_ssh_pass=$password" >> /etc/ansible/hosts

sed -i s/MUDAR/$PASS/g $PLAYBOOK
dos2unix /etc/ansible/hosts

exit 0
