read -p "Old Container ID? " oVMID
mount -o loop /mnt/external/userdata/lxc$oVMID.raw /mnt/temp

sleep 1

echo "Old Container Stats to Mimic"
cat /opt/lxc/$oVMID.conf | grep hostname
cat /opt/lxc/$oVMID.conf | grep cores
cat /opt/lxc/$oVMID.conf | grep memory
cat /opt/lxc/$oVMID.conf | grep swap
cat /opt/lxc/$oVMID.conf | grep net0
df -h /mnt/temp

sleep 20

read -p "New Container ID? " nVMID
SOURCE_DIR=/mnt/temp/
MOUNT_DIR=/var/lib/lxc/$nVMID/rootfs/

pct mount $nVMID
echo "New Container Mounted, Ready to RSYNC"

rsync -avPH --delete $SOURCE_DIR $MOUNT_DIR
echo "Copy Complete"

sleep 1

echo "VERIFYING"
ls -l /var/lib/lxc/$nVMID/rootfs/opt

sleep 3

pct unmount $nVMID
echo "Container $nVMID Unmounted" 
umount /mnt/temp
echo "Disk $oVMID Unmounted"

echo "DONE"
