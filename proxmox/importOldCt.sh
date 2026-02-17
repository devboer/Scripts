#!/usr/bin/env bash
set -euo pipefail
### -------------------------
### DEFAULTS
### -------------------------
OLD_CONFIG_DIR=""
CONFIG_DIR="/etc/pve/lxc"
TEMP_MOUNT="/mnt/temp"

DEFAULT_TEMPLATE="local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
ROOTFS_STORAGE="apps-pool"

SCRIPTS_SOURCE="/codebase/Scripts"
SCRIPTS_TARGET="/opt/code"

MEDIA_SOURCE="/media-pool/content"
MEDIA_TARGET="/opt/media"

APPDATA_BASE="/apps-pool/app-data"

BRIDGE_DEFAULT="vmbr1"
### -------------------------
### CLEANUP HANDLER
### -------------------------
cleanup() {
    pct unmount "$NEWID" 2>/dev/null || true
    umount "$TEMP_MOUNT" 2>/dev/null || true
}
trap cleanup EXIT

### -------------------------
### ARG PARSER
### -------------------------
OLDID="${1:-}"
NEWID="${2:-}"

shift 2 || true

MEDIA_FLAG=false
DATA_FLAG=false

for arg in "$@"; do
    case "$arg" in
        --media) MEDIA_FLAG=true ;;
        --data) DATA_FLAG=true ;;
        *) echo "Unknown flag $arg"; exit 1 ;;
    esac
done

if [[ -z "$OLDID" || -z "$NEWID" ]]; then
    echo "Usage: importOldCt.sh <oldid> <newid> [--media] [--data]"
    exit 1
fi

OLD_CONF="$OLD_CONFIG_DIR/$OLDID.conf"
RAW_IMG="/mnt/external/userdata/lxc${OLDID}.raw"

[[ -f "$OLD_CONF" ]] || { echo "Missing config"; exit 1; }
[[ -f "$RAW_IMG" ]] || { echo "Missing raw disk"; exit 1; }

mkdir -p "$TEMP_MOUNT"

### -------------------------
### CONFIG EXTRACTION
### -------------------------
config_extraction() {
HOSTNAME=$(grep '^hostname:' "$OLD_CONF" | awk '{print $2}')
CORES=$(grep '^cores:' "$OLD_CONF" | awk '{print $2}')
MEMORY=$(grep '^memory:' "$OLD_CONF" | awk '{print $2}')
SWAP=$(grep '^swap:' "$OLD_CONF" | awk '{print $2}')

NET_RAW=$(grep '^net0:' "$OLD_CONF" | cut -d' ' -f2-)

ONBOOT=$(grep '^onboot:' "$OLD_CONF" | awk '{print $2}' || true)
STARTUP=$(grep '^startup:' "$OLD_CONF" | cut -d' ' -f2- || true)
FEATURES=$(grep '^features:' "$OLD_CONF" | cut -d' ' -f2- || true)
SIZE=$(du -BG "$RAW_IMG" | awk '{print $1}')
}
### -------------------------
### NETWORK SANITIZER
### remove vlan tag
### replace bridge
### keep mac
### -------------------------
sanitize_net() {
    CLEAN=$(echo "$NET_RAW" | sed -E 's/,tag=[0-9]+//g')
    CLEAN=$(echo "$CLEAN" | sed -E 's/bridge=[^,]+/bridge='"$BRIDGE_DEFAULT"'/')
    echo "$CLEAN"
}
create_container() {
NET0=$(sanitize_net)

### -------------------------
### CREATE CONTAINER
### -------------------------
echo "Creating CT $NEWID from $OLDID"

pct create "$NEWID" "$DEFAULT_TEMPLATE" \
    --hostname "$HOSTNAME" \
    --cores "$CORES" \
    --memory "$MEMORY" \
    --swap "$SWAP" \
    --net0 "$NET0" \
    --rootfs "$ROOTFS_STORAGE:$SIZE"

[[ -n "$ONBOOT" ]] && pct set "$NEWID" --onboot "$ONBOOT"
[[ -n "$STARTUP" ]] && pct set "$NEWID" --startup "$STARTUP"
[[ -n "$FEATURES" ]] && pct set "$NEWID" --features "$FEATURES"
}
### -------------------------
### AUTO MOUNTPOINT INDEX
### -------------------------
get_next_mp() {
    CONF="$CONFIG_DIR/$NEWID.conf"
    grep -o '^mp[0-9]\+' "$CONF" 2>/dev/null | sed 's/mp//' | sort -n | tail -1 | awk '{print $1+1}' || echo 0
}

add_mount() {
    SRC="$1"
    DEST="$2"
    IDX=$(get_next_mp)
    pct set "$NEWID" -mp${IDX} "$SRC,mp=$DEST"
}
mount_options() {
### -------------------------
### SCRIPTS MOUNT
### -------------------------
add_mount "$SCRIPTS_SOURCE" "$SCRIPTS_TARGET"

### -------------------------
### OPTIONAL MEDIA
### -------------------------
if $MEDIA_FLAG; then
    add_mount "$MEDIA_SOURCE" "$MEDIA_TARGET"
fi

### -------------------------
### OPTIONAL APPDATA
### -------------------------
if $DATA_FLAG; then
    APP_PATH="$APPDATA_BASE/${NEWID}-${HOSTNAME}"
    mkdir -p "$APP_PATH"
    add_mount "$APP_PATH" "/opt/app-data"
fi
}
### -------------------------
### COPY FILESYSTEM
### -------------------------
copy_files(){
echo "Mounting old disk..."
mount -o loop "$RAW_IMG" "$TEMP_MOUNT"

pct mount "$NEWID"

echo "Syncing filesystem..."
rsync -aHAX --delete "$TEMP_MOUNT/" "/var/lib/lxc/$NEWID/rootfs/"

pct unmount "$NEWID"
umount "$TEMP_MOUNT"

echo "Clone complete → CT $NEWID"
}

### -------------------------
### EXECUTION
### -------------------------
main() {
config_extraction
create_container
mount_options
copy_files
echo "Script finished!"
}

main "$@"
