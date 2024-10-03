#!/bin/bash
##################  CONFIG Section #############
MP_PKG="morpheus-appliance_5.3.2-1_amd64.deb"
MP_URL_DN="https://downloads.morpheusdata.com/files"



################## CODE SECTION ################################
#    -------- Morpheus,Ansible installation Code below --------
################################################################

function run_cmd() {
#	echo -e "$(date "+%m%d%Y %T") : ------------ run command $1"
	RED='\033[0;31m'
	GR='\033[0;32m'
	NC='\033[0m' # No Color
	
	# Run Command string
	sudo ${@}
	
	# Get Return Status
	rc=$?
	
	if [ $rc -ne 0 ]
	then
		echo -e "$(date "+%m%d%Y %T") : ------------ Run command failed : ${@}"
		echo -e "$(date "+%m%d%Y %T") : ------------${RED} INSTALLATION FAILED : Admin intervention required ${NC}"
		echo -e "$(date "+%m%d%Y %T") : ------------${RED} INSTALLATION FAILED : Exiting installation ${NC}"
		exit 1;
	else
		echo -e "$(date "+%m%d%Y %T") : ------------${GR} Run Command Success ${NC} : ${@}"
	fi
	return $rc
}

function fail {
echo $1 >&2
exit 1
}

function retry {
local n=1
local max=5
local delay=60
while true; do
sudo ${@} && break || {
if [[ $n -lt $max ]]; then
((n++))
echo "Command failed. Attempt $n/$max:"
sleep $delay;
else
fail "The command has failed after $n attempts."
fi
}
done
}

## MAIN 

#main() {

	echo "####################################################################################"
	echo -e "$(date "+%m%d%Y %T") : ------------ The Ansible, Morpheus softwares start install"
	echo "####################################################################################"
	run_cmd apt-get update -y

	# Install Ansible and Morpheus Packages
	run_cmd wget "${MP_URL_DN}/${MP_PKG}"
	run_cmd dpkg -i ${MP_PKG}
	
	# Configure Morpheus with Custom onfigurations
	run_cmd morpheus-ctl reconfigure
	export APP_EXTERNAL_IP=`echo https://$(wget -qO - https://api.ipify.org)`
	run_cmd sed -i 's|'https://Linuxvm*'|'$APP_EXTERNAL_IP'|' /etc/morpheus/morpheus.rb

	#Reconfigure Morpheus with updated URL
	run_cmd morpheus-ctl reconfigure
	run_cmd morpheus-ctl stop morpheus-ui
	retry morpheus-ctl start morpheus-ui
	run_cmd morpheus-ctl status morpheus-ui
	run_cmd apt-get update -y
	run_cmd apt-get install software-properties-common -y
	run_cmd apt-add-repository ppa:ansible/ansible -y
	run_cmd apt-get install -y python-requests
	run_cmd apt-get install ansible -y
	run_cmd chown morpheus-local.morpheus-local /opt/morpheus/.local/.ansible
	run_cmd mkdir /opt/morpheus/.ansible
	run_cmd chown morpheus-local.morpheus-local /opt/morpheus/.ansible
	echo "####################################################################################"
	echo -e "$(date "+%m%d%Y %T") : ------------ The Ansible, Morpheus softwares are installed sucessfully on $a server"
	echo "####################################################################################"
#}
