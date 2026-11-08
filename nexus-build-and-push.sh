#!/bin/bash
set -e

# --- Настройки ---
NEXUS_URL="http://93.77.166.24:8081"
NEXUS_USER="student"
NEXUS_PASSWORD="1iRd|OjBGq9V"
BACKEND_REPO="fajzullinid-backend-docker"
FRONTEND_REPO="fajzullinid-frontend-docker"
OUTPUT_DIR="./output"

VERSION=$(date -u +"%Y%m%dT%H%M%SZ")
echo "=== Текущая версия: $VERSION ==="

mkdir -p "$OUTPUT_DIR"

# --- 1. Упаковка бэкенда ---
echo "=== [1/4] Упаковка исходников бэкенда ==="
tar -czvf "$OUTPUT_DIR/sandbox-backend-src.tar.gz" -C ./src/backend .

# --- 2. Упаковка фронтенда ---
echo "=== [2/4] Упаковка исходников фронтенда ==="
tar -czvf "$OUTPUT_DIR/sandbox-frontend-src.tar.gz" -C ./src/frontend .

# --- 3. Пуш бэкенда в Nexus ---
echo "=== [3/4] Пуш бэкенда в Nexus ==="
curl -s -v -u "${NEXUS_USER}:${NEXUS_PASSWORD}" \
  --upload-file "$OUTPUT_DIR/sandbox-backend-src.tar.gz" \
  "${NEXUS_URL}/repository/${BACKEND_REPO}/${VERSION}/sandbox-backend-src-${VERSION}.tar.gz"

# --- 4. Пуш фронтенда в Nexus ---
echo "=== [4/4] Пуш фронтенда в Nexus ==="
curl -s -v -u "${NEXUS_USER}:${NEXUS_PASSWORD}" \
  --upload-file "$OUTPUT_DIR/sandbox-frontend-src.tar.gz" \
  "${NEXUS_URL}/repository/${FRONTEND_REPO}/${VERSION}/sandbox-frontend-src-${VERSION}.tar.gz"

echo "=== Готово ==="