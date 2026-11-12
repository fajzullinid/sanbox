#!/bin/bash
set -e

# --- Загрузка переменных окружения ---
# Ищем .env в корне проекта (на два уровня выше, чем папка frontend)
ENV_PATH="$(dirname "$0")/../../.env"

if [ -f "$ENV_PATH" ]; then
    source "$ENV_PATH"
else
    echo "Ошибка: Файл .env не найден по пути $ENV_PATH"
    exit 1
fi

# --- Настройки ---
REPO_NAME="fajzullinid-frontend-docker"
IMAGE_NAME="sandbox-frontend"
TAG="latest"

# --- Логин в Nexus ---
echo "=== Логин в Nexus Docker Registry ==="
echo "$NEXUS_PASSWORD" | docker login "$NEXUS_DOCKER_URL" -u "$NEXUS_USER" --password-stdin

# --- Сборка образа ---
echo "=== Сборка образа ${IMAGE_NAME}:${TAG} ==="
docker build -t "${IMAGE_NAME}:${TAG}" .

# --- Тегирование и пуш ---
FULL_IMAGE_NAME="${NEXUS_DOCKER_URL}/${REPO_NAME}/${IMAGE_NAME}:${TAG}"
echo "=== Тегирование в ${FULL_IMAGE_NAME} ==="
docker tag "${IMAGE_NAME}:${TAG}" "${FULL_IMAGE_NAME}"

echo "=== Пуш в Nexus ==="
docker push "${FULL_IMAGE_NAME}"

echo "=== Готово! Образ ${FULL_IMAGE_NAME} запушен в Nexus ==="