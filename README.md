# Crear un servidor en casa

## Instalar sistema operativo
Es recomendable utilizar Debian para estos servidores debido a la compatibilidad. Pero tambien se puede utilizar Ubuntu o Ubuntu Server.

En mi caso voy a usar Debian.

1. Descargar la ultima version de [Debian](https://www.debian.org/distrib/netinst).
2. Usar [Balena Etcher](https://etcher.balena.io/#download-etcher) para quemar el iso.
3. Seguir los pasos de instalación y al final podras elegir un entorno grafico o no usar entorno, en mi caso desactivar las opciones de entorno grafico y dejar Utilidades del sistema y Server SSH.
4. Terminar la instalacion.

## Requisitos previos de instalación

### Instalar Sudo
```
su -
apt update
apt install sudo
usermod -aG sudo na_juan25
```

Cerrar sesion usando `exit` dos veces, o reiniciar usando `reboot`.

### IPs Fijas
**Metodo 1 (recomendado):**

La mayoria de routers dejan elegir una ip fija a un dispositivo en concreto, ingresando al panel del router `192.168.1.1` desde el navegador y en la parte de `Avanzados > Lan` podras encontrar **Configuración de IP estática DHCP**.

Este te va a pedir la direccion MAC de tu dispositivo y una ip fija que va de `192.168.1.2` hasta `192.168.1.255`.

Para encontrar la direccion MAC, en consola escribir `ip a` devolviendo un resultado similar a:
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo ...
2: enx00e04c68002f: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:e0:4c:68:00:2f brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.69/24 brd 192.168.1.255 scope global dynamic noprefixroute enx00e04c68002f ...
3: wlo2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 3c:21:9c:bf:e6:f4 brd ff:ff:ff:ff:ff:ff
    altname wlp0s12f0
    altname wlx3c219cbfe6f4
    inet 192.168.1.70/24 brd 192.168.1.255 scope global dynamic noprefixroute wlo2 ...
```
Pueden aparecer mas o menos, pero lo importante es identificar nuestro dispositivo de red, en mi caso `wlo2` es wifi y `enx00e04c68002f` es ethernet, en la linea que dice `link/ether` los numeros siguientes es el MAC del dispositivo. En el apartado de `inet` podras ver la ip asignada actualmente.

Una vez asignada en el panel del router solamente es reiniciar el equipo usando `sudo reboot` y listo.

**Metodo 2:**

> [!NOTE]
> Este metodo solo funcionará con ethernet hasta donde probe.

Editamos el archivo `interfaces`
```
sudo nano /etc/network/interfaces
```

Y tendremos que agregar lo siguiente:
```
# Ethernet
auto enx00e04c68002f
iface enx00e04c68002f inet static
    address 192.168.1.69/24
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 192.168.1.1
```
> [!TIP]
> Para guardar usar `CTRL + O` y despues `ENTER`, para salir usar `CTRL + X`. Abajo sale los comandos para utilizar si ves `^X` hace referencia a `CTRL + X` siendo `^` una referencia a `CTRL`.

Siendo `enx00e04c68002f` el nombre de mi dispositivo ethernet. En el caso de ustedes remplazar por el nombre de su dispositivo y la ip en `address 192.168.1.x/24`.

Ejecutar:
```
sudo systemctl restart networking
```
Y ya tendríamos ip fija.

> [!NOTE]
> Si usaste el primer método y pusiste la MAC de tu ethernet cambiar la palabra `static` por `dhcp`.

En caso de haber hecho la instalacion de Debian usando ethernet y quieres usar WiFi agregar al archivo `interfaces` lo siguiente:
```
# WiFi
allow-hotplug wlo2
iface wlo2 inet dhcp
        wpa-ssid nombre del wifi
        wpa-psk  contraseña del wifi
```
Siendo `wlo2` el nombre del dispositivo de red wifi, se puede ver en `ip a`.


### Desactivar suspension de tapa
Si usas una laptop lo mejor es desactivar la suspension.
```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

### Apagar pantalla
Es recomendable apagar la pantalla o reducir el brillo ya que baja el consumo unos 6W

```
sudo wget -O /usr/local/bin/brillo_set.sh https://raw.githubusercontent.com/Nacho25So2/Server-Creator/refs/heads/desarollo/brillo_set.sh
sudo chmod +x /usr/local/bin/brillo_set.sh
sudo wget -O /etc/systemd/system/apagar-pantalla.service https://raw.githubusercontent.com/Nacho25So2/Server-Creator/refs/heads/desarollo/apagar-pantalla.service
sudo systemctl enable apagar-pantalla.service
sudo systemctl start apagar-pantalla.service
sudo systemctl status apagar-pantalla.service
```

### Instalar BTOP
BTop es un monitor, este nos ayudará a ver bateria, uso de memoria y almacenamiento, procesos, temperaturas entre otros, es recomendable instalarlo para registrar temperaturas entre otros.
```
sudo apt install btop
```
usar `btop` para ver el monitor.

## Instalar [Pterodactyl](https://github.com/pterodactyl-installer/pterodactyl-installer)
```
su-
apt install -y curl
bash <(curl -s https://pterodactyl-installer.se)
```
> [!TIP]
> Si no tienes el panel, elegir la opcion **2** ya que instalará el panel y el nodo para crear servidores.
> Sí ya tienes un panel y tienes otra pc para servidor instalar la opcion **1** que es solo el nodo.
> En caso de querer separar el panel de las PCs e instalar en otro dispositivo usar la opcion **0** instala solo el panel.

> [!WARNING]
> En el script dar todo que si salvo estas opciones debido a problemas en seguridad:

* Datos para la instalación:
**Timezone: America/Montevideo**

Una vez instalado todo entrar al panel `192.168.1.x` y crear un lugar y un nodo, en el apartado de *Fully Qualified Domain Name* o **FQDN** agregar la ip de ZeroTier o ingresar la ip local `192.168.1.x`.

Agregar 46080 MiB (45GB) de **DISK** y 6656 MiB (6.5 GB) de **MEMORY**.
En la pestaña de *Allocation* ingresar en `IP Address` la ip `0.0.0.0` y en `ports` los puertos `25565 7777 19132` y enviar.

Estas ip son asignadas a los servidores creados y es necesario el de la ip para que funcione con ZeroTier.
> [!NOTE]
> Los puertos son únicos por ip, por lo que si tienes 2 servidores de Minecraft, uno tendra 25565 y otro 19132, si te quedas sin puertos, volves al nodo y agregas mas y todos los puertos que necesites. El limite esta en `65535`.

## Configurar [Wings](https://pterodactyl.io/wings/1.0/installing.html)
```
sudo nano /etc/pterodactyl/config.yml
```
Pegar la configuracion del nodo que se encuentra en la pestaña `configuration`.
```
sudo wings --debug
```
Sirve para comprobar errores, si no presenta, proseguir usando `CTRL + C`

Inicia wings
```
sudo systemctl enable --now wings
```
Volvemos a editar el archivo:
```
sudo nano /etc/pterodactyl/config.yml
```
Y en el apartado de `allowed_origins:` agregar tu ip local y tu ip de ZeroTier.
```
allowed_origins:
  - http://192.168.1.69   # LAN del servidor
  - http://172.30.27.63   # IP ZeroTier del Nodo
```
Esto permite acceder a los nodos y consolas de servidores mediante zerotier o en local.

Reinicia wings
```
sudo systemctl restart wings
```

## Instalar [ZeroTier One](https://www.zerotier.com/download/)
```
curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/main/doc/contact%40zerotier.com.gpg' | gpg --import && \
if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
```

Para conectarme a una network:
```
sudo zerotier-cli join (id)
```
Para comprobar que estamos en la network
```
sudo zerotier-cli listnetworks
```
Tendrá que decir "OK", tambien puedes sacar la ip de ZeroTier de tu nodo.

## Instalar [Playit](https://playit.gg/download/linux)
```
curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
sudo apt update
sudo apt install playit
su -
sudo systemctl enable --now playit
sudo playit setup
```
Conectarse y crear agentes y tuneles todo eso, una vez terminado salir.

comprobar usando
```
sudo cat /var/log/playit/playit.log
```

Para terminar usar `sudo reboot` y listo para usar.

## Datos y comparaciones

Estas pruebas se realizaron en una Laptop con especificaiones:
* **CPU**: Intel Celeron N4020
* **RAM**: 8GB
* **ROM**: 64GB

Una vez terminada la instalación por completo, el consumo de ram esta en 700MiB siendo utilizados 500MiB solamente por el panel de Pterodactyl. Para observar su consumo utilizar `btop`.

#### Tabla comparativa con entornos graficos

Sin iniciar sesion

| Entorno gráfico | Ram al inicio | Ram al terminar |
|-----------------|:-------------:|:---------------:|
| Sin entorno     | 200 MiB       | 700 MiB         |
| LXQt            | 250 MiB       | 800 MiB         |
| GNOME           | 400 MiB       | 900 MiB         |

Con sesion iniciada

| Entorno gráfico |      RAM      |
|-----------------|:-------------:|
| Sin entorno     | 716 MiB       |
| LXQt            | 1000 MiB      |
| GNOME           | 1.2 GiB       |

> [!TIP]
> Se puede desactivar el bluetooth para tener un menor consumo de recursos, en el apartado de ram bluetooth ocupa 6 MiB, si no se utiliza mejor desactivar: `sudo systemctl stop --now bluetooth.service`

# Otros

## Activar audio sink de bluetooth
```
sudo apt install \
pipewire \
pipewire-audio \
pipewire-pulse \
wireplumber \
pulseaudio-utils \
libspa-0.2-bluetooth \
blueman
```

## Subir volumen a 100%
```
wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0
```
> [!TIP]
> Modificando el "1.0" cambias el volumen siendo 1 = 100%
