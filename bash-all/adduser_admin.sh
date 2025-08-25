#! /usr/bin/env bash

# Automate my shared data user amongst my virtual servers.

addgroup --gid 118 shared-data
# Making this user system user hasn't created a home dir so it is specified
adduser --system \
        --home /home/admin \
        --uid 110 \
        --gid 118 \
        admin

# Assuming sudo is available
chmod -aG sudo admin
passwd admin && su admin