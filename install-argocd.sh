#!/bin/bash
set -e

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Installation d'ArgoCD ===${NC}"

# Création du namespace ArgoCD
echo "Création du namespace ArgoCD..."
kubectl create namespace argocd 2>/dev/null || true

# Installation d'ArgoCD
echo "Installation d'ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Attendre que les pods ArgoCD soient prêts
echo "Attente que les pods ArgoCD soient prêts..."
echo "Cela peut prendre quelques minutes..."
kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=300s || true

# Modifier le service ArgoCD pour l'exposer via NodePort
echo "Configuration du service ArgoCD pour l'exposer via NodePort..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Obtenir le port
NODE_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')

# Obtenir le mot de passe admin initial
echo "Récupération du mot de passe admin ArgoCD..."
sleep 5
ARGO_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo -e "${GREEN}ArgoCD est installé!${NC}"
echo "URL: https://localhost:${NODE_PORT} ou https://${NODE_IP}:${NODE_PORT}"
echo "Utilisateur: admin"
echo "Mot de passe: ${ARGO_PASSWORD}"
echo ""
echo "Pour une configuration plus simple, vous pouvez accéder à ArgoCD via le port forward:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Puis accédez à https://localhost:8080"
echo ""
echo "IMPORTANT: Vous devrez accepter le certificat auto-signé dans votre navigateur."