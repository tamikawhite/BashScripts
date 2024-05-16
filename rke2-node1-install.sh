#!/bin/bash

# Step 1: Update package lists
sudo apt update

# Step 2: Install firewalld
sudo apt install firewalld -y

# Prompt the user to enter the fully qualified domain name (FQDN) and IP address for node 1
read -p "Enter the FQDN for node 1: " fqdn_node1
read -p "Enter the IP address for node 1: " ip_address_node1

# Prompt the user to enter the FQDN and IP address for node 2
read -p "Enter the FQDN for node 2: " fqdn_node2
read -p "Enter the IP address for node 2: " ip_address_node2

# Add the values to the /etc/hosts file
sudo sh -c "echo '$ip_address_node1 $fqdn_node1' >> /etc/hosts"
sudo sh -c "echo '$ip_address_node2 $fqdn_node2' >> /etc/hosts"

echo "Host entries for node 1 and node 2 have been added to the /etc/hosts file."

echo "Steps completed successfully."

# Download the latest kubectl release
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl

# Install the kubectl release
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Download Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

# Change the permissions for the Helm package downloaded
chmod 700 get_helm.sh 

# Install Helm
./get_helm.sh 

# Make directory
mkdir -p /etc/rancher/rke2/

# Prompt the user to enter the fully qualified domain name (FQDN) of master node
read -p "Enter the fully qualified domain name (FQDN) for the master node: " fqdn_master

# Prompt the user to enter the IP address
read -p "Enter the IP address of the master node: " ip_address_master

# Create the config.yaml file with the provided contents
cat <<EOF | sudo tee /etc/rancher/rke2/config.yaml > /dev/null
token: my-shared-secret
tls-san:
  - $fqdn_master
  - $ip_address_master
EOF


echo "Config.yaml file has been created with the provided information."

# Open ports using firewall-cmd command
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=2376/tcp
firewall-cmd --permanent --add-port=2379/tcp
firewall-cmd --permanent --add-port=2380/tcp
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --permanent --add-port=9099/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10254/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --permanent --add-port=30000-32767/udp
firewall-cmd --permanent --add-port=4789/udp

# Reload firewall to apply changes
firewall-cmd --reload

echo "Ports have been opened successfully."

# Stop firewalld
systemctl stop firewalld

# Install RKE2
curl -sfL https://get.rke2.io | sh -

# Add a pause for 45 seconds
sleep 45

# Enable the RKE2 server service
systemctl enable rke2-server.service

# Add a pause for 15 seconds
sleep 15

# Start the RKE2 server service
systemctl start rke2-server.service

# Add a pause for 120 seconds
sleep 120

# Add the line to .bashrc file
echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml PATH=$PATH:/var/lib/rancher/rke2/bin' >> ~/.bashrc

echo "Commands executed successfully."
