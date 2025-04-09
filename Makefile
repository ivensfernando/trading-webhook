# 📘 Makefile for Local K8s Webhook Dev Environment
# Usage: make <target>
# Run `make help` to see available commands

.PHONY: help install-tools setup start install-deps build deploy logs clean ingress patch-ingress-webhook

# Show help message for each target
help:
	@echo ""
	@echo "📘 Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'
	@echo ""

install-tools: ## Install Minikube, Docker, and kubectl
	chmod +x scripts/install-dependencies.sh
	scripts/install-dependencies.sh

setup: ## Run full setup (Minikube, dependencies, build, deploy, patch)
	$(MAKE) start
	$(MAKE) install-deps
	$(MAKE) build
	$(MAKE) deploy
	$(MAKE) patch-ingress-webhook

start: ## Start Minikube cluster
	@echo "\n🚀 Starting Minikube..."
	minikube start

install-deps: ## Install Node.js dependencies via npm
	@echo "\n📦 Installing Node.js dependencies..."
	npm ci

build: ## Build Docker image inside Minikube
	@echo "\n🐳 Building Docker image inside Minikube..."
	eval $$(minikube docker-env) && docker build -t webhook-app:latest .

deploy: ## Deploy the app to Kubernetes
	@echo "\n🚢 Deploying application to Kubernetes..."
	kubectl apply -f k8s/

patch-ingress-webhook: ## Patch Ingress admission service and webhook config to use port 8443
	@echo "\n🔧 Patching admission service to expose port 8443..."
	kubectl patch svc ingress-nginx-controller-admission \
	  -n ingress-nginx \
	  --type='merge' \
	  -p='{"spec": {"ports": [{"name": "https-webhook", "port": 8443, "targetPort": 8443}]}}' || true

	@echo "\n🔧 Patching ValidatingWebhookConfiguration to use port 8443..."
	kubectl patch ValidatingWebhookConfiguration ingress-nginx-admission \
	  --type='json' \
	  -p='[{"op": "replace", "path": "/webhooks/0/clientConfig/service/port", "value": 8443}]' || true

logs: ## Stream logs from the Kubernetes pod
	@echo "\n📄 Streaming logs..."
	kubectl logs -l app=webhook -f

clean: ## Remove K8s resources and stop Minikube
	@echo "\n🧹 Cleaning up Kubernetes resources and stopping Minikube..."
	kubectl delete -f k8s/ || true
	minikube stop

ingress: ## Enable ingress addon, apply ingress config, and update /etc/hosts
	@echo "\n🌐 Enabling Ingress controller..."
	minikube addons enable ingress

	@echo "\n📥 Applying ingress.yaml..."
	kubectl apply -f k8s/ingress.yaml

	@echo "\n🔗 Mapping webhook.local to Minikube IP..."
	IP=$$(minikube ip); \
	  if ! grep -q "webhook.local" /etc/hosts; then \
	    echo "$$IP webhook.local" | sudo tee -a /etc/hosts; \
	  else \
	    echo "⚠️  webhook.local already mapped in /etc/hosts"; \
	  fi

	@echo "✅ You can now access the app at http://webhook.local"

dev: ## Run dev mode: watch for changes, rebuild + redeploy + stream logs
	@echo "\n🚀 Starting dev mode (auto rebuild + deploy + logs)..."
	@find . -type f \( -name '*.js' -o -name '*.json' \) | entr -r sh -c '\
		echo "\n🔄 Change detected! Rebuilding and deploying..."; \
		eval $$(minikube docker-env); \
		docker build -t webhook-app:latest . && \
		kubectl rollout restart deployment webhook-deployment && \
		kubectl logs -l app=webhook -f \
	'

dev-reload: ## Rebuild Docker image, restart deployment, stream logs
	@echo "\n🔄 Rebuilding Docker image inside Minikube..."
	eval $$(minikube docker-env) && docker build --no-cache -t webhook-app:latest .

	@echo "\n🚀 Restarting Kubernetes deployment..."
	kubectl rollout restart deployment webhook-deployment

	@echo "\n📄 Streaming logs from deployment..."
	kubectl logs -l app=webhook -f
