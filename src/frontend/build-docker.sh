#!/bin/bash
set -e

NEXUS_DOCKER_URL="93.77.166.24:8081"
NEXUS_USER="student"
NEXUS_PASSWORD="1iRd|OjBGq9V"
REPO_NAME="fajzullinid-frontend-docker"
IMAGE_NAME="sandbox-frontend"
TAG="latest"

echo "=== Логин в Nexus Docker Registry ==="
echo "$NEXUS_PASSWORD" | docker login "$NEXUS_DOCKER_URL" -u "$NEXUS_USER" --password-stdin

echo "=== Сборка образа ${IMAGE_NAME}:${TAG} ==="
docker build -t "${IMAGE_NAME}:${TAG}" .

FULL_IMAGE_NAME="${NEXUS_DOCKER_URL}/${REPO_NAME}/${IMAGE_NAME}:${TAG}"
echo "=== Тегирование в ${FULL_IMAGE_NAME} ==="
docker tag "${IMAGE_NAME}:${TAG}" "${FULL_IMAGE_NAME}"

echo "=== Пуш в Nexus ==="
docker push "${FULL_IMAGE_NAME}"

echo "=== Готово! Образ ${FULL_IMAGE_NAME} запушен в Nexus ==="