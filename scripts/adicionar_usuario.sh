#!/bin/bash

# VARIÁVEIS DE ARQUIVOS

KEY="/tmp/key"
PLAYBOOK="/etc/ansible/playbooks/adicionar_usuario.yml"

cp /root/adicionar_usuario_incompleto.yml $PLAYBOOK
cp /etc/ansible/hosts /root/hosts.bkp

chmod 755 $PLAYBOOK

PASS=$(cat $KEY)
echo "[adduser]" >> /etc/ansible/hosts
for line in $(cat /tmp/arquivo.txt); do
	echo $line >> /etc/ansible/hosts
done
echo " " >> /etc/ansible/hosts
echo "[adduser:vars]" >> /etc/ansible/hosts
echo "ansible_ssh_user=root" >> /etc/ansible/hosts
echo "ansible_ssh_pass=roundhead" >> /etc/ansible/hosts

echo "      password: '$PASS'" >> $PLAYBOOK
echo "      state: present" >> $PLAYBOOK
echo " " >> $PLAYBOOK
echo "  - lineinfile:" >> $PLAYBOOK
echo "      path: /etc/sudoers" >> $PLAYBOOK
echo "      state: present" >> $PLAYBOOK
echo "      regexp: '^%{{ grupo }}'" >> $PLAYBOOK
echo "      line: '%{{ grupo }} ALL=(ALL) NOPASSWD: ALL'" >> $PLAYBOOK
echo "      validate: '/usr/sbin/visudo -cf %s'" >> $PLAYBOOK

dos2unix /etc/ansible/hosts

exit 0
