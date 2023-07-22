#!/bin/bash

# Vérifier si l'utilisateur a les droits d'administration (root)
if [[ $(id -u) -ne 0 ]]; then
  echo "Ce script doit être exécuté en tant que root. Veuillez utiliser sudo."
  exit 1
fi

# Installer les paquets nécessaires
echo "Installation des paquets..."
apt-get update
apt-get install -y isc-dhcp-server

# Configuration du DHCP
echo "Configuration du DHCP..."

# Spécifier l'interface réseau à utiliser pour DHCP (remplacez "eth0" par votre interface réseau)
INTERFACE="eth0"

# Renseignez l'adresse IP de la passerelle (remplacez "192.168.1.1" par l'adresse souhaitée)
GATEWAY_IP="192.168.1.1"

# Renseignez le masque de sous-réseau (remplacez "255.255.255.0" par le masque souhaité)
SUBNET_MASK="255.255.255.0"

# Renseignez la plage d'adresses IP à attribuer automatiquement (remplacez par la plage souhaitée)
IP_RANGE="192.168.1.100 192.168.1.254"

# Renseignez les adresses IP à réserver (remplacez par vos adresses souhaitées)
RESERVED_IPS=("192.168.1.2" "192.168.1.3" "192.168.1.4" "192.168.1.5" "192.168.1.6" "192.168.1.7" "192.168.1.8" "192.168.1.9" "192.168.1.10" "192.168.1.11")

# Définition du fichier de configuration du DHCP
DHCP_CONF="/etc/dhcp/dhcpd.conf"

# Sauvegarde du fichier de configuration actuel
cp "$DHCP_CONF" "$DHCP_CONF.bak"

# Configuration du fichier de DHCP
cat <<EOL > "$DHCP_CONF"
subnet $GATEWAY_IP netmask $SUBNET_MASK {
  option routers $GATEWAY_IP;
  option subnet-mask $SUBNET_MASK;
  option domain-name-servers 8.8.8.8, 8.8.4.4;

  range $IP_RANGE;

  EOL

for ip in "${RESERVED_IPS[@]}"; do
  echo "  host host_$(echo "$ip" | awk -F'.' '{print $4}'){ hardware ethernet 00:00:00:00:00:0$RANDOM; fixed-address $ip; }" >> "$DHCP_CONF"
done

echo "}" >> "$DHCP_CONF"

# Redémarrer le service DHCP
echo "Redémarrage du service DHCP..."
service isc-dhcp-server restart

echo "Configuration terminée."
