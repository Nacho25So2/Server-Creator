#!/bin/bash

read -p "Ingrese la clave " ssh_key

mkdir -p ~/.ssh
echo "$ssh_key" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
echo Clave guardada con exito.	