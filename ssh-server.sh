#!/bin/bash
# start script on system to setup ssh server

function get_info {
    local desktopEnvecho=$("$XDG_CURRENT_DESKTOP")
    local displayManager=$(sudo cat /etc/X11/default-display-manager)
    if [[ "$desktopEnvecho" != "XFCE" || "$displayManager" != "lightdm" ]]; then
        echo "Desktop env is not XFCE, or display manager is not lightdm, exit"
        exit
    fi
}

function install_ssh {
    echo " + Install openssh packages"
    sudo apt install openssh-client openssh-server -y
}

function sshd_config {
    echo " + Configure sshd" 
    sudo cp -v /etc/ssh/sshd_config ${HOME}/sshd_config.bkp
    sudo cp -v ${PWD}/sshd_config.new /etc/ssh/sshd_config
    sudo chmod a-w ${HOME}/sshd_config.bkp
}

function setup_remote_user {
    echo " + Setup remote user, disable showing remote use in lightdm"
    local remoteUser='remote'
    sudo useradd -m -s /bin/bash "$remoteUser"
    sudo usermod -aG sudo "$remoteUser"
    sudo cp ${PWD}/remote "/var/lib/AccountsService/users/$remoteUser"
}

function firewall_config {
    echo " + Configure firewall for ssh"
    local ufwStatus=$(sudo ufw status | head -n 1 | cut -d ':' -f2 | tr -d " ")
    if [[ "$ufwStatus" == "nieaktywny" || "$ufwStatus" == "notactive" ]]; then
        sudo ufw enable
    fi

    sudo ufw allow 1022/tcp
}

function start_ssh_svc {
    echo " + Start ssh service"
    sudo systemctl enable --now ssh
}

get_info
install_ssh
sshd_config
setup_remote_user
firewall_config
start_ssh_svc


# https://ubuntu.com/server/docs/service-openssh
# https://www.cyberciti.biz/faq/how-to-disable-ssh-password-login-on-linux/
# https://ubuntu.com/server/docs/service-openssh
# https://serverfault.com/questions/684346/ssh-copy-id-permission-denied-publickey
# ssh configuration check
# sudo sshd -t -f /etc/ssh/sshd_config


# for adding ssh keys to remote server, set PasswordAuthentication yes in sshd_config
# use ssh-copy-id -i [public key] host
# then ssh to server
# on server set PasswordAuthentication no and sudo systemctl restart ssh
# ssh user@host -p 1022 -i [priv key]