#!/bin/bash
# Ubuntu Installation Script for DevOps Tools

# Update system and install basic dependencies
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl unzip python3 python3-pip git pipx
sudo pipx install -y boto3

# Install Java (OpenJDK 21)
sudo apt install -y openjdk-21-jdk

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install Docker
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER  # Better than hardcoding 'ubuntu'
sudo chmod 660 /var/run/docker.sock  # More secure than 777

# Run SonarQube container (with proper resource limits)
docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  --ulimit nofile=65536:65536 \
  sonarqube:lts-community

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
rm awscliv2.zip

# Install kubectl (specific version)
KUBECTL_VERSION="v1.28.4"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Install Helm
curl https://baltocdn.com/helm/signing.asc | sudo gpg --dearmor -o /usr/share/keyrings/helm.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update
sudo apt install -y helm

# Verify installations
echo "=== Installation Verification ==="
java -version
docker --version
aws --version
kubectl version --client
eksctl version
helm version