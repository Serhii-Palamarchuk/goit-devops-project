# 🚀 Lesson 8-9 — Jenkins, Argo CD, EKS & GitOps CI/CD Pipeline

## 📌 Опис проєкту

Цей проєкт демонструє повний DevOps CI/CD pipeline у Kubernetes на базі AWS EKS.

У гілці `lesson-db-module` проєкт додатково розширено універсальним Terraform-модулем `rds`, який може створювати звичайну RDS instance або Aurora Cluster залежно від параметра `use_aurora`.

Реалізовано:

* Terraform інфраструктура
* Remote Terraform state в S3
* State locking через DynamoDB
* VPC з public/private subnets
* ECR repository для Docker images
* EKS cluster з worker nodes
* EBS CSI Driver для persistent volumes
* Jenkins встановлений через Helm + Terraform
* Jenkins Kubernetes Agent
* Kaniko build без Docker daemon
* Push Docker image в AWS ECR
* Автоматичне оновлення Helm `values.yaml`
* Argo CD встановлений через Helm + Terraform
* Argo CD Application для GitOps-деплою Django app
* Django app задеплоєний у EKS через Helm chart
* LoadBalancer доступ до Jenkins, Argo CD та Django app
* Універсальний Terraform-модуль `rds`
* Підтримка звичайної RDS instance або Aurora Cluster через параметр `use_aurora`
* Автоматичне створення DB Subnet Group, Security Group та Parameter Group для бази даних

Проєкт демонструє повний цикл:

```text
GitHub → Jenkins → Kaniko → ECR → values.yaml → Argo CD → EKS → Django app
```

Окремо для баз даних реалізовано Terraform-модуль:

```text
Terraform → modules/rds → RDS або Aurora
```

---

## 🏗️ Архітектура

### AWS / Terraform

* **S3 Bucket** — зберігання Terraform state
* **DynamoDB** — блокування Terraform state
* **VPC `10.0.0.0/16`**
  * 3 public subnets
  * 3 private subnets
  * Internet Gateway
  * NAT Gateway
* **ECR Repository** — зберігання Docker images
* **EKS Cluster** — Kubernetes cluster
* **Managed Node Group** — worker nodes
* **EBS CSI Driver** — динамічне створення EBS volume для PVC
* **OIDC / IRSA** — IAM role для EBS CSI Driver
* **RDS / Aurora**
  * стандартна RDS instance, якщо `use_aurora = false`
  * Aurora Cluster + writer instance, якщо `use_aurora = true`
  * DB Subnet Group
  * Security Group
  * Parameter Group

---

### Kubernetes

* **Namespace `jenkins`**
  * Jenkins controller
  * Jenkins agent service
  * PVC для Jenkins через `gp3`
* **Namespace `argocd`**
  * Argo CD server
  * Argo CD repo-server
  * Argo CD application-controller
  * Redis
  * Dex
* **Namespace `django-app`**
  * Django Deployment
  * Django Service LoadBalancer
  * HPA
  * ConfigMap

---

## 📁 Структура проєкту

```text
lesson-8-9/
│
├── app/
│   ├── Dockerfile
│   ├── manage.py
│   ├── requirements.txt
│   └── mysite/
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
│
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   ├── ecr/
│   ├── eks/
│   ├── jenkins/
│   ├── argo_cd/
│   └── rds/
│       ├── shared.tf
│       ├── rds.tf
│       ├── aurora.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── Jenkinsfile
├── main.tf
├── backend.tf.bak
├── outputs.tf
└── README.md
```

---

## 🧩 Terraform модулі

### 🔹 s3-backend

Відповідає за:

* створення S3 bucket
* увімкнення versioning
* server-side encryption
* блокування публічного доступу
* створення DynamoDB table для state locking

---

### 🔹 vpc

Створює:

* VPC `10.0.0.0/16`
* Public subnets:
  * `10.0.1.0/24`
  * `10.0.2.0/24`
  * `10.0.3.0/24`
* Private subnets:
  * `10.0.4.0/24`
  * `10.0.5.0/24`
  * `10.0.6.0/24`
* Internet Gateway
* NAT Gateway
* Route Tables

---

### 🔹 ecr

Створює:

* ECR repository `lesson-8-9-ecr`
* image scanning on push
* repository policy
* lifecycle policy для обмеження кількості старих images

---

### 🔹 eks

Створює:

