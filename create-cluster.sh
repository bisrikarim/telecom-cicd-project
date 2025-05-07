#!/bin/bash
set -e

# Vérifier que kind est installé
if ! command -v kind &> /dev/null; then
    echo "Kind n'est pas installé. Installation en cours..."
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
fi

# Vérifier que kubectl est installé
if ! command -v kubectl &> /dev/null; then
    echo "kubectl n'est pas installé. Installation en cours..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
fi

# Créer le cluster kind
echo "Création du cluster kind..."
kind create cluster --config=kind-config.yaml

# Vérifier que le cluster est fonctionnel
echo "Vérification du cluster..."
kubectl cluster-info
kubectl get nodes -o wide

echo "Cluster créé avec succès!"