#!/bin/bash

# Create the required directory structure
mkdir -p nginx/html
mkdir -p suricata/rules

# Copy the configuration files to their respective locations
# (These will be created separately and should be in the same directory as this script)

# Create the docker-compose file (this will be created separately)

echo "Directory structure has been created."
echo "Place the configuration files in their respective directories and run 'docker-compose up -d' to start the lab."
