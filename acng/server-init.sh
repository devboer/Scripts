#!/bin/bash
# Run as root on the Apt-Cacher NG Server

echo "--- Configuring Apt-Cacher NG Server ---"

# 1. Create Backend Files for HTTPS Repos
echo "https://download.docker.com/linux/debian" | sudo tee /etc/apt-cacher-ng/backends_docker
echo "https://pkgs.tailscale.com/stable/debian" | sudo tee /etc/apt-cacher-ng/backends_tailscale

# 2. Append Remap rules to acng.conf (if not already there)
# Note: Bookworm and Trixie share the standard debian.org mirrors, which are cached by default.
cat <<EOF | sudo tee -a /etc/apt-cacher-ng/acng.conf

# Custom Remaps for HTTPS Repos
Remap-docker: http://docker.mirror ; file:backends_docker
Remap-tailscale: http://tailscale.mirror ; file:backends_tailscale

# Enable PassThrough for other HTTPS traffic
PassThroughPattern: .*
EOF

# 3. Install Avahi-Utils for Discovery
sudo install avahi-utils -y

# 4. Restart the service
sudo systemctl restart apt-cacher-ng
echo "--- Server configuration complete! ---"
