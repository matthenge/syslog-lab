# Intrusion Detection and Prevention with Syslog: Lab Guide for M1 MacBook

This guide will help you set up and run the lab environment using Docker on your M1 MacBook. The lab is designed to work with ARM architecture.

## Prerequisites

- Docker Desktop for Mac (with Apple Silicon support)
- Terminal access
- Basic knowledge of Docker, networking, and Linux commands

## Setup Instructions

### Step 1: Create the Directory Structure

1. Clone the repository and move into the project folder:
   ```bash
   git clone https://github.com/matthenge/syslog-lab.git
   cd ~/syslog-lab
   ```

2. Copy the setup script and make it executable:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

### Step 2: Create Configuration Files

Create all the necessary configuration files as provided in the artifacts.

### Step 3: Start the Docker Environment

1. Start the Docker containers:
   ```bash
   docker-compose up -d
   ```

2. Verify all containers are running:
   ```bash
   docker-compose ps
   ```

## Lab Tasks

### Task 1: Syslog for Log Collection (15%)

All of our containers are configured to send logs to the central Graylog server using UDP on port 1514.

1. **Verify Syslog Configuration**:
   - Connect to the firewall container:
     ```bash
     docker-compose exec firewall sh
     ```
   - Check the rsyslog configuration:
     ```bash
     cat /etc/rsyslog.d/10-graylog.conf
     ```
   - Generate some test logs:
     ```bash
     logger -t FIREWALL "Test log message with severity INFO"
     logger -p local0.error -t FIREWALL "Test log message with severity ERROR"
     ```

2. **Repeat for web server and router containers changing the container names respectively**

### Task 2: Centralized Log Management (20%)

1. **Access Graylog Web Interface**:
   - Open your browser and navigate to: `http://localhost:9000`
   - Login with:
     - Username: `admin`
     - Password: `admin` (default password, SHA2 hash in the config is for "admin")

2. **Configure Graylog**:
   - Create a new Input:
     1. Go to System → Inputs
     2. Select "Syslog UDP" from the dropdown and click "Launch new input"
     3. Set title to "Syslog UDP"
     4. Set port to 1514
     5. Click "Save"

3. **Create Dashboards**:
   - Go to Dashboards → Create Dashboard
   - Name it "Security Events"
   - Add widgets for:
     - Log count by host
     - Log count by severity
     - Recent error messages
     - Authentication failures

### Task 3: Best Practices for Syslog (15%)

1. **Configure Log Rotation**:
   - Connect to one of the containers:
     ```bash
     docker-compose exec webserver sh
     ```
   - Install logrotate:
     ```bash
     apk add --no-cache logrotate
     ```
   - Create a logrotate configuration for syslog:
     ```bash
     cat > /etc/logrotate.d/rsyslog << EOF
     /var/log/messages {
         rotate 7
         daily
         compress
         delaycompress
         missingok
         notifempty
         postrotate
             /usr/bin/killall -HUP rsyslogd
         endscript
     }
     EOF
     ```

2. **Set Up Log Filtering**:
   - Create a filter configuration:
     ```bash
     cat > /etc/rsyslog.d/20-filter.conf << EOF
     # Exclude debug messages
     :syslogtag, contains, "debug" ~
     
     # Only forward critical and higher to Graylog
     if $syslogseverity <= 2 then @graylog:1514
     EOF
     ```
   - Restart rsyslog:
     ```bash
     kill -HUP $(pidof rsyslogd)
     ```

3. **Optional: Secure Transmission**:
   - For a production environment, we would configure TLS for syslog, but for this lab, we'll focus on the core functionality.

### Task 4: Intrusion Detection and Prevention Scenarios (30%)

> **Note**: For the M1 MacBook version of this lab, we're using a simplified container for the IDPS component due to compatibility issues with Suricata on ARM architecture. In a production environment, you would use a full Suricata installation.

1. **Using the Simplified IDPS Container**:
   ```bash
   # Check that the IDPS container is running
   docker-compose ps suricata
   
   # View the simulated IDPS logs
   docker-compose logs suricata
   ```

2. **Run Attack Simulation**:
   ```bash
   chmod +x attack-simulation.sh
   ./attack-simulation.sh
   ```

3. **Analyze Events in Graylog**:
   - Go to Search in Graylog
   - Look for security-related events from the webserver and firewall
   - Create a dashboard widget for security events

4. **For a Real Suricata Installation (Reference Only)**:
   In a production or x86 environment, you would analyze Suricata logs with:
   ```bash
   # These commands are for reference only
   cat /var/log/suricata/fast.log
   cat /var/log/suricata/eve.json | tail -n 20
   ```

## Cleanup

When you're done with the lab, you can clean up:

```bash
docker-compose down -v
```

This will stop all containers and remove the volumes.

## Troubleshooting

- **Issue**: Containers fail to start
  - **Solution**: Check Docker logs with `docker-compose logs [service_name]`

- **Issue**: Suricata not detecting attacks
  - **Solution**: Verify network mode and interface configuration

- **Issue**: Logs not appearing in Graylog
  - **Solution**: Verify the Graylog input is running and the syslog configuration is correct
 