* EKS cluster `lesson-8-9-eks`
* IAM role для EKS control plane
* IAM role для worker nodes
* managed node group
* EBS CSI Driver addon
* OIDC provider
* IRSA role для `ebs-csi-controller-sa`

---

### 🔹 jenkins

Створює:

* namespace `jenkins`
* StorageClass `gp3`
* Jenkins через Helm chart
* LoadBalancer service
* PVC для Jenkins controller

Jenkins встановлений через Terraform + Helm відповідно до умов завдання.

---

### 🔹 argo_cd

Створює:

* namespace `argocd`
* Argo CD через Helm chart
* LoadBalancer service для Argo CD UI
* Argo CD Application `django-app`
* namespace `django-app`

---

### 🔹 rds

Універсальний Terraform-модуль для створення бази даних.

Модуль підтримує два режими роботи:

* `use_aurora = false` — створюється звичайна `aws_db_instance`
* `use_aurora = true` — створюється `aws_rds_cluster` та writer instance `aws_rds_cluster_instance`

Модуль автоматично створює спільні ресурси:

* `aws_db_subnet_group`
* `aws_security_group`
* `aws_db_parameter_group` для звичайної RDS
* `aws_rds_cluster_parameter_group` для Aurora

Основні файли модуля:

```text
modules/rds/
├── shared.tf      # DB Subnet Group, Security Group, Parameter Groups
├── rds.tf         # Standard RDS instance
├── aurora.tf      # Aurora Cluster + writer instance
├── variables.tf   # Input variables
└── outputs.tf     # Module outputs
```

#### Приклад використання модуля

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "lesson-db"
  use_aurora = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_cidr_blocks = ["10.0.0.0/16"]

  db_name  = "appdb"
  username = "dbadmin"
  password = var.db_password

  engine         = "postgres"
  engine_version = "16.13"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  multi_az          = false

  publicly_accessible = false

  tags = {
    Project = "lesson-db-module"
    Managed = "terraform"
  }
}
```

#### Основні змінні модуля

| Змінна | Опис | Приклад |
|---|---|---|
| `name` | Префікс імені ресурсів бази даних | `lesson-db` |
| `use_aurora` | Перемикач між Aurora та звичайною RDS | `false` або `true` |
| `vpc_id` | ID VPC, де створюється база | `module.vpc.vpc_id` |
| `subnet_ids` | Список private subnet IDs для DB Subnet Group | `module.vpc.private_subnet_ids` |
| `allowed_cidr_blocks` | CIDR blocks, яким дозволено доступ до БД | `["10.0.0.0/16"]` |
| `db_name` | Назва бази даних | `appdb` |
| `username` | Master username | `dbadmin` |
| `password` | Master password, передається через sensitive variable | `var.db_password` |
| `engine` | Тип database engine | `postgres`, `mysql`, `aurora-postgresql`, `aurora-mysql` |
| `engine_version` | Версія database engine | `16.3` |
| `instance_class` | Клас інстансу | `db.t3.micro` |
| `allocated_storage` | Розмір диску для звичайної RDS | `20` |
| `multi_az` | Multi-AZ для звичайної RDS | `false` |
| `publicly_accessible` | Чи буде база доступна публічно | `false` |
| `backup_retention_period` | Кількість днів збереження backup | `1` |
| `skip_final_snapshot` | Пропустити final snapshot при destroy | `true` |
| `deletion_protection` | Захист від видалення | `false` |
| `tags` | Теги для ресурсів | `{ Project = "lesson-db-module" }` |

#### Як змінити тип бази даних

Звичайна PostgreSQL RDS:

```hcl
use_aurora     = false
engine         = "postgres"
engine_version = "16.13"
instance_class = "db.t3.micro"
```

Звичайна MySQL RDS:

```hcl
use_aurora     = false
engine         = "mysql"
engine_version = "8.0"
instance_class = "db.t3.micro"
```

Aurora PostgreSQL:

```hcl
use_aurora     = true
engine         = "aurora-postgresql"
engine_version = "16.13"
instance_class = "db.r6g.large"
```

Aurora MySQL:

```hcl
use_aurora     = true
engine         = "aurora-mysql"
engine_version = "8.0.mysql_aurora.3.05.2"
instance_class = "db.r6g.large"
```

Для зміни класу інстансу потрібно змінити значення `instance_class`. Наприклад:

```hcl
instance_class = "db.t3.small"
```

Для ввімкнення Multi-AZ у звичайній RDS:

```hcl
multi_az = true
```

Для перемикання на Aurora достатньо встановити:

```hcl
use_aurora = true
```

---

## ⚙️ Terraform запуск

### 1. Ініціалізація

```bash
terraform init
```

або після зміни backend/module:

```bash
terraform init -reconfigure
```

### 2. Перевірка

```bash
terraform validate
```

### 3. Передача пароля для RDS

Пароль бази даних не зберігається в коді. Його потрібно передати через Terraform variable.

У Git Bash:

```bash
read -s TF_VAR_db_password
export TF_VAR_db_password
```

Або напряму для плану:

```bash
terraform plan -var="db_password=<your-secure-password>"
```

### 4. План

```bash
terraform plan
```

### 5. Застосування

```bash
terraform apply
```

---

## ☸️ Підключення до EKS

```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-8-9-eks
kubectl get nodes
```

---

## 🐳 Docker image build через Jenkins + Kaniko

Pipeline описаний у:

```text
lesson-8-9/Jenkinsfile
```

Jenkins pipeline виконує:

1. Створює Kubernetes agent pod
2. Запускає container `kaniko`
3. Build Docker image з:

```text
lesson-8-9/app/Dockerfile
```

4. Push image в ECR:

```text
493947253485.dkr.ecr.us-west-2.amazonaws.com/lesson-8-9-ecr
```

5. Оновлює image tag у:

```text
lesson-8-9/charts/django-app/values.yaml
```

6. Комітить зміну
7. Push у GitHub
8. Argo CD автоматично синхронізує застосунок

---

## 🔐 Jenkins credentials

Для push у GitHub створено Jenkins credential:

```text
ID: github-token
Kind: Username with password
Username: Serhii-Palamarchuk
Password: GitHub Personal Access Token
```

Для Kaniko створено Kubernetes secret:

```bash
kubectl create secret generic ecr-docker-config \
  --from-file=config.json=/tmp/ecr-config.json \
  -n jenkins
