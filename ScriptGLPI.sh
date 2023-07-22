#!/bin/bash

# Vérifier si l'utilisateur a les droits d'administration (root)
if [[ $(id -u) -ne 0 ]]; then
  echo "Ce script doit être exécuté en tant que root. Veuillez utiliser sudo."
  exit 1
fi

# Variables de configuration
MYSQL_ROOT_PASSWORD="votre_mot_de_passe_mysql"
GLPI_DB_NAME="glpidb"
GLPI_DB_USER="glpiuser"
GLPI_DB_PASSWORD="mot_de_passe_glpiuser"
GLPI_INSTALL_DIR="/var/www/glpi"

# Mise à jour du système et installation des paquets nécessaires
echo "Mise à jour du système et installation des dépendances..."
apt-get update
apt-get install -y apache2 mariadb-server php libapache2-mod-php php-mysql php-gd php-ldap php-curl php-xml php-mbstring

# Définir le mot de passe root de MySQL
debconf-set-selections <<< "mariadb-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"

# Créer la base de données et l'utilisateur pour GLPI
mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOL
CREATE DATABASE $GLPI_DB_NAME CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON $GLPI_DB_NAME.* TO '$GLPI_DB_USER'@'localhost' IDENTIFIED BY '$GLPI_DB_PASSWORD';
FLUSH PRIVILEGES;
EXIT;
EOL

# Télécharger GLPI depuis son site officiel
echo "Téléchargement de GLPI..."
GLPI_URL="https://github.com/glpi-project/glpi/releases/latest/download/glpi-9.5.5.tgz"
GLPI_ARCHIVE="/tmp/glpi.tgz"
wget -O "$GLPI_ARCHIVE" "$GLPI_URL"

# Extraire l'archive dans le répertoire d'installation
echo "Extraction de GLPI dans $GLPI_INSTALL_DIR..."
mkdir -p "$GLPI_INSTALL_DIR"
tar -xzf "$GLPI_ARCHIVE" -C "$GLPI_INSTALL_DIR" --strip-components=1

# Définir les permissions appropriées
echo "Configuration des permissions..."
chown -R www-data:www-data "$GLPI_INSTALL_DIR/files"
chown -R www-data:www-data "$GLPI_INSTALL_DIR/config"
chown -R www-data:www-data "$GLPI_INSTALL_DIR/plugins"

# Créer le fichier de configuration du site Apache pour GLPI
GLPI_CONF="/etc/apache2/sites-available/glpi.conf"
cat <<EOL > "$GLPI_CONF"
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot $GLPI_INSTALL_DIR

    <Directory $GLPI_INSTALL_DIR>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/glpi-error.log
    CustomLog \${APACHE_LOG_DIR}/glpi-access.log combined
</VirtualHost>
EOL

# Activer le site GLPI
a2ensite glpi.conf

# Activer les modules Apache nécessaires
a2enmod rewrite

# Redémarrer Apache pour appliquer les changements
echo "Redémarrage du serveur Apache..."
service apache2 restart

# Supprimer l'archive téléchargée
rm "$GLPI_ARCHIVE"

echo "Installation et configuration de GLPI terminées."
echo "Accédez à votre GLPI en utilisant l'adresse IP ou le nom de domaine de votre serveur dans un navigateur web."
echo "Suivez les étapes de configuration dans l'interface web de GLPI pour finaliser la configuration initiale."
