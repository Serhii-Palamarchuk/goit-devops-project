# 🚀 Lesson 5 - Terraform AWS Infrastructure

## 📌 Опис проєкту

Цей проєкт демонструє підхід **Infrastructure as Code (IaC)** з використанням Terraform для розгортання базової AWS-інфраструктури.

Реалізовано:

* централізоване зберігання Terraform state (S3 + DynamoDB)
* модульну архітектуру Terraform
* побудову мережевої інфраструктури (VPC)
* створення ECR для контейнерів

Проєкт максимально наближений до реального DevOps сценарію.

---

## 🏗️ Архітектура

Інфраструктура складається з:

* **S3 Bucket** → зберігання Terraform state
* **DynamoDB** → state locking
* **VPC (10.0.0.0/16)**:

  * 3 Public Subnets
  * 3 Private Subnets
  * Internet Gateway
  * NAT Gateway
* **ECR Repository** → зберігання Docker образів

---

## 📁 Структура проєкту

lesson-5/
│
├── main.tf
├── backend.tf
├── outputs.tf
├── README.md
│
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   └── ecr/

---

## 🧩 Модулі

### 🔹 s3-backend

Відповідає за:

* створення S3 bucket
* увімкнення versioning
* створення DynamoDB таблиці

👉 Використовується як backend для Terraform

---

### 🔹 vpc

Створює мережу:

* VPC: `10.0.0.0/16`
* Public subnets:

  * 10.0.1.0/24
  * 10.0.2.0/24
  * 10.0.3.0/24
* Private subnets:

  * 10.0.4.0/24
  * 10.0.5.0/24
  * 10.0.6.0/24

Також:

* Internet Gateway
* NAT Gateway (для доступу з private subnet)
* Route Tables

---

### 🔹 ecr

Створює:

* ECR repository
* автоматичне сканування образів

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

## 🚀 Як запустити

### 1. Ініціалізація

```
terraform init
```

### 2. Перевірка

```
terraform validate
```

### 3. План

```
terraform plan
```

### 4. Застосування

```
terraform apply
```

---

## 📤 Outputs

Після виконання:

* `s3_bucket_name`
* `dynamodb_table_name`
* `vpc_id`
* `public_subnet_ids`
* `private_subnet_ids`
* `ecr_repository_url`

---

## 🔒 Чому S3 + DynamoDB?

Це best practice в Terraform:

* S3 → централізоване зберігання state
* DynamoDB → блокування (lock)

👉 Запобігає:

* конфліктам
* одночасним apply
* пошкодженню state

---

## 💸 Вартість (важливо)

Деякі ресурси платні:

* NAT Gateway ⚠️ (~30$/міс)
* Elastic IP

👉 Після завершення ОБОВʼЯЗКОВО:

```
terraform destroy
```

---

## 🧠 Що прокачує цей проєкт

* Terraform modules
* Remote state
* AWS networking (VPC)
* роботу з ECR
* базову DevOps архітектуру

---

## 🔧 Можливі покращення

* S3 bucket encryption (KMS)
* IAM roles замість user
* Multi-AZ NAT Gateway
* VPC endpoints
* tagging strategy
* CI/CD через Jenkins / GitHub Actions

---

## 📌 Висновок

Цей проєкт демонструє базову, але реальну DevOps інфраструктуру, яку можна масштабувати під production.

---

## ⚠️ Cleanup

Не забудь:

```
terraform destroy
```

Інакше будеш платити за NAT Gateway 😄
