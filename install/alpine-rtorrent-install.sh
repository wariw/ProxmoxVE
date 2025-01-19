#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apk add newt
$STD apk add curl
$STD apk add openssh
$STD apk add nano
$STD apk add mc
msg_ok "Installed Dependencies"

msg_info "Installing rTorrent BitTorrent client"
$STD apk add rtorrent

mkdir -p /etc/rtorrent/
curl -Ls "https://raw.githubusercontent.com/wiki/rakshasa/rtorrent/CONFIG-Template.md" \
    | sed -ne "/^######/,/^### END/p" \
    | sed -re "s:/home/USERNAME:/etc/rtorrent:" >/etc/rtorrent/.rtorrent.rc

cat <<\EOF > /etc/init.d/rtorrent
#!/sbin/openrc-run

name="rTorrent BitTorrent client"
description="rTorrent BitTorrent client"

: ${cfgfile:="/etc/rtorrent/.${RC_SVCNAME#rtorrent.}.rc"}

command="/usr/sbin/rtorrent"
# mosquitto_args is here for backward compatibility only
# command_args="-c $cfgfile ${command_args:-$mosquitto_args}"
command_args=" -n -o 'import=$cfgfile,system.daemon.set=true'"
command_background="yes"
pidfile="/run/$RC_SVCNAME.pid"

required_files="$cfgfile"
EOF
chmod 644 /etc/init.d/rtorrent

# $STD rc-update add rtorrent
# $STD rc-service rtorrent start
msg_ok "Installed rTorrent BitTorrent client"

motd_ssh
customize
