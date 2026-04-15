# 🚀 Lesson 7 - Kubernetes, Helm & EKS Deployment

## 📌 Опис проєкту

Цей проєкт демонструє повний DevOps pipeline:

👉 **Infrastructure → Container → Kubernetes → Helm → Autoscaling**

Реалізовано:

* Terraform інфраструктура (VPC, ECR, EKS)
* Docker контейнеризація Django застосунку
* Збереження образу в AWS ECR
* Розгортання застосунку в Kubernetes (EKS)
* Використання Helm chart
* Автоматичне масштабування (HPA)

Проєкт максимально наближений до реального production сценарію.

---

## 🏗️ Архітектура

### AWS (Terraform)

* **S3 Bucket** → Terraform state
* **DynamoDB** → state locking
* **VPC (10.0.0.0/16)**:

  * 3 Public Subnets
  * 3 Private Subnets
  * Internet Gateway
  * NAT Gateway
* **ECR Repository** → Docker образи
* **EKS Cluster** → Kubernetes
* **Node Group (t3.small)** → worker nodes

---

### Kubernetes (Helm)

* **Deployment** → Django app
* **Service (LoadBalancer)** → доступ з інтернету
* **ConfigMap** → env змінні
* **HPA (2–6 pods)** → автоскейл
* **metrics-server** → метрики CPU

---

## 📁 Структура проєкту

```
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

## 🔄 Deployment Flow

1. Terraform створює інфраструктуру (VPC, ECR, EKS)
2. Docker будує Django образ
3. Образ пушиться в AWS ECR
4. Helm розгортає застосунок в Kubernetes
5. Service типу LoadBalancer відкриває доступ
6. HPA автоматично масштабує поди при навантаженні

---

## ⚙️ Terraform — запуск

```bash
terraform init
terraform validate
terraform plan
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

### Встановлення

```bash
helm install django-app ./charts/django-app
```

### Перевірка

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
```

---

## 🌐 Доступ до застосунку

```bash
kubectl get svc
```

Використати LoadBalancer DNS:

http://af08d436a4ad14fd99faa78a131185e2-1859282388.us-west-2.elb.amazonaws.com

---

## 📈 Автоскейл (HPA)

```bash
kubectl get hpa
kubectl top pods
```

Приклад:

```
cpu: 1%/70%
```

---

## 🛠 Troubleshooting

### Pod не стартує

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

---

### ImagePullBackOff

👉 Перевірити:

* чи образ запушений в ECR
* чи правильний repository в values.yaml

---

### HPA показує `<unknown>`

👉 Встановити metrics-server:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

---

## ✅ Перевірка працездатності

```bash
kubectl get nodes
kubectl get pods
kubectl get svc
kubectl get hpa
kubectl top pods
```

---

## 🧠 Lessons Learned

* Робота з IAM може блокувати Terraform (AccessDenied)
* EKS створюється значно довше за інші ресурси
* Без metrics-server HPA не працює коректно
* Правильна структура Helm chart критична
* Важливо правильно тегати Docker image перед push

---

## ⚠️ Вартість

Платні ресурси:

* NAT Gateway ⚠️
* EKS Cluster ⚠️
* EC2 (Node Group)

---

## ⚠️ Cleanup

⚠️ EKS та NAT Gateway коштують гроші!

Після завершення:

```bash
terraform destroy
```

---

## 🧠 Що прокачує цей проєкт

* Terraform (IaC)
* AWS (VPC, ECR, EKS)
* Docker
* Kubernetes
* Helm
* Autoscaling
* DevOps pipeline

---

## 🔧 Можливі покращення

* Ingress + TLS (cert-manager)
* CI/CD (Jenkins / GitHub Actions)
* Secrets замість ConfigMap
* ArgoCD (GitOps)
* Monitoring (Prometheus + Grafana)

---

## 📌 Висновок

Проєкт демонструє повний цикл DevOps:

👉 від інфраструктури до працюючого застосунку з автоскейлом
