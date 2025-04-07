#!/bin/bash

# This script simulates various attacks to generate logs for analysis
# Modified for the simplified lab setup without full Suricata

echo "Starting attack simulations for log generation..."

# Target IP
WEB_SERVER="http://localhost:8080"

# 1. Simulate unauthorized admin panel access
echo "Simulating unauthorized admin panel access..."
curl -s "$WEB_SERVER/admin"
echo ""

# Generate a log on the firewall about this event
docker-compose exec firewall logger -t FIREWALL -p auth.warning "Unauthorized admin panel access attempt detected from external IP"

# 2. Simulate SQL injection attempt
echo "Simulating SQL injection attempt..."
curl -s "$WEB_SERVER/?id=1%20union%20select%20username,password%20from%20users"
echo ""

# Generate a log on the firewall about this event
docker-compose exec firewall logger -t FIREWALL -p auth.crit "Possible SQL injection attempt detected: union select pattern"

# 3. Simulate brute force attempt (multiple rapid requests)
echo "Simulating brute force attempt..."
for i in {1..10}; do
  curl -s "$WEB_SERVER/" > /dev/null
  sleep 0.1
done
echo "Sent 10 rapid requests"

# Generate a log about this event
docker-compose exec firewall logger -t FIREWALL -p auth.warning "Possible brute force attempt: 10 rapid requests from same source"

# 4. Simulate 404 error generation
echo "Simulating 404 error generation..."
for i in {1..5}; do
  curl -s "$WEB_SERVER/nonexistent$i" > /dev/null
  sleep 0.1
done
echo "Generated 5 404 errors"

# Generate a log about this event
docker-compose exec firewall logger -t FIREWALL -p auth.notice "Web probe detected: Multiple 404 errors from same source"

# 5. Manually generate a simulated IDPS log
docker-compose exec suricata logger -t IDPS -p auth.crit "ALERT: Intrusion attempt detected - possible port scan"
docker-compose exec suricata logger -t IDPS -p auth.warning "Suspicious traffic pattern identified - potential reconnaissance"

echo "Attack simulation completed. Check Graylog for the generated security logs."
