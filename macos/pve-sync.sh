#! /bin/bash
# Directories
localData=/Users/austindeboer/Downloads/-Move-to-Server
pveMedia=/mnt/data/multimedia # gitRepo /multimedia/Books,Movies,Porn,TV_Shows,Notes
pveData=/mnt/data
title="PVE rsync upload to /mnt/data"
prompt="Pick an option:"
options=("Movies" "TV Shows" "YouTube" "Porn" "Books" "Documents" "Repo" "ISO Images")
server=sysadmin@192.168.1.103
sync=rsync -rav --progress --human-readable

echo "$title"
PS3="$prompt "
select opt in "${options[@]}" "Quit"; do

    case "$REPLY" in
    
    1 ) $sync $localData/01_Movies/* $server:$pveDIR/Movies;;
    2 ) $sync $localData/02_TV_Shows/* $server:$pveMedia/TV_Shows;;
    3 ) $sync $localData/03_YouTube/* $server:$pveMedia/YouTube;;
    4 ) $sync $localData/04_Porn/* $server:$pveMedia/Porn;;
    5 ) $sync $localData/06_Books/* $server:$pveMedia/Books;;
    6 ) $sync $localData/07_Documents/* $server:$pveMedia/Notes;;
    7 ) $sync $localData/08_Repo/* $server:$pveData/gitRepo;;
    8 ) $sync $localData/05_ISO_Images/* $server:$pveData/iso_images;;
    
    $(( ${#options[@]+1 )) ) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one.";continue;;
    
    esac
    
done