```

---

## 🧪 Jenkins перевірка

### Jenkins pod

```bash
kubectl get pods -n jenkins
```

Очікувано:

```text
jenkins-0   2/2   Running
```

### Jenkins service

```bash
kubectl get svc -n jenkins
```

Jenkins доступний через LoadBalancer:

```text
http://<jenkins-load-balancer>:8080
```

### Jenkins Kubernetes Agent test

Було перевірено тестовим pipeline:

```text
git version
Jenkins Kubernetes agent works
```

---

## 🚀 Argo CD

Argo CD встановлено через Terraform + Helm.

### Перевірка pod-ів

```bash
kubectl get pods -n argocd
```

Очікувано всі pod-и:

```text
Running
```

### Argo CD service

```bash
kubectl get svc -n argocd
```

Argo CD доступний через LoadBalancer:

```text
https://<argocd-load-balancer>
```

### Отримати admin password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

Логін:

```text
admin
```

---

## 🔄 Argo CD Application

Terraform створює Argo CD Application:

```text
django-app
```

Application дивиться на:

```text
Repository: https://github.com/Serhii-Palamarchuk/goit-devops-project.git
Branch: main
Path: lesson-8-9/charts/django-app
Namespace: django-app
```

Sync policy:

```text
automated
prune: true
selfHeal: true
```

---

## 📦 Django app deployment

Django app розгортається через Helm chart:

```text
lesson-8-9/charts/django-app
```

### Перевірка Argo CD Application

```bash
kubectl get applications -n argocd
```

Очікувано:

```text
NAME         SYNC STATUS   HEALTH STATUS
django-app   Synced        Healthy
```

### Перевірка pod-ів Django

```bash
kubectl get pods -n django-app
```

Очікувано:

```text
django-app-...   1/1   Running
django-app-...   1/1   Running
```

### Перевірка service

```bash
kubectl get svc -n django-app
```

Очікувано:

```text
django-app-service   LoadBalancer   ...   <external-dns>   80:xxxxx/TCP
```

---

## 🌐 Доступ до Django app

Поточний LoadBalancer DNS:

```text
http://a5cf23d9065544622a57ea3cf27a7dc9-1167017426.us-west-2.elb.amazonaws.com
```

Результат:

```text
The install worked successfully! Congratulations!
```

---

## ✅ Фінальна перевірка

```bash
kubectl get pods -n jenkins
kubectl get pods -n argocd
kubectl get applications -n argocd
kubectl get pods -n django-app
kubectl get svc -n django-app
```

Приклад фінального стану:

```text
jenkins-0   2/2   Running

