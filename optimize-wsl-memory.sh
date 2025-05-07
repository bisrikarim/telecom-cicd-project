#!/bin/bash
# Script pour optimiser la mémoire sur WSL pour Kubernetes

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Optimisation de WSL pour Kubernetes ===${NC}"

# Vérifier si nous sommes dans WSL
if ! grep -q Microsoft /proc/version; then
  echo -e "${RED}Ce script doit être exécuté dans un environnement WSL.${NC}"
  exit 1
fi

# Créer un fichier .wslconfig dans le répertoire utilisateur Windows
WINDOWS_HOME=$(wslpath $(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r'))

echo -e "${YELLOW}Création du fichier .wslconfig dans $WINDOWS_HOME${NC}"

cat > "$WINDOWS_HOME/.wslconfig" << EOF
[wsl2]
memory=6GB
processors=2
swap=4GB
EOF

echo -e "${GREEN}Configuration .wslconfig créée.${NC}"
echo "Pour appliquer ces changements, exécutez les commandes suivantes dans PowerShell en tant qu'administrateur:"
echo -e "${YELLOW}wsl --shutdown${NC}"
echo "Puis redémarrez WSL."
echo ""

# Optimiser les paramètres de Docker
echo -e "${YELLOW}Configuration de Docker pour consommer moins de ressources...${NC}"

# Vérifier si Docker est installé
if command -v docker > /dev/null; then
  # Créer le fichier de configuration Docker
  mkdir -p ~/.docker
  cat > ~/.docker/daemon.json << EOF
{
  "registry-mirrors": [],
  "max-concurrent-downloads": 1,
  "max-concurrent-uploads": 1,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
  echo -e "${GREEN}Configuration Docker optimisée.${NC}"
  echo "Redémarrez Docker avec: sudo service docker restart"
else
  echo -e "${RED}Docker n'est pas installé. Ignoré.${NC}"
fi

# Optimiser les paramètres système
echo -e "${YELLOW}Optimisation des paramètres système...${NC}"

# Réduire la charge du système de fichiers
sudo sysctl -w vm.swappiness=10
sudo sysctl -w vm.vfs_cache_pressure=50

echo -e "${GREEN}Optimisations système appliquées.${NC}"
echo "Ces paramètres seront réinitialisés au redémarrage de WSL."
echo "Pour les rendre permanents, ajoutez-les à /etc/sysctl.conf:"
echo "vm.swappiness=10"
echo "vm.vfs_cache_pressure=50"

# Afficher les conseils
echo -e "${YELLOW}\nImportant: Pour exécuter Kind avec succès dans WSL, suivez ces conseils:${NC}"
echo "1. Utilisez une configuration Kind minimale (1 control-plane, 1 worker)"
echo "2. Installez un composant à la fois (commencez par ArgoCD)"
echo "3. Fermez les applications gourmandes en mémoire sur Windows"
echo "4. Utilisez le port-forward au lieu de l'Ingress pour accéder aux services"
echo "5. Augmentez la mémoire allouée à WSL comme indiqué ci-dessus"