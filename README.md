# Node.js Service Deployment (Terraform + Ansible + GitHub Actions)

This project demonstrates a full CI/CD pipeline for deploying a simple Node.js service to an AWS EC2 instance using **Terraform**, **Ansible**, and **GitHub Actions**.

---

## 🚀 Overview

The goal of this project is to automate infrastructure provisioning, configuration management, and application deployment in a single, end-to-end workflow.

### Stack Components

| Tool | Purpose |
|------|----------|
| **Terraform** | Infrastructure as Code — provisions an AWS EC2 instance |
| **Ansible** | Configuration management — installs Node.js, Nginx, and deploys the app |
| **Node.js** | Simple Express app (`Hello, world!`) served via Nginx reverse proxy |
| **GitHub Actions** | Continuous Deployment — automatically updates the server on each push |

---

## 🗂 Directory Structure

```
nodejs-service-deploy/
│
├── app/                        # Node.js application
│   ├── package.json
│   ├── server.js
│
├── ansible/                    # Configuration management
│   ├── inventory.ini
│   ├── node_service.yml
│   └── roles/
│       └── app/
│           ├── tasks/main.yml
│           └── templates/
│               ├── node-app.service.j2
│               └── nginx-node.conf.j2
│
├── terraform/                  # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│
├── .github/workflows/          # CI/CD pipelines
│   ├── deploy-ansible.yml
│   └── deploy-ssh.yml
│
├── .gitignore
└── README.md
```

---

## 🧱 1. Terraform — Provision EC2

### Initialize and apply

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### Outputs

- **public_ip** — EC2 instance IP  
- **ssh_private_key_path** — path to generated key  
- **ssh_command** — quick SSH command for access

---

## ⚙️ 2. Ansible — Configure Server & Deploy App

### Test connection

```bash
cd ansible
ansible all -i inventory.ini -m ping
```

### Deploy app

```bash
ansible-playbook -i inventory.ini node_service.yml --tags app
```

### Verify

Visit `http://<EC2_PUBLIC_IP>/` → you should see **Hello, world!**

---

## 🧩 3. GitHub Actions — Automate Deployment

### Secrets Required

| Secret | Description |
|--------|--------------|
| `EC2_HOST` | Public IP of EC2 instance |
| `EC2_USER` | SSH username (usually `ubuntu`) |
| `SSH_PRIVATE_KEY` | Private key for SSH access |
| `REPO_URL` | Repo URL (HTTPS or SSH) |
| `APP_PORT` | Optional app port (default 3000) |

### Trigger Deployment

- Push to the **main** branch → auto-deploy
- Or manually run via the **Actions** tab

---

## 🧰 4. Local Development (optional)

```bash
cd app
npm install
npm start
# Visit http://localhost:3000
```

---

## 🧹 Cleanup

To delete all AWS resources:

```bash
cd terraform
terraform destroy -auto-approve
```

---

## 🧠 Key Learnings

- How to integrate Terraform + Ansible + GitHub Actions
- Managing SSH keys & GitHub Secrets securely
- Building an end-to-end automated deployment pipeline

---

## 🪪 License

MIT License © 2025

https://roadmap.sh/projects/nodejs-service-deployment
