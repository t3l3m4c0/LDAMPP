#!/bin/bash

set -e  # Terminar el script si cualquier comando falla

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Este script debe ejecutarse con privilegios de root."
        exit 1
    fi
}

# Función para instalar paquetes en un orden específico
install_packages() {
    apt update
    for package in "$@"; do
        echo "Instalando $package..."
        if ! apt install -y "$package"; then
            echo "Error al instalar $package. Abortando la instalación."
            exit 1
        fi
    done
}

# Función para configurar phpMyAdmin
configure_phpmyadmin() {
    ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
    a2enconf phpmyadmin.conf
    systemctl restart apache2
}

# Llamada a la función para verificar los privilegios de root
check_root

# Llamada a la función para instalar paquetes en el orden específico
install_packages xclip mariadb-server apache2 php phpmyadmin

# Llamada a la función para configurar phpMyAdmin
configure_phpmyadmin

echo "Instalación y configuración completadas."
