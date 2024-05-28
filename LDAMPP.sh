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

echo "Que usuario quieres utilizar en PHPmyAdmin?."
read usuario
echo "Que password quieres utilizar en PHPmyAdmin?."
read password

# Verificar si el usuario ya existe
if ! mysql -u root -e "SELECT user FROM mysql.user WHERE user='$usuario';" | grep -q $usuario; then
mysql -u root <<EOF
CREATE USER $usuario@localhost IDENTIFIED BY '$password';
GRANT ALL PRIVILEGES ON *.* TO $usuario@localhost WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
echo " Se ha creado el usuario $usuario con la contraseña $password para el acceso a http://localhost/phpmyadmin"
else
echo "El usuario '$usuario' ya existe en MySQL."
fi


