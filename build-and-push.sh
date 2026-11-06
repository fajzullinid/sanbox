#!/bin/bash

# env
NEXUS_URL="http://93.77.166.24:8081"
NEXUS_USER="student"
NEXUS_PASSWORD="1iRd|OjBGq9V"
BACKEND_REPO="fajzullinid-backend"
FRONTEND_REPO="fajzullinid-frontend"

VERSION=$(date -u +"%Y%m%dT%H%M%SZ")
echo "=== Текущая версия: $VERSION ==="

# --- 1. Сборка и запуск через Docker Compose ---
echo "=== [1/3] Сборка и запуск через Docker Compose ==="
# Останавливаем старые контейнеры и собираем новые
docker compose down
docker compose up -d --build

# Ждем пару секунд, чтобы контейнеры поднялись
sleep 5

# --- 2. Сборка артефактов для Nexus ---
echo "=== [2/3] Подготовка артефактов ==="

# Бэкенд: собираем бинарник внутри контейнера (если его нет в образе)
# Но у нас в Dockerfile бэкенда уже есть бинарник. Вытащим его из образа.
# Проще всего использовать docker cp из запущенного контейнера.
# Но чтобы не ломать работающий контейнер, создадим временный.

# Вариант с docker cp из работающего контейнера (безопасно, если бинарник в /app)
# Но в нашем Dockerfile бэкенд лежит в /app/backend. 
# Однако, чтобы не гадать, лучше собрать бинарник отдельно через Go (как раньше).
# Но если ты хочешь всё через compose, можно вытащить из контейнера:
# docker cp backend:/app/backend ./output/app

# Давай сделаем надежнее: соберем бинарник внутри контейнера Go (как в прошлом скрипте)
docker run --rm -v "$(pwd)/src/backend:/app" -v "$(pwd)/output:/output" -w /app golang:1.23-alpine \
  sh -c "CGO_ENABLED=0 go build -o /output/app ./cmd/api"

# Упаковываем
cd output
tar -czvf "sandbox-backend-${VERSION}.tar.gz" app

# Фронтенд: собираем статику внутри контейнера Node и упаковываем
docker run --rm -v "$(pwd)/src/frontend:/app" -v "$(pwd)/output:/output" -w /app \
  -e NODE_OPTIONS="--openssl-legacy-provider" \
  node:16.20.0-alpine3.18 \
  sh -c "npm install && npm run build && tar -czvf /output/sandbox-frontend-${VERSION}.tar.gz -C dist ."

# --- 3. Пуш в Nexus ---
echo "=== [3/3] Пуш артефактов в Nexus ==="

curl -v -u "${NEXUS_USER}:${NEXUS_PASSWORD}" \
  --upload-file "sandbox-backend-${VERSION}.tar.gz" \
  "${NEXUS_URL}/repository/${BACKEND_REPO}/${VERSION}/sandbox-backend-${VERSION}.tar.gz"

curl -v -u "${NEXUS_USER}:${NEXUS_PASSWORD}" \
  --upload-file "sandbox-frontend-${VERSION}.tar.gz" \
  "${NEXUS_URL}/repository/${FRONTEND_REPO}/${VERSION}/sandbox-frontend-${VERSION}.tar.gz"

cd ..

echo "=== Готово! Сервисы запущены, артефакты в Nexus ==="