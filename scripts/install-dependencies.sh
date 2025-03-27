#!/bin/bash
# scripts/install-dependencies.sh
# Run with: bash scripts/install-dependencies.sh

set -e

# Versions
KUBECTL_VERSION="v1.29.0"
MINIKUBE_VERSION="v1.32.0"
DOCKER_VERSION="24.0.7"
NODE_MAJOR_VERSION="20"

echo "🔧 Installing dependencies..."

# Install kubectl
if ! command -v kubectl &> /dev/null || [[ $(kubectl version --client --short | grep -oE '[0-9]+\.[0-9]+\.[0-9]+') != ${KUBECTL_VERSION#v} ]]; then
  echo "📦 Installing kubectl ${KUBECTL_VERSION}..."
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
else
  echo "✅ kubectl ${KUBECTL_VERSION} already installed."
fi

# Install Minikube
if ! command -v minikube &> /dev/null || [[ $(minikube version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+') != ${MINIKUBE_VERSION#v} ]]; then
  echo "📦 Installing Minikube ${MINIKUBE_VERSION}..."
  curl -LO https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  rm minikube-linux-amd64
else
  echo "✅ Minikube ${MINIKUBE_VERSION} already installed."
fi

# Install Docker with version check
if ! command -v docker &> /dev/null || [[ $(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+') != ${DOCKER_VERSION} ]]; then
  echo "📦 Installing Docker ${DOCKER_VERSION}..."
  sudo apt update && sudo apt install -y docker.io
else
  echo "✅ Docker ${DOCKER_VERSION} already installed."
fi

# Add current user to docker group
if groups $USER | grep -qv docker; then
  echo "➕ Adding user to docker group..."
  sudo usermod -aG docker $USER
  echo "⚠️  Please log out and back in to apply Docker group changes."
else
  echo "✅ User already in docker group."
fi

# Install Node.js via Nodesource
if ! command -v node &> /dev/null || [[ $(node -v | cut -d. -f1) != v${NODE_MAJOR_VERSION} ]]; then
  echo "📦 Installing Node.js ${NODE_MAJOR_VERSION}.x..."
  curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR_VERSION}.x | sudo -E bash -
  sudo apt-get install -y nodejs
else
  echo "✅ Node.js already installed."
fi

# Final check
echo -e "\n🧪 Installed Versions:"
echo "kubectl:  $(kubectl version --client=true | grep 'GitVersion' | cut -d'"' -f4)"
echo "minikube: $(minikube version | head -n1 | cut -d: -f2 | xargs)"
echo "docker:   $(docker --version)"
echo "node:     $(node -v)"
