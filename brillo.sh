#!/bin/bash

# Script para controlar brillo de pantalla
# Guardar como control_brillo.sh y ejecutar con permisos

# Verificar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "Este script necesita permisos de administrador"
    echo "Por favor, ejecuta con: sudo ./brillo.sh"
    exit 1
fi

# Función para mostrar el menú
mostrar_menu() {
    clear
    echo "========================================"
    echo "    CONTROL DE BRILLO DE PANTALLA"
    echo "========================================"
    echo ""
    echo "1. Brillo al máximo (96000)"
    echo "2. Brillo mínimo (1)"
    echo "3. Apagar pantalla (0)"
    echo "4. Salir"
    echo ""
    echo "========================================"
    echo -n "Selecciona una opción [1-4]: "
}

# Bucle principal
while true; do
    mostrar_menu
    read opcion
    
    case $opcion in
        1)
            echo "Configurando brillo al máximo..."
            echo 96000 > /sys/class/backlight/intel_backlight/brightness
            echo "¡Brillo configurado al máximo!"
            sleep 2
            ;;
        2)
            echo "Configurando brillo mínimo..."
            echo 1 > /sys/class/backlight/intel_backlight/brightness
            echo "¡Brillo configurado al mínimo!"
            sleep 2
            ;;
        3)
            echo "Apagando pantalla..."
            echo 0 > /sys/class/backlight/intel_backlight/brightness
            echo "¡Pantalla apagada!"
            sleep 2
            ;;
        4)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción inválida. Por favor, selecciona 1, 2, 3 o 4."
            sleep 2
            ;;
    esac
done
