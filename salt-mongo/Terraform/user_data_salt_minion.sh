#!/bin/bash
sudo yum update -y
sudo yum install -y curl
sudo rpm --import https://repo.saltproject.io/salt/py3/amazon/2/x86_64/SALT-PROJECT-GPG-PUBKEY-2023.pub
curl -fsSL https://repo.saltproject.io/salt/py3/amazon/2/x86_64/latest.repo | sudo tee /etc/yum.repos.d/salt-amzn.repo
echo "===> executing yum clean expire-cache"
sudo yum clean expire-cache
echo "===> executing install salt-minion"
sudo yum -y install salt-minion
echo "===> executing override"
sudo yum install -y aws-cli salt-minion
# Configure AWS CLI with hard-coded credentials
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_DEFAULT_REGION=""

mkdir -p ~/.aws
cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOF

cat <<EOF > ~/.aws/config
[default]
region = $AWS_DEFAULT_REGION
EOF
echo "=====> adding master ip in /etc/salt/minion.d/master.conf"
# Fetch the Salt master instance ID dynamically
MASTER_INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=Salt_Master" --query "Reservations[*].Instances[*].InstanceId" --output text)
echo "Master Instance ID: $MASTER_INSTANCE_ID"

# Fetch the private IP address of the Salt master instance
MASTER_PRIVATE_IP=$(aws ec2 describe-instances --instance-ids $MASTER_INSTANCE_ID --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)
echo "Master Private IP: $MASTER_PRIVATE_IP"

# Write the master IP address to the minion configuration file
cat <<EOF | sudo tee /etc/salt/minion.d/master.conf > /dev/null
# Override the default Salt master setting
master: $MASTER_PRIVATE_IP
EOF
echo "===> executing ddclaration"
cat <<EOF | sudo tee /etc/salt/minion.d/id.conf
# Declare the minion ID
id: key_1
EOF
cat <<EOF | sudo tee -a /etc/salt/minion
# Configure mine_functions
mine_functions:
  network.ip_addrs: []
EOF
# Restart Salt minion to apply changes
sudo systemctl restart salt-minion  # Adjust for your init system if not using systemd

echo "===> Uncomment the line containing"
FILE_PATH="/etc/salt/minion"
# Uncomment the line containing 'master: salt' and change the value
sed -i 's/^#\(.*master: salt.*\)/\1/' "$FILE_PATH"
sed -i "s/master: salt/master: $MASTER_PRIVATE_IP/" "$FILE_PATH"
echo "===> adding line to host"
# Add a new line to the /etc/hosts file
echo "$MASTER_PRIVATE_IP salt" >> /etc/hosts
echo "=====> installing iptables"
sudo yum install -y iptables
sudo iptables -A INPUT -p tcp --dport 4505 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 4506 -j ACCEPT
sudo iptables-save | sudo tee /etc/sysconfig/iptables
sudo service iptables restart
echo "=====> starting salt-minion"
sudo systemctl enable salt-minion 
sudo systemctl start salt-minion
