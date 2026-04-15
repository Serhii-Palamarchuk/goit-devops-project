# 🚀 Lesson 7 - Kubernetes, Helm & EKS Deployment

## 📌 Опис проєкту

Цей проєкт демонструє повний DevOps pipeline:

👉 **Infrastructure as Code → Containerization → Kubernetes → Helm → Autoscaling**

Реалізовано:

* Terraform інфраструктура (S3 backend, VPC, ECR, EKS)
* Docker контейнеризація Django застосунку
* Збереження образу в AWS ECR
* Розгортання застосунку в Kubernetes (EKS)
* Використання Helm chart
* Автоматичне масштабування через HPA
* Збір метрик через metrics-server

Проєкт максимально наближений до реального DevOps сценарію.

---

## 🏗️ Архітектура

### AWS (Terraform)

* **S3 Bucket** → зберігання Terraform state
* **DynamoDB** → state locking
* **VPC (10.0.0.0/16)**:
  * 3 Public Subnets
  * 3 Private Subnets
  * Internet Gateway
  * NAT Gateway
* **ECR Repository** → зберігання Docker образів
* **EKS Cluster** → Kubernetes cluster
* **Node Group (t3.small)** → worker nodes

---

### Kubernetes (Helm)

* **Deployment** → Django app
* **Service (LoadBalancer)** → доступ з інтернету
* **ConfigMap** → env змінні
* **HPA (2–6 pods)** → автоскейл по CPU
* **metrics-server** → метрики для HPA

---

## 📁 Структура проєкту

```text
lesson-7/
│
├── main.tf
├── backend.tf
├── outputs.tf
├── README.md
│
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   ├── ecr/
│   └── eks/
│
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml
```

---

## 🧩 Terraform модулі

### 🔹 s3-backend

Відповідає за:

* створення S3 bucket
* увімкнення versioning
* server-side encryption (AES256)
* блокування публічного доступу
* створення DynamoDB таблиці

👉 Використовується як backend для Terraform

---

### 🔹 vpc

Створює мережу:

* VPC: `10.0.0.0/16`
* Public subnets:
  * `10.0.1.0/24`
  * `10.0.2.0/24`
  * `10.0.3.0/24`
* Private subnets:
  * `10.0.4.0/24`
  * `10.0.5.0/24`
  * `10.0.6.0/24`

Також:

* Internet Gateway
* NAT Gateway
* Route Tables

---

### 🔹 ecr

Створює:

* ECR repository
* автоматичне сканування образів
* repository policy (доступ тільки для поточного AWS account)
* lifecycle policy (зберігає лише останні 10 образів)

---

### 🔹 eks

Створює:

* EKS cluster
* IAM role для control plane
* IAM role для worker nodes
* managed node group
* фіксовану версію Kubernetes: `1.35`

---

## 🔄 Deployment Flow

1. Terraform створює інфраструктуру (S3 backend, VPC, ECR, EKS)
2. Docker будує Django image
3. Образ тегується та пушиться в AWS ECR
4. `kubectl` підключається до EKS
5. Helm chart розгортає Django app в Kubernetes
6. Service типу LoadBalancer відкриває доступ до застосунку
7. HPA автоматично масштабує поди при навантаженні
8. metrics-server надає CPU metrics для HPA

---

## ⚙️ Backend конфігурація

```hcl
terraform {
  backend "s3" {
    bucket         = "serhii-terraform-state-lesson-5"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

---

## 🚀 Terraform — запуск

### 1. Ініціалізація

```bash
terraform init -reconfigure
```

### 2. Перевірка

```bash
terraform validate
```

### 3. План

```bash
terraform plan
```

### 4. Застосування

```bash
terraform apply
```

---

## ☸️ Підключення до Kubernetes

```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks
kubectl get nodes
```

---

## 🐳 Docker → ECR

### Логін

```bash
aws ecr get-login-password --region us-west-2 \
| docker login --username AWS --password-stdin 493947253485.dkr.ecr.us-west-2.amazonaws.com
```

### Тегування

```bash
docker tag django-docker-hw-web:latest \
493947253485.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:latest
```

### Push

```bash
docker push 493947253485.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:latest
```

---

## 📦 Helm — деплой

### Встановлення / оновлення

```bash
helm install django-app ./charts/django-app
```

або якщо реліз уже існує:

```bash
helm upgrade django-app ./charts/django-app
```

### Перевірка

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
```

---

## 🌐 Доступ до застосунку

Перевірити service:

```bash
kubectl get svc
```

Реальний LoadBalancer DNS:

http://af08d436a4ad14fd99faa78a131185e2-1859282388.us-west-2.elb.amazonaws.com

---

## 📈 Автоскейл (HPA)

```bash
kubectl get hpa
kubectl top pods
```

Приклад поточного стану:

```text
cpu: 1%/70%
```

---

## ✅ Перевірка працездатності

```bash
kubectl get nodes
kubectl get pods
kubectl get svc
kubectl get hpa
kubectl top pods
terraform plan
```

Фінальна перевірка Terraform:

```text
No changes. Your infrastructure matches the configuration.
```

---

## 🛠 Troubleshooting

### Pod не стартує

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### ImagePullBackOff

Перевірити:

* чи образ запушений в ECR
* чи правильний repository в `values.yaml`
* чи ECR repository policy дозволяє доступ тільки для поточного AWS акаунту

### HPA показує `<unknown>`

Встановити metrics-server:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Потім перевірити:

```bash
kubectl get pods -n kube-system
kubectl get hpa
kubectl top pods
```

### Terraform хоче створити все заново

Перевірити правильний backend key у `backend.tf`:

```hcl
key = "lesson-5/terraform.tfstate"
```

---

## Outputs

Після `terraform apply` виводяться:

* S3 bucket name
* DynamoDB table name
* VPC ID
* Public subnet IDs
* Private subnet IDs
* ECR repository URL
* EKS cluster name
* EKS cluster endpoint

---

## 🧠 Lessons Learned

* IAM права можуть блокувати створення EKS ролей (`iam:CreateRole`)
* EKS створюється значно довше за інші AWS ресурси
* Без metrics-server HPA не працює коректно
* Поле `replicas` у Deployment не повинно конфліктувати з HPA
* ECR policy не варто залишати з `Principal = "*"`
* Backend key у Terraform критично важливий для правильного state

---

## 🔒 Чому S3 + DynamoDB?

Це best practice в Terraform:

* S3 → централізоване зберігання state
* DynamoDB → блокування state

👉 Запобігає:

* конфліктам
* одночасним `apply`
* пошкодженню state

---

## 💸 Вартість (важливо)

Платні ресурси:

* NAT Gateway ⚠️
* EKS Cluster ⚠️
* EC2 (Node Group)

👉 Після завершення перевірки ОБОВʼЯЗКОВО:

```bash
terraform destroy
```

---

## 🧠 Що прокачує цей проєкт

* Terraform (IaC)
* Remote state
* AWS networking (VPC)
* AWS ECR / EKS
* Docker
* Kubernetes
* Helm
* Autoscaling
* базові security practices

---

## 🔧 Можливі покращення

* Ingress + TLS (cert-manager)
* Secrets замість ConfigMap для чутливих даних
* CI/CD через Jenkins / GitHub Actions
* GitOps через ArgoCD
* Monitoring через Prometheus + Grafana
* S3 encryption через KMS

---

## 📌 Висновок

Цей проєкт демонструє повний DevOps цикл:

👉 від інфраструктури до працюючого застосунку з автоскейлом у Kubernetes.

---

## ⚠️ Cleanup

Не забудь:

```bash
terraform destroy
```

Інакше будеш платити за AWS 😄
