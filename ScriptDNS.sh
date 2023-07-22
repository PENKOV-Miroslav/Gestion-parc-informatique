#!/bin/bash

# Vérifier si l'utilisateur a les droits d'administration (root)
if [[ $(id -u) -ne 0 ]]; then
  echo "Ce script doit être exécuté en tant que root. Veuillez utiliser sudo."
  exit 1
fi

# Installer les paquets nécessaires
echo "Installation de BIND9..."
apt-get update
apt-get install -y bind9 bind9utils bind9-doc

# Configuration du serveur DNS BIND9
echo "Configuration de BIND9..."

# Renseignez le nom de domaine que vous souhaitez gérer avec BIND9
DOMAIN="mondomaine.local"

# Renseignez le chemin du fichier de zone directe (forward zone file)
ZONE_FILE="/etc/bind/zones/$DOMAIN.zone"

# Renseignez le chemin du fichier de zone inverse (reverse zone file)
REVERSE_ZONE_FILE="/etc/bind/zones/$DOMAIN.reverse.zone"

# Créer le répertoire pour les fichiers de zone s'ils n'existent pas déjà
mkdir -p /etc/bind/zones

# Créer le fichier de zone directe
cat <<EOL > "$ZONE_FILE"
\$TTL 604800
@ IN SOA ns1.$DOMAIN. admin.$DOMAIN. (
   2023072201 ; Serial
   604800     ; Refresh
   86400      ; Retry
   2419200    ; Expire
   604800 )   ; Negative Cache TTL
;
@   IN  NS  ns1.$DOMAIN.
@   IN  A   192.168.1.1  ; Remplacez par l'adresse IP de votre serveur DNS

; Définir les enregistrements pour les hôtes
hostname1   IN  A   192.168.1.10
hostname2   IN  A   192.168.1.20
EOL

# Créer le fichier de zone inverse
# Notez que l'adresse IP de votre serveur DNS doit être écrite en ordre inverse ici (ex: 192.168.1.1 devient 1.168.192.in-addr.arpa.)
cat <<EOL > "$REVERSE_ZONE_FILE"
\$TTL 604800
@ IN SOA ns1.$DOMAIN. admin.$DOMAIN. (
   2023072201 ; Serial
   604800     ; Refresh
   86400      ; Retry
   2419200    ; Expire
   604800 )   ; Negative Cache TTL
;
@   IN  NS  ns1.$DOMAIN.
1   IN  PTR ns1.$DOMAIN.  ; Remplacez par l'adresse IP de votre serveur DNS
10  IN  PTR hostname1.$DOMAIN.
20  IN  PTR hostname2.$DOMAIN.
EOL

# Mettre à jour le fichier de configuration BIND9 pour inclure les fichiers de zone
cat <<EOL >> /etc/bind/named.conf.local
zone "$DOMAIN" {
    type master;
    file "$ZONE_FILE";
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "$REVERSE_ZONE_FILE";
};
EOL

# Redémarrer BIND9 pour appliquer les changements
echo "Redémarrage de BIND9..."
service bind9 restart

echo "Configuration terminée. Votre serveur DNS BIND9 est maintenant prêt."
