#!/bin/bash
set -e

# Installation de Helm
if ! command -v helm &> /dev/null; then
    echo "Installation de Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Installation de l'ingress controller Nginx
echo "Installation de Nginx Ingress Controller..."
kubectl create namespace ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=NodePort

# Installation de Prometheus et Grafana pour la surveillance
echo "Installation de Prometheus et Grafana..."
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring

# Installation de Cert-Manager pour les certificats TLS
echo "Installation de Cert-Manager..."
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true

# Installation de MetalLB pour le load balancing
echo "Installation de MetalLB..."
kubectl create namespace metallb-system
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install metallb metallb/metallb \
  --namespace metallb-system

# Configurer MetalLB
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.17.255.1-172.17.255.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advert
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF

echo "Toutes les installations de base sont terminées!"