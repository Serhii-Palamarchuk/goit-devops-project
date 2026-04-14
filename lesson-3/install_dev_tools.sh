#!/usr/bin/env bash

set -e

echo "=== Dev tools installation started ==="

# Перевірка sudo
if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is not installed. Please install sudo first."
  exit 1
fi

# Оновлення індексу пакетів
sudo apt update

# ----------------------------
# Install Docker
# ----------------------------
if command -v docker >/dev/null 2>&1; then
  echo "Docker is already installed: $(docker --version)"
else
  echo "Installing Docker..."
  sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
  echo "Docker installed successfully."
fi

# ----------------------------
# Install Docker Compose
# ----------------------------
if docker compose version >/dev/null 2>&1; then
  echo "Docker Compose is already installed: $(docker compose version)"
elif command -v docker-compose >/dev/null 2>&1; then
  echo "Docker Compose is already installed: $(docker-compose --version)"
else
  echo "Installing Docker Compose..."
  sudo apt install -y docker-compose-plugin
  echo "Docker Compose installed successfully."
fi

# ----------------------------
# Install Python 3.9+
# ----------------------------
if command -v python3 >/dev/null 2>&1; then
  PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')
  PYTHON_MAJOR=$(python3 -c 'import sys; print(sys.version_info[0])')
  PYTHON_MINOR=$(python3 -c 'import sys; print(sys.version_info[1])')

  if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 9 ]; then
    echo "Python is already installed: Python $PYTHON_VERSION"
  else
    echo "Python version is lower than 3.9. Installing newer Python..."
    sudo apt install -y python3 python3-pip python3-venv
  fi
else
  echo "Installing Python..."
  sudo apt install -y python3 python3-pip python3-venv
fi

# ----------------------------
# Install pip
# ----------------------------
if command -v pip3 >/dev/null 2>&1; then
  echo "pip is already installed: $(pip3 --version)"
else
  echo "Installing pip..."
  sudo apt install -y python3-pip
fi

# ----------------------------
# Install Django
# ----------------------------
if python3 -m pip show django >/dev/null 2>&1; then
  echo "Django is already installed: $(python3 -m pip show django | grep Version)"
else
  echo "Installing Django..."
  python3 -m pip install --break-system-packages django
  echo "Django installed successfully."
fi

# Fix PATH for user-installed pip packages
if ! grep -q "$HOME/.local/bin" ~/.bashrc; then
  echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
  echo "Added ~/.local/bin to PATH. Restart terminal or run: source ~/.bashrc"
fi

echo "=== Installation completed ==="
echo "Installed versions:"
docker --version || true
docker compose version || docker-compose --version || true
python3 --version || true
python3 -m pip show django | grep Version || true