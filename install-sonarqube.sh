#!/bin/bash
set -e

# Création du namespace SonarQube
echo "Création du namespace SonarQube..."
kubectl create namespace sonarqube

# Installation de SonarQube via Helm
echo "Installation de SonarQube..."
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
helm install sonarqube sonarqube/sonarqube \
  --namespace sonarqube \
  --set persistence.enabled=true \
  --set postgresql.persistence.enabled=true

# Attendre que les pods SonarQube soient prêts
echo "Attente que les pods SonarQube soient prêts..."
kubectl wait --for=condition=Ready pods --all -n sonarqube --timeout=500s

# Création de l'Ingress pour accéder à SonarQube
echo "Configuration de l'ingress pour SonarQube..."
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sonarqube-ingress
  namespace: sonarqube
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: sonarqube.telecom.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: sonarqube-sonarqube
            port:
              number: 9000
EOF

# Génération d'un token d'API pour SonarQube (à utiliser dans les pipelines CI/CD)
echo "Configuration du token SonarQube pour l'intégration CI/CD..."
echo "Pour générer un token SonarQube:"
echo "1. Accédez à l'interface web SonarQube: http://sonarqube.telecom.local"
echo "2. Connectez-vous avec les identifiants par défaut (admin/admin)"
echo "3. Allez dans Administration > Security > Users > Tokens"
echo "4. Générez un nouveau token nommé 'gitlab-ci'"
echo "5. Copiez le token généré pour l'utiliser dans votre configuration GitLab CI"

echo "SonarQube est installé!"
echo "URL: http://sonarqube.telecom.local"
echo "Utilisateur: admin"
echo "Mot de passe par défaut: admin"
echo ""
echo "N'oubliez pas d'ajouter 'sonarqube.telecom.local' à votre fichier /etc/hosts pour y accéder localement."
echo "Pour cela, exécutez: echo '127.0.0.1 sonarqube.telecom.local' | sudo tee -a /etc/hosts"