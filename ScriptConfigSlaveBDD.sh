#!/bin/bash

# Vérifier si l'utilisateur a les droits d'administration (root)
if [[ $(id -u) -ne 0 ]]; then
  echo "Ce script doit être exécuté en tant que root. Veuillez utiliser sudo."
  exit 1
fi

# Renseignez le mot de passe root de MySQL
MYSQL_ROOT_PASSWORD="votre_mot_de_passe_mysql"

# Renseignez les informations du maître (Master) fournies par le script précédent
MASTER_LOG_FILE="mysql-bin.xxxxxx"
MASTER_LOG_POS="xxxx"

# Activer le mode esclave (Slave) sur le serveur MySQL
echo "Activer le mode esclave sur le serveur MySQL..."
echo "CHANGE MASTER TO MASTER_HOST='adresse_ip_maitre', MASTER_USER='replication_user', MASTER_PASSWORD='mot_de_passe_replication', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS;" | mysql -u root -p$MYSQL_ROOT_PASSWORD

# Démarrer le processus de réplication de l'esclave (Slave)
echo "Démarrer le processus de réplication sur l'esclave..."
echo "START SLAVE;" | mysql -u root -p$MYSQL_ROOT_PASSWORD

# Afficher le statut de la réplication
echo "Statut de la réplication :"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SHOW SLAVE STATUS\G"
