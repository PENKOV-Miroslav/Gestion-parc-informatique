#!/bin/bash

# Vérifier si l'utilisateur a les droits d'administration (root)
if [[ $(id -u) -ne 0 ]]; then
  echo "Ce script doit être exécuté en tant que root. Veuillez utiliser sudo."
  exit 1
fi

# Renseignez le mot de passe root de MySQL
MYSQL_ROOT_PASSWORD="votre_mot_de_passe_mysql"

# Activer le journal binlog pour le maître
echo "Activer le journal binlog sur le serveur maître..."
echo "log_bin = /var/log/mysql/mysql-bin.log" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "server-id = 1" >> /etc/mysql/mysql.conf.d/mysqld.cnf

# Redémarrer le serveur MySQL pour appliquer les changements
echo "Redémarrer le serveur MySQL..."
service mysql restart

# Créer un utilisateur répliquant pour l'esclave
echo "Créer un utilisateur répliquant pour l'esclave..."
mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOL
CREATE USER 'replication_user'@'%' IDENTIFIED BY 'mot_de_passe_replication';
GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'%';
FLUSH PRIVILEGES;
EXIT;
EOL

# Afficher les informations nécessaires pour la configuration de l'esclave
echo "Informations du maître (Master) :"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SHOW MASTER STATUS\G"
