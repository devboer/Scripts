#! /usr/bin/env bash
# Quick edit lxc conf
# Mobile friendly
#
#read -p "Editing which ID? " VMID

nvim /etc/pve/lxc/$1.conf
