#! /usr/bin/env bash
TEMPLATE=""
SEARCH_DOMAIN=""
NAME_SERVER=""
GW_ADDRESS="192.168.50.1"
VLAN="50"
SWAP_MEM=0

read -p "Container ID # " LXC_ID
read -p "Hostname? " HOSTNAME
sleep 1
read -p "Root password " ROOT_PW
sleep 1
read -p "CPU Core Allocation (1-2) " CPU_NUM
sleep 1
read -p "RAM Allocation (up to 16GB) in MB " RAM_MEM
sleep 1
read -p "SWAP Allocation (default 0) in MB " SWAP_MEM
read -p "IP Address - last 3: " IP_ADDRESS

sudo pct create $LXC_ID sas-storage:vztmpl/$TEMPLATE \
  --storage sas-lvm --rootfs volume=sas-lvm:16 \
  --ostype debian --arch amd64 --password $ROOT_PW --unprivileged 1 \
  --cores $CPU_NUM --memory $RAM_MEM --swap $SWAP_MEM \
  --hostname $HOSTNAME --searchdomain $SEARCH_DOMAIN --nameserver $NAME_SERVER \
  --net0 name=eth0,bridge=vmbrxx,ip=192.168.$VLAN.$IP_ADDRESS/24,gw=$GW_ADDRESS,type=veth \
  --start true