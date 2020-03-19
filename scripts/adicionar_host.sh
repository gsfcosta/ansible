#!/bin/bash

##################################################################################
function ADDHOST(){
while (( $INDICE != $INDICE_TOTAL)); do
	echo "---" > $PLAYBOOK
	echo "- name: Adiconando hosts do arquivo $ARQUIVO" >> $PLAYBOOK
	echo "  hosts: $ANSIBLE_HOSTS" >> $PLAYBOOK
	echo "  tasks:" >> $PLAYBOOK
	echo " " >> $PLAYBOOK
	echo "  - name: Criando host ${HOSTNAME[$INDICE]}" >> $PLAYBOOK
	echo "    local_action:" >> $PLAYBOOK
	echo "        module: zabbix_host" >> $PLAYBOOK
	echo "        server_url: $URL" >> $PLAYBOOK
	echo "        login_user: $USERNAME" >> $PLAYBOOK
	echo "        login_password: $PASSWORD" >> $PLAYBOOK
	echo "        host_name: ${HOSTNAME[$INDICE]}" >> $PLAYBOOK
	echo "        visible_name: ${VISIBLE_NAME[$INDICE]}" >> $PLAYBOOK
	echo "        description: ${DESCRIPTION[$INDICE]}" >> $PLAYBOOK
	echo "        host_groups:" >> $PLAYBOOK

	IFS=',' read -r -a HOSTGROUP <<< "${HOSTG[$INDICE]}"
	INDICE2=0
	IND=$(echo ${#HOSTGROUP[@]})
	if (( $IND == 1 )); then
		echo "            - ${HOSTG[$INDICE]}" >> $PLAYBOOK
	else
		while (( $INDICE2 != $IND )); do
			echo "            - ${HOSTGROUP[$INDICE2]}" >> $PLAYBOOK
			let INDICE2=($INDICE2+1)
		done
	fi

	echo "        link_templates:" >> $PLAYBOOK

	IFS=',' read -r -a TEMPLATE <<< "${TEMP[$INDICE]}"

	INDICE2=0
	IND=$(echo ${#TEMPLATE[@]})
	if (( $IND == 1 )); then
		echo "            - ${TEMP[$INDICE]}" >> $PLAYBOOK
	else
		while (( $INDICE2 != $IND )); do
			echo "            - ${TEMPLATE[$INDICE2]}" >> $PLAYBOOK
			let INDICE2=($INDICE2+1)
		done
	fi
	echo "        status: $STATUS" >> $PLAYBOOK
	echo "        state: present" >> $PLAYBOOK
	echo "        inventory_mode: $INVENTARIO" >> $PLAYBOOK
	echo "        interfaces:" >> $PLAYBOOK
	echo "            - type: ${INTERFACE_TYPE[$INDICE]}" >> $PLAYBOOK
	echo "              main: $DEFAULT" >> $PLAYBOOK
	echo "              useip: ${INTERFACE_MODE[$INDICE]}" >> $PLAYBOOK
	case ${INTERFACE_MODE[$INDICE]} in
		1) echo "              ip: ${IP_DNS[$INDICE]}" >> $PLAYBOOK;;
		0) echo "              dns: "${IP_DNS[$INDICE]}"" >> $PLAYBOOK;;
	esac
	echo "              port: ${PORTA[$INDICE]}" >> $PLAYBOOK
	echo "        proxy: ${PROXY[$INDICE]}" >> $PLAYBOOK

	ansible-playbook $PLAYBOOK

	IFS=';' read -r -a TOTAL_LINE <<< "${TOTAL[$INDICE]}"
	IND_TOTAL_LINE=${#TOTAL_LINE[@]}
	if (( $IND_TOTAL_LINE > 10 )); then
		MACRO
	else
		let INDICE=($INDICE+1)
	fi
done
exit 0
}
##############################################################################################
function MACRO(){
while (( $INDICE != $INDICE_SUB )); do
	echo "---" > $PLAYBOOK
	echo "- name: Adicionando macros aos hosts do arquivo $ARQUIVO" >> $PLAYBOOK
	echo "  hosts: $ANSIBLE_HOSTS" >> $PLAYBOOK
	echo "  tasks:" >> $PLAYBOOK
	echo " " >> $PLAYBOOK
	echo "  - name: Criando macros no host ${HOSTNAME[$INDICE]}" >> $PLAYBOOK
	echo "    local_action:" >> $PLAYBOOK
	echo "        module: zabbix_hostmacro" >> $PLAYBOOK
	echo "        server_url: $URL" >> $PLAYBOOK
	echo "        login_user: $USERNAME" >> $PLAYBOOK
	echo "        login_password: $PASSWORD" >> $PLAYBOOK
	echo "        host_name: ${HOSTNAME[$INDICE]}" >> $PLAYBOOK

	IFS=',' read -r -a MACRO_NAME <<< "${MACRO_N[$INDICE]}"
	IFS=',' read -r -a MACRO_VALUE <<< "${MACRO_V[$INDICE]}"

	IND_NAME=${#MACRO_NAME[@]}
	IND_VALUE=${#MACRO_NAME[@]}

	INDICE2=0
	if (( $IND_NAME == 1 )); then
		echo "        macro_name: ${MACRO_N[$INDICE]}" >> $PLAYBOOK
		echo "        macro_value: ${MACRO_V[$INDICE]}" >> $PLAYBOOK
	else
		echo "        macro_name: ${MACRO_NAME[$INDICE2]}" >> $PLAYBOOK
		echo "        macro_value: ${MACRO_VALUE[$INDICE2]}" >> $PLAYBOOK
		echo "        state: present" >> $PLAYBOOK
		
		ansible-playbook $PLAYBOOK

		MACRO2
	fi
	echo "        state: present" >> $PLAYBOOK

	ansible-playbook $PLAYBOOK

	let INDICE=($INDICE+1)
	ADDHOST
done
exit 0
}
################################################################################################
function MACRO2(){
let INDICE2=($INDICE2+1)

while (( $INDICE2 != $IND_NAME )); do
	echo "---" > $PLAYBOOK
	echo "- name: Adicionando macros aos hosts do arquivo $ARQUIVO" >> $PLAYBOOK
	echo "  hosts: $ANSIBLE_HOSTS" >> $PLAYBOOK
	echo "  tasks:" >> $PLAYBOOK
	echo " " >> $PLAYBOOK
	echo "  - name: Criando macros no host ${HOSTNAME[$INDICE]}" >> $PLAYBOOK
	echo "    local_action:" >> $PLAYBOOK
	echo "        module: zabbix_hostmacro" >> $PLAYBOOK
	echo "        server_url: $URL" >> $PLAYBOOK
	echo "        login_user: $USERNAME" >> $PLAYBOOK
	echo "        login_password: $PASSWORD" >> $PLAYBOOK
	echo "        host_name: ${HOSTNAME[$INDICE]}" >> $PLAYBOOK
	echo "        macro_name: ${MACRO_NAME[$INDICE2]}" >> $PLAYBOOK
	if (( $IND_VALUE == 1 )); then
		echo "        macro_value: " >> $PLAYBOOK
	else
		echo "        macro_value: ${MACRO_VALUE[$INDICE2]}" >> $PLAYBOOK
	fi
	echo "        state: present" >> $PLAYBOOK

	ansible-playbook $PLAYBOOK

	let INDICE2=($INDICE2+1)
done
let INDICE=($INDICE+1)
ADDHOST
exit 0
}

# VARIÁVEIS DE ARQUIVOS

PLAYBOOK="/etc/ansible/playbooks/play_adicionar_host.yml"
PASTA_TEMP="/tmp"

# VÁRIAVEIS ZABBIX

# CASO FOR ADICIONAR MAIS DE UM GRUPO, DESCOMENTE AS VARIAVEIS NECESSÁRIAS E COLOQUE O NOME DO GRUPO.
# CASO NECESSITE INCLUIR MAIS HOSTGROUPS/TEMPLATES, SEGUIR A SEQUENCIA, EXEMPLO: HOSTGROUP4="nome", E COPIAR A LINHA 3113 DO SCRIPT, ALTERANDO ASSIM COMO AS ANTERIORES.

DEFAULT=1 #1 - SIM $0 - NÃO
INVENTARIO="disabled" #automatic #manual #disabled
STATUS="enabled" #enabled #disabled
URL="http://172.17.27.23:8080" #URL Zabbix
USERNAME="svcacc_ansible"
PASSWORD="sun123*compasso"
ANSIBLE_HOSTS="rundeck"
ARQUIVO="/tmp/arquivo.csv"

##################################################################################

cat $ARQUIVO | cut -d';' -f1 | sed '1d' > $PASTA_TEMP/hostname
INT=$(tr '\n' ';' < $PASTA_TEMP/hostname)
IFS=';' read -r -a HOSTNAME <<< "$INT"
cat $ARQUIVO | cut -d';' -f2 | sed '1d' > $PASTA_TEMP/visible_name
INT=$(tr '\n' ';' < $PASTA_TEMP/visible_name)
IFS=';' read -r -a VISIBLE_NAME <<< "$INT"
cat $ARQUIVO | cut -d';' -f3 | sed '1d' > $PASTA_TEMP/hostgroup
INT=$(tr '\n' ';' < $PASTA_TEMP/hostgroup)
IFS=';' read -r -a HOSTG <<< "$INT"
cat $ARQUIVO | cut -d';' -f4 | sed '1d' > $PASTA_TEMP/template
INT=$(tr '\n' ';' < $PASTA_TEMP/template)
IFS=';' read -r -a TEMP <<< "$INT"
cat $ARQUIVO | cut -d';' -f5 | sed '1d' >  $PASTA_TEMP/interface_type
INT=$(tr '\n' ';' < $PASTA_TEMP/interface_type)
IFS=';' read -r -a INTERFACE_TYPE <<< "$INT"
cat $ARQUIVO | cut -d';' -f6 | sed '1d' > $PASTA_TEMP/porta
INT=$(tr '\n' ';' < $PASTA_TEMP/porta)
IFS=';' read -r -a PORTA <<< "$INT"
cat $ARQUIVO | cut -d';' -f7 | sed '1d' > $PASTA_TEMP/interface_mode
INT=$(tr '\n' ';' < $PASTA_TEMP/interface_mode)
IFS=';' read -r -a INTERFACE_MODE <<< "$INT"
cat $ARQUIVO | cut -d';' -f8 | sed '1d' > $PASTA_TEMP/ip_dns
INT=$(tr '\n' ';' < $PASTA_TEMP/ip_dns)
IFS=';' read -r -a IP_DNS <<< "$INT"
cat $ARQUIVO | cut -d';' -f9 | sed '1d' > $PASTA_TEMP/description
INT=$(tr '\n' ';' < $PASTA_TEMP/description)
IFS=';' read -r -a DESCRIPTION <<< "$INT"
cat $ARQUIVO | cut -d';' -f10 | sed '1d' > $PASTA_TEMP/proxy
INT=$(tr '\n' ';' < $PASTA_TEMP/proxy)
IFS=';' read -r -a PROXY <<< "$INT"
cat $ARQUIVO | cut -d';' -f11 | sed '1d' > $PASTA_TEMP/macro_name
INT=$(tr '\n' ';' < $PASTA_TEMP/macro_name)
IFS=';' read -r -a MACRO_N <<< "$INT"
cat $ARQUIVO | cut -d';' -f12 | sed '1d' > $PASTA_TEMP/macro_value
INT=$(tr '\n' ';' < $PASTA_TEMP/macro_value)
IFS=';' read -r -a MACRO_V <<< "$INT"
cat $ARQUIVO | sed '1d' > $PASTA_TEMP/total_line
INT=$(tr '\n' '#' < $PASTA_TEMP/total_line)
IFS='#' read -r -a TOTAL <<< "$INT"
INDICE_TOTAL=$(echo ${#HOSTNAME[@]})
INDICE_SUB=$(echo ${#HOSTNAME[@]})
INDICE=0
ADDHOST

exit 0
