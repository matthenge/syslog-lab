#!/bin/bash

echo "Stopping all containers..."
docker-compose down

echo "Starting containers..."
docker-compose up -d

echo "Waiting for containers to initialize (30 seconds)..."
sleep 30

echo "Checking container status..."
docker-compose ps

echo "Showing recent container logs..."

echo "=== FIREWALL LOGS ==="
docker-compose logs --tail=20 firewall

echo "=== WEBSERVER LOGS ==="
docker-compose logs --tail=20 webserver

echo "=== ROUTER LOGS ==="
docker-compose logs --tail=20 router

echo "=== SURICATA LOGS ==="
docker-compose logs --tail=20 suricata

echo "=== GRAYLOG LOGS ==="
docker-compose logs --tail=20 graylog

echo ""
echo "If containers are still restarting, examine logs for specific errors."
echo "You can get more detailed logs with: docker-compose logs <container-name>"
