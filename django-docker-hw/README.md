# Django Docker Homework

Цей проєкт демонструє контейнеризацію вебзастосунку Django з використанням PostgreSQL та Nginx.

## Склад проєкту

- **web** — Django-застосунок
- **db** — PostgreSQL база даних
- **nginx** — вебсервер для проксирування запитів до Django

## Структура проєкту

```text
django-docker-hw/
├─ app/
│  ├─ Dockerfile
│  ├─ manage.py
│  ├─ requirements.txt
│  └─ mysite/
├─ nginx/
│  └─ nginx.conf
├─ docker-compose.yml
├─ .gitignore
└─ README.md
```

## Використані технології

- Python 3.11
- Django
- PostgreSQL 15
- Nginx
- Docker
- Docker Compose

## Запуск проєкту

### 1. Клонувати репозиторій

```bash
git clone <your-repository-url>
cd django-docker-hw
```

### 2. Запустити контейнери

```bash
docker-compose up --build -d
```

### 3. Виконати міграції

```bash
docker-compose exec web python manage.py migrate
```

### 4. Відкрити проєкт у браузері

http://localhost

## Конфігурація сервісів

### Django
Django запускається в контейнері web через Gunicorn на порту 8000.

### PostgreSQL
- DB_NAME: mydb
- DB_USER: myuser
- DB_PASSWORD: mypassword
- DB_HOST: db
- DB_PORT: 5432

### Nginx
Nginx працює як reverse proxy і перенаправляє HTTP-запити на Django.

## Перевірка роботи

Після запуску:
- контейнери web, db, nginx повинні бути в статусі Up
- сторінка Django відкривається на http://localhost

Перевірка:

```bash
docker ps
```

## Автор
Serhii Palamarchuk


