#!/bin/bash
# Firezone Gateway Fix Script
# Run this script to restart and fix common Firezone gateway issues

echo "=== Firezone Gateway Fix Script ==="
echo "Timestamp: $(date)"
echo

# Ensure we're in the right directory
cd /opt/firezone || { echo "❌ Firezone directory not found"; exit 1; }

echo "1. Stopping existing Firezone containers..."
sudo -u azureuser docker compose down
sleep 5

echo "2. Checking Docker status..."
if ! systemctl is-active --quiet docker; then
    echo "Starting Docker..."
    sudo systemctl start docker
    sleep 10
fi

echo "3. Pulling latest Firezone gateway image..."
sudo -u azureuser docker compose pull

echo "4. Starting Firezone gateway..."
sudo -u azureuser docker compose up -d

echo "5. Waiting for containers to start..."
sleep 30

echo "6. Checking container status..."
sudo -u azureuser docker compose ps

echo "7. Checking logs..."
sudo -u azureuser docker compose logs --tail=10

echo "8. Testing health endpoint..."
sleep 10
curl -s http://localhost:8080 || echo "Health endpoint not responding yet"

echo
echo "=== Fix Complete ==="
echo "Check Firezone admin portal in 2-3 minutes for gateway status"
echo "If still not working, check logs with:"
echo "  sudo -u azureuser docker compose logs -f"