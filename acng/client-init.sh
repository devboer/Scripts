#!/bin/bash
# Run as root on the Client (Trixie/Bookworm)
PROXY_IP="10.0.40.5" # Change this to your AC NG server

echo "--- Configuring Client to use $PROXY_IP ---"

# 1. Set global Apt Proxy
echo "Acquire::http::Proxy \"http://$PROXY_IP:3142\";" | sudo tee /etc/apt/apt.conf.d/00aptproxy

# 2. Fix Docker Source (if exists)
if [ -f /etc/apt/sources.list.d/docker.list ]; then
    sudo sed -i "s|https://download.docker.com|http://docker.mirror|g" /etc/apt/sources.list.d/docker.list
fi

# 3. Fix Tailscale Source (if exists)
if [ -f /etc/apt/sources.list.d/tailscale.list ]; then
    sudo sed -i "s|https://pkgs.tailscale.com|http://tailscale.mirror|g" /etc/apt/sources.list.d/tailscale.list
fi

# 4. Test it
sudo apt update
sudo apt install -y avahi-utils
echo "--- Client configuration complete! ---"
