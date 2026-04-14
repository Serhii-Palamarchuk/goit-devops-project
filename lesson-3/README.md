# DevOps Homework - Linux Administration 🐧

## 📌 Description

This project contains a Bash script for automatic installation of basic DevOps tools:

* Docker
* Docker Compose
* Python (3.9+)
* Django

The script checks if each tool is already installed to avoid duplication.

---

## ⚙️ Requirements

* Ubuntu / Debian
* sudo privileges
* Internet connection

---

## 🚀 Usage

### 1. Clone repository

```bash
git clone <your-repo-url>
cd <your-repo>
```

### 2. Make script executable

```bash
chmod u+x install_dev_tools.sh
```

### 3. Run script

```bash
./install_dev_tools.sh
```

---

## 🔍 What the script does

* Updates package list (`apt update`)
* Installs Docker (if not installed)
* Installs Docker Compose
* Checks Python version (>= 3.9)
* Installs pip
* Installs Django via pip
* Adds `~/.local/bin` to PATH (if needed)

---

## 📦 Installed tools check

After execution you can verify:

```bash
docker --version
docker compose version
python3 --version
django-admin --version
```

---

## ⚠️ Notes

* In WSL (Windows Subsystem for Linux), Docker may require enabling integration via Docker Desktop.
* Script is compatible with Ubuntu / Debian systems.

---

## 🧠 Author

Serhii

---

## ✅ Status

✔ Completed
✔ Meets all homework requirements
