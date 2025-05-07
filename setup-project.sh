#!/bin/bash
set -e

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Configuration simplifiée pour WSL ===${NC}"

# Fonction pour afficher les messages d'étape
function step() {
  echo -e "${YELLOW}\n=== ÉTAPE: $1 ===${NC}"
}

# Vérifier que Docker est en cours d'exécution
step "Vérification de Docker"
if ! docker info > /dev/null 2>&1; then
  echo -e "${RED}Docker n'est pas en cours d'exécution. Démarrage...${NC}"
  sudo service docker start
  sleep 5
fi

# Vérifier les ressources disponibles
step "Vérification des ressources système"
MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
echo "Mémoire totale disponible: ${MEM_TOTAL}MB"

if [ $MEM_TOTAL -lt 4000 ]; then
  echo -e "${RED}Attention: Vous avez moins de 4GB de RAM disponible, ce qui peut causer des problèmes.${NC}"
  echo "Continuer quand même? (o/n)"
  read -r response
  if [[ ! "$response" =~ ^([oO][uU][iI]|[oO])$ ]]; then
    exit 1
  fi
fi

# Nettoyer l'environnement précédent si nécessaire
step "Nettoyage de l'environnement précédent"
kind delete cluster --name telecom-cluster 2>/dev/null || true
docker system prune -f

# Création du cluster kind simplifié
step "Création du cluster kind simplifié"
echo "Création d'un cluster avec 1 control plane et 1 worker..."
kind create cluster --config=kind-config.yaml

# Vérifier que le cluster est fonctionnel
if kubectl cluster-info; then
  echo -e "${GREEN}Cluster kind créé avec succès!${NC}"
  kubectl get nodes -o wide
else
  echo -e "${RED}La création du cluster a échoué.${NC}"
  exit 1
fi

# Installation de l'ingress controller Nginx seulement
step "Installation de Nginx Ingress Controller"
kubectl create namespace ingress-nginx || true
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=NodePort

echo -e "${GREEN}Configuration de base terminée!${NC}"
echo "Vous pouvez maintenant procéder à l'installation des autres composants un par un."
echo "Suggéré ordre d'installation:"
echo "1. ArgoCD"
echo "2. Vault"
echo "3. SonarQube"