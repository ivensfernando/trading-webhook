# 🪝 Trading Webhook

A Node.js + Express webhook service for handling trading-related events.  
Built for local development with Kubernetes (Minikube), GitHub Actions, and Docker.

---

## 🚀 Features

- ✅ Node.js Express app with `/health` endpoint
- ✅ CI/CD with GitHub Actions (test → format → build → deploy)
- ✅ Local Kubernetes support via Minikube
- ✅ Liveness & readiness probes for reliability
- ✅ Ingress with local domain (`webhook.local`)
- ✅ One-line setup via `make`

---

## 📦 Requirements

- Linux (tested on Ubuntu 22+)
- Docker
- Git
- GitHub CLI (`gh`)
- `make`

---

## 🛠️ Setup

1. **Clone the repo:**

   
   git clone git@github.com:ivensfernando/trading-webhook.git  
   cd trading-webhook

2. **Install dependencies & tools:**

   
   make install-tools

3. **Start Minikube, build and deploy:**

   
   make setup

4. **Enable ingress and expose the app:**

   
   make ingress

5. **Add to /etc/hosts:**

   
   192.168.49.2 webhook.local

   Replace `192.168.49.2` with your actual Minikube IP.

6. **Access the app:**

   http://webhook.local/health

---

## 🧪 Health Checks

The app exposes `/health` and the Kubernetes deployment includes:

- **Liveness Probe:** Restarts the pod if it becomes unresponsive
- **Readiness Probe:** Ensures pod is ready before receiving traffic

See `k8s/deployment.yaml` for full config.

---

## 🐳 Docker

A simple `Dockerfile` builds the app using Node 20:

FROM node:20-alpine  
WORKDIR /app  
COPY . .  
RUN npm ci  
CMD ["node", "bin/www"]  
EXPOSE 3000

---

## ☸️ Kubernetes

Manifests are in the `k8s/` directory:

- `deployment.yaml` – App deployment with health checks
- `ingress.yaml` – Ingress rule for `webhook.local`
- `health.yaml` – (optional patch if separated from deployment)

---

## 🛠️ Makefile Commands

| Command             | Description                                      |
|---------------------|--------------------------------------------------|
| make install-tools  | Install kubectl, Minikube, Docker, Node.js       |
| make setup          | Start Minikube, install deps, build, deploy      |
| make build          | Build Docker image in Minikube's Docker daemon   |
| make deploy         | Deploy the app to Kubernetes                     |
| make ingress        | Enable Ingress + configure local hostname        |
| make logs           | Show pod logs                                    |
| make clean          | Remove all resources and stop Minikube           |

---

## 🤖 GitHub Actions

CI/CD is defined in `.github/workflows/github-actions.yml`:

- Runs on `developer` branch
- Lints, tests, builds Docker image
- Deploys to local K8s (if using self-hosted runner)

---

## 📄 License

MIT License

---

## 🙌 Credits

Made with 💻 and ☕ by [@ivensfernando](https://github.com/ivensfernando)
