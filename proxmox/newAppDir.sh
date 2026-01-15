read -p "New hostname? " NAME
read -p "New container ID? " CTID
APPDIR=/media-pool/app-data/$CTID\_$NAME
echo "Congrats! Your new directory is here: " $APPDIR
mkdir -p $APPDIR
chown -R :10000 $APPDIR
chmod -R 775 $APPDIR
