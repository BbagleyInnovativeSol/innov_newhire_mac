#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
# 1. Configuration – change these if you use a different image.
# ──────────────────────────────────────────────────────────────
IMAGE="dockurr/macos:latest"          # Minimal macOS container (Apple‑Silicon friendly)
CONTAINER_NAME="macos_installer"
INSTALL_SCRIPT="./install.sh"        # Path to the script that installs apps

# ──────────────────────────────────────────────────────────────
# 2. Pull the image (will skip if already present).
# ──────────────────────────────────────────────────────────────
echo "🔍 Pulling Docker image $IMAGE ..."
docker pull "$IMAGE"

# ──────────────────────────────────────────────────────────────
# 3. Start the container (detached, with a tty for interactive commands).
# ──────────────────────────────────────────────────────────────
echo "🚀 Starting container $CONTAINER_NAME ..."
docker run -d --name "$CONTAINER_NAME" \
    -v /tmp:/tmp \
    "$IMAGE" sleep 99999

# Wait a moment for it to fully start
sleep 2

# Confirm it's running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}\$"; then
    echo "❌ Container failed to start."
    exit 1
fi  

# ──────────────────────────────────────────────────────────────
# 4. Copy the install script into the container.
# ──────────────────────────────────────────────────────────────
echo "📦 Copying install script into the container ..."
docker cp "$INSTALL_SCRIPT" "${CONTAINER_NAME}:/root/install.sh"
docker exec -it "$CONTAINER_NAME" ls -l /root/install.sh

# Error on this, canot find file
docker start "$CONTAINER_NAME"
docker exec -it "$CONTAINER_NAME" chmod +x /root/install.sh

# ──────────────────────────────────────────────────────────────
# 5. Run the install script inside the container.
# ──────────────────────────────────────────────────────────────
echo "🛠️  Running installation script ..."
docker exec -it "$CONTAINER_NAME" /root/install.sh

# ──────────────────────────────────────────────────────────────
# 6. Verify the installations.
# ──────────────────────────────────────────────────────────────
echo "✅ Verifying installations ..."
declare -A VERIFY=(
    ["brew"]="brew --version"
    ["node"]="node --version"
    ["npm"]="npm --version"
    ["python3"]="python3 --version"
    ["awscli"]="aws --version"
)

for cmd in "${!VERIFY[@]}"; do
    echo -n "   • $cmd: "
    if docker exec "$CONTAINER_NAME" bash -c "${VERIFY[$cmd]}" &>/dev/null; then
        echo "✓"
    else
        echo "✗  (not found)"
    fi
done

# ──────────────────────────────────────────────────────────────
# 7. (Optional) Stop and remove the container.
# ──────────────────────────────────────────────────────────────
read -p "🧹  Remove container? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker rm -f "$CONTAINER_NAME"
    echo "🗑️  Container removed."
else
    echo "🛡️  Leaving container running for debugging."
fi

echo "🎉 Done!"

