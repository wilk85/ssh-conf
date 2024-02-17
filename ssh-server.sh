#!/bin/bash
# start script on system to setup ssh server

function install_ssh {
    sudo apt install openssh-client openssh-server -y
}

function sshd_backup {
    sudo cp /etc/ssh/sshd_config ~/sshd_config.bkp
    sudo chmod a-w ~/sshd_config.bkp
}

function setup_remote_user {
    remoteUser='remote'
    sudo useradd -m -s /bin/bash "$remoteUser"
    sudo usermod -aG sudo "$remoteUser"
}

function firewall {
    ufwStatus=$(sudo ufw status | head -n 1 | cut -d ':' -f2 | tr -d " ")
    if [[ "$ufwStatus" == "nieaktywny" || "$ufwStatus" == "notactive" ]]; then
        sudo ufw enable
    fi

    sudo ufw allow 1022/tcp
}

function copy_sshd_config {
    sudo cp sshd_config.new /etc/ssh/sshd_config
}

function start_ssh_svc {
    sudo systemctl enable --now ssh
}


# install_ssh
# sshd_backup
# setup_remote_user
# copy_sshd_config
firewall
# start_ssh_svc


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