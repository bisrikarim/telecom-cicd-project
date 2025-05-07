#!/bin/bash
set -e

# Création du namespace Vault
echo "Création du namespace Vault..."
kubectl create namespace vault

# Installation de Vault via Helm
echo "Installation de Vault..."
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault \
  --namespace vault \
  --set "server.dev.enabled=true" \
  --set "ui.enabled=true" \
  --set "ui.serviceType=ClusterIP"

# Attendre que le pod Vault soit prêt
echo "Attente que le pod Vault soit prêt..."
kubectl wait --for=condition=Ready pods --all -n vault --timeout=300s

# Création de l'Ingress pour accéder à l'interface Vault
echo "Configuration de l'ingress pour Vault..."
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: vault-ui-ingress
  namespace: vault
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
spec:
  rules:
  - host: vault.telecom.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: vault-ui
            port:
              number: 8200
EOF

# Configuration de l'intégration Vault-Kubernetes
echo "Configuration de l'intégration Vault-Kubernetes..."
# Démarrons une session shell dans le pod Vault
kubectl -n vault exec -it vault-0 -- /bin/sh -c '
# Activation du secret engine Kubernetes
vault secrets enable -path=kubernetes kv-v2

# Création de politiques pour nos microservices
vault policy write device-service - <<EOH
path "kubernetes/data/device-service/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOH

vault policy write monitoring-service - <<EOH
path "kubernetes/data/monitoring-service/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOH

vault policy write alert-service - <<EOH
path "kubernetes/data/alert-service/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOH

vault policy write inventory-service - <<EOH
path "kubernetes/data/inventory-service/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOH

# Création de quelques secrets de démonstration
vault kv put kubernetes/device-service/db username=device_user password=device_password
vault kv put kubernetes/monitoring-service/db username=monitoring_user password=monitoring_password
vault kv put kubernetes/alert-service/db username=alert_user password=alert_password
vault kv put kubernetes/inventory-service/db username=inventory_user password=inventory_password

# Activer l'authentification Kubernetes
vault auth enable kubernetes

# Configurer l'authentification Kubernetes
vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    issuer="https://kubernetes.default.svc.cluster.local"

# Créer des rôles pour nos microservices
vault write auth/kubernetes/role/device-service \
    bound_service_account_names=device-service \
    bound_service_account_namespaces=default \
    policies=device-service \
    ttl=1h

vault write auth/kubernetes/role/monitoring-service \
    bound_service_account_names=monitoring-service \
    bound_service_account_namespaces=default \
    policies=monitoring-service \
    ttl=1h

vault write auth/kubernetes/role/alert-service \
    bound_service_account_names=alert-service \
    bound_service_account_namespaces=default \
    policies=alert-service \
    ttl=1h

vault write auth/kubernetes/role/inventory-service \
    bound_service_account_names=inventory-service \
    bound_service_account_namespaces=default \
    policies=inventory-service \
    ttl=1h
'

echo "Vault est installé et configuré!"
echo "URL: https://vault.telecom.local"
echo "Token: root (mode développement)"
echo ""
echo "N'oubliez pas d'ajouter 'vault.telecom.local' à votre fichier /etc/hosts pour y accéder localement."
echo "Pour cela, exécutez: echo '127.0.0.1 vault.telecom.local' | sudo tee -a /etc/hosts"