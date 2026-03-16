#!/bin/bash
# Firezone Gateway Troubleshooting Script
# Run this script on each gateway VM to diagnose connection issues

echo "=== Firezone Gateway Troubleshooting ==="
echo "Timestamp: $(date)"
echo

echo "1. Checking startup script completion..."
if [ -f /var/log/firezone-startup.log ]; then
    echo "✅ Startup log exists"
    echo "Last 10 lines of startup log:"
    tail -10 /var/log/firezone-startup.log
else
    echo "❌ Startup log not found - script may not have run"
fi
echo

echo "2. Checking Docker status..."
if systemctl is-active --quiet docker; then
    echo "✅ Docker is running"
else
    echo "❌ Docker is not running"
    echo "Starting Docker..."
    sudo systemctl start docker
fi
echo

echo "3. Checking Firezone directory..."
if [ -d /opt/firezone ]; then
    echo "✅ Firezone directory exists"
    cd /opt/firezone
    
    echo "4. Checking environment file..."
    if [ -f .env ]; then
        echo "✅ Environment file exists"
        echo "Environment variables (token masked):"
        cat .env | sed 's/FIREZONE_TOKEN=.*/FIREZONE_TOKEN=***MASKED***/'
    else
        echo "❌ Environment file missing"
    fi
    echo
    
    echo "5. Checking Docker Compose file..."
    if [ -f docker-compose.yml ]; then
        echo "✅ Docker Compose file exists"
    else
        echo "❌ Docker Compose file missing"
    fi
    echo
    
    echo "6. Checking Firezone containers..."
    echo "Container status:"
    sudo -u azureuser docker compose ps
    echo
    
    echo "7. Checking Firezone logs..."
    echo "Recent logs:"
    sudo -u azureuser docker compose logs --tail=20
    echo
    
else
    echo "❌ Firezone directory not found"
fi

echo "8. Checking network connectivity..."
echo "Testing internet connectivity:"
curl -s --connect-timeout 5 https://api.firezone.dev > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Can reach Firezone API"
else
    echo "❌ Cannot reach Firezone API"
fi
echo

echo "9. Checking firewall status..."
if command -v ufw >/dev/null 2>&1; then
    echo "UFW status:"
    sudo ufw status
else
    echo "UFW not installed"
fi
echo

echo "10. Checking system resources..."
echo "Memory usage:"
free -h
echo
echo "Disk usage:"
df -h /
echo

echo "=== Troubleshooting Complete ==="
echo "If containers are not running, try:"
echo "  cd /opt/firezone"
echo "  sudo -u azureuser docker compose down"
echo "  sudo -u azureuser docker compose up -d"
echo
echo "To restart Firezone service:"
echo "  sudo systemctl restart firezone-gateway"