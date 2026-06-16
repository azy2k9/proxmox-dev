#!/usr/bin/env bash
source <(curl -fsSL https://git.community-scripts.org/community-scripts/ProxmoxVE/raw/branch/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Authors: MickLesk (CanbiZ) | Co-Author: remz1337
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://frigate.video/ | Github: https://github.com/blakeblackshear/frigate

APP="Frigate"
var_tags="${var_tags:-nvr}"
var_cpu="${var_cpu:-8}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-20}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_arm64="${var_arm64:-no}"
var_unprivileged="${var_unprivileged:-0}"
var_gpu="${var_gpu:-yes}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
    header_info
    check_container_storage
    check_container_resources
    if [[ ! -f /etc/systemd/system/frigate.service ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi
    msg_error "To update Frigate, create a new container and transfer your configuration."
    exit
}

start
build_container


# ============================================================================
# Optional: Mount storage for Frigate recordings
# ============================================================================

STORAGE_NAME="cctv"
MOUNT_SIZE="6000"  # This is in GB for pct set
MOUNT_POINT="/media/frigate"

if pvesm status | awk 'NR>1 {print $1}' | grep -qx "$STORAGE_NAME"; then
    msg_info "Mounting Proxmox storage '$STORAGE_NAME' to $MOUNT_POINT"
    pct set "$CTID" -mp0 "${STORAGE_NAME}:${MOUNT_SIZE},mp=${MOUNT_POINT}"
    # echo "mp0: cctv:subvol-${CTID}-disk-0,mp=/media/frigate,size=6000G" >> /etc/pve/lxc/${CTID}.conf
    msg_ok "Mounted storage '$STORAGE_NAME' to $MOUNT_POINT"
else
    msg_warn "Proxmox storage '$STORAGE_NAME' not found. Skipping mount point."
    msg_info "To add storage: zpool create cctv /dev/sdX && pvesm add zfspool cctv -pool cctv"
fi

description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW}Access it using the following URL:${CL}"
echo -e "${GATEWAY}${BGN}http://${IP}:5000${CL}"