argocd-application-controller-0       1/1   Running
argocd-server-...                     1/1   Running
argocd-repo-server-...                1/1   Running

django-app   Synced   Healthy

django-app-...   1/1   Running
django-app-...   1/1   Running

django-app-service   LoadBalancer   ...   a5cf23d9065544622a57ea3cf27a7dc9-1167017426.us-west-2.elb.amazonaws.com
```

---

## 🛠 Troubleshooting

### Jenkins PVC Pending

Причина:

```text
no storage class is set
```

Рішення:

* встановити EBS CSI Driver
* створити StorageClass `gp3`
* зробити `gp3` default StorageClass

---

### EBS CSI Driver CrashLoopBackOff

Причина:

```text
no EC2 IMDS role found
```

Рішення:

* додати OIDC provider
* створити IRSA IAM role
* привʼязати `AmazonEBSCSIDriverPolicy`
* передати `service_account_role_arn` в `aws_eks_addon`

---

### Kaniko не пушить в ECR

Помилка:

```text
docker-credential-desktop: executable file not found
```

Причина:

* Kubernetes secret був створений з Docker Desktop config, де використовується `credsStore`

Рішення:

* створити чистий `/tmp/ecr-config.json` з auth token
* перестворити secret `ecr-docker-config`

---

### Git push з Jenkins не працює

Помилка:

```text
could not read Username for 'https://github.com'
```

Рішення:

* створити GitHub Personal Access Token
* додати Jenkins credential `github-token`
* використати `withCredentials` у Jenkinsfile

---

### Git dubious ownership

Помилка:

```text
detected dubious ownership
```

Рішення:

```bash
git config --global --add safe.directory ${WORKSPACE}
```

---

## 💸 Вартість

Платні ресурси:

* EKS Cluster
* EC2 worker nodes
* NAT Gateway
* LoadBalancers
* EBS volume для Jenkins PVC
* ECR storage
* RDS instance або Aurora Cluster
* RDS storage та backups

Після завершення перевірки обовʼязково видалити ресурси:

```bash
terraform destroy
```

Також бажано перевірити AWS Console:

* EC2 Load Balancers
* EBS Volumes
* NAT Gateways
* EKS
* ECR
* S3
* DynamoDB
* RDS / Aurora
* DB snapshots

---

## 🧠 Lessons Learned

* Jenkins Helm chart потребує persistent storage
* Для PVC в EKS потрібен EBS CSI Driver
* Для EBS CSI краще використовувати IRSA, а не node role
* Kaniko дозволяє збирати Docker images без Docker daemon
* Jenkins відповідає за CI
* Argo CD відповідає за CD
* Git є source of truth для GitOps
* Argo CD автоматично синхронізує кластер зі станом у Git
* `values.yaml` може бути точкою інтеграції між CI і CD
* LoadBalancer service створює AWS ELB і може генерувати витрати
* Terraform-модулі краще робити універсальними та багаторазовими
* Через `count` можна умовно створювати різні типи ресурсів залежно від змінної `use_aurora`
* Паролі та інші секрети не варто зберігати в Terraform-коді або README

---

## 🔧 Можливі покращення

* Ingress замість окремих LoadBalancer service
* TLS через cert-manager
* External Secrets або AWS Secrets Manager
* Окремий GitOps repository
* Argo CD Image Updater замість commit з Jenkins
* Prometheus + Grafana monitoring
* Slack/Email notifications для Jenkins або Argo CD
* Обмеження доступу до Jenkins і Argo CD через security groups / ingress rules

---

## 📌 Висновок

У межах роботи реалізовано повний CI/CD процес:

```text
GitHub → Jenkins → Kaniko → ECR → Git update → Argo CD → EKS
```

Jenkins автоматично збирає Docker image Django застосунку та пушить його в ECR.  
Після цього Jenkins оновлює Helm `values.yaml`, а Argo CD автоматично синхронізує зміни та деплоїть нову версію застосунку в EKS.

Також додано універсальний Terraform-модуль `rds`, який дозволяє створювати стандартну RDS instance або Aurora Cluster з мінімальною зміною параметрів.

Результат: Django app успішно працює в Kubernetes і доступний через AWS LoadBalancer.

---

## ⚠️ Cleanup

Щоб уникнути витрат AWS:

```bash
terraform destroy
```

Після цього перевірити, що не залишились:

* LoadBalancers
* EBS volumes
* NAT Gateway
* EKS cluster
* EC2 instances
* ECR images
* RDS / Aurora databases
* DB snapshots
