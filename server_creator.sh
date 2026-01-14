#!/bin/bash

# Verificar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "Este script necesita permisos de administrador"
    echo "Por favor, ejecuta con "su -""
    exit 1
fi

# Desactivar suspension de tapa
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Actualizar y actualizar repos
apt update -y && apt upgrade -y
apt install -y curl

# Instalar BTOP
apt install btop

# Instalar ZeroTier One
curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/main/doc/contact%40zerotier.com.gpg' | gpg --import && \ if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi

zerotier-cli join $ztNetworkID

# Instalar PlayIT
curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
sudo apt update
sudo apt install playit
sudo systemctl enable --now playit
sudo playit setup

# Instalar Pterodactyl
bash <(curl -s https://pterodactyl-installer.se)


# Instalar lm-sensors para tener toda informacion de sensores
apt install lm-sensors

sudo sensors-detect
