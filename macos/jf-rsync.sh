#! /bin/bash

transfer () {

dlDIR=/Users/austindeboer/Downloads/-Move_to_Server
pveDIR=/home/admin/data

read -p "Movies [1], TV [2], YouTube [3] to transfer? Answer: # " DIR

if [ $DIR == 1 ] 
then
     localMedia=01_Movies
     dlDIR=$dlDIR/$localMedia/*/*.*
     pveMedia=Movies
     pveDIR=$pveDIR/$pveMedia
elif [ $DIR == 2 ]
then   
     localMedia=02_TV_Shows
     dlDIR=$dlDIR/$localMedia/*/*.*
     pveMedia=TV_Shows 
     pveDIR=$pveDIR/$pveMedia 
elif [ $DIR = 3 ]
then
     localMedia=03_YouTube
     dlDIR=$dlDIR/$localMedia/*.*
     pveMedia=YouTube
     pveDIR=$pveDIR/$pveMedia
else
    echo "Oops try again";
    transfer
fi

rsync -rav --progress --human-readable $dlDIR admin@192.168.50.20:$pveDIR

}

transfer
