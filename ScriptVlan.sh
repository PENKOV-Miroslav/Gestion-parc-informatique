#!/bin/bash

# Vérifier si l'utilisateur a les droits d'administration (root)
if [[ $(id -u) -ne 0 ]]; then
  echo "Ce script doit être exécuté en tant que root. Veuillez utiliser sudo."
  exit 1
fi

# Renseignez le nom de l'interface réseau principale (sans le numéro de VLAN)
INTERFACE_NAME="eth0"

# Renseignez l'ID du VLAN que vous souhaitez créer
VLAN_ID="100"

# Renseignez l'adresse IP et le masque de sous-réseau pour le VLAN (facultatif)
IP_ADDRESS="192.168.100.1/24"

# Installation des paquets nécessaires (si vous ne les avez pas déjà installés)
# apt-get update
# apt-get install -y vlan

# Charger le module du kernel pour les VLAN (s'il n'est pas déjà chargé)
modprobe 8021q

# Créer le VLAN virtuel sur l'interface principale
echo "Création du VLAN $VLAN_ID sur $INTERFACE_NAME..."
vconfig add "$INTERFACE_NAME" "$VLAN_ID"

# Activer l'interface virtuelle VLAN
ifconfig "$INTERFACE_NAME.$VLAN_ID" up

# Facultatif : Configurer une adresse IP pour l'interface VLAN
if [[ -n "$IP_ADDRESS" ]]; then
  echo "Configuration de l'adresse IP $IP_ADDRESS pour l'interface VLAN $INTERFACE_NAME.$VLAN_ID..."
  ip addr add "$IP_ADDRESS" dev "$INTERFACE_NAME.$VLAN_ID"
fi

# Facultatif : Si vous souhaitez que cette configuration persiste après le redémarrage,
# vous pouvez ajouter les commandes ci-dessus à votre fichier de démarrage ou
# utiliser les fichiers de configuration réseau appropriés pour votre distribution Linux.
