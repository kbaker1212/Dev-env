#!/bin/bash

# Log file for debugging
LOGFILE=/var/log/user-data.log
exec > >(tee -a $LOGFILE | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting user data script..."

# Update the package repository
echo "Updating package repository..."
sudo apt-get update -y

# Install necessary packages
echo "Installing necessary packages..."
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

# Add Docker’s official GPG key
echo "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the stable repository
echo "Setting up the stable Docker repository..."
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package repository again
echo "Updating package repository again..."
sudo apt-get update -y

# Install Docker
echo "Installing Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add the ubuntu user to the docker group
echo "Adding ubuntu user to the docker group..."
sudo usermod -aG docker ubuntu

# Verify Docker installation
echo "Verifying Docker installation..."
docker --version
if [ $? -ne 0 ]; then
  echo "Docker installation failed."
else
  echo "Docker installation succeeded."
fi

echo "User data script completed."
