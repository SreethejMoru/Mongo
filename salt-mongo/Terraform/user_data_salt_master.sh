#!/bin/bash
sudo yum update -y
sudo yum install -y curl
sudo rpm --import https://repo.saltproject.io/salt/py3/amazon/2/x86_64/SALT-PROJECT-GPG-PUBKEY-2023.pub
curl -fsSL https://repo.saltproject.io/salt/py3/amazon/2/x86_64/latest.repo | sudo tee /etc/yum.repos.d/salt-amzn.repo
sudo yum clean expire-cache
sudo yum -y install salt-master
sudo yum -y install salt-minion
echo "====>mkdir"
sudo mkdir -p /tmp/salt/
sudo chown -R root:root /tmp/salt/
sudo chmod -R 777 /tmp/salt
sudo mkdir -p /srv/salt
sudo chown -R root:root /srv/salt
# sudo cp -r /tmp/salt/* /srv/salt/
sudo chmod -R 777 /srv/salt
echo "===>network.conf"
cat <<EOF | sudo tee /etc/salt/master.d/network.conf
# The network interface to bind to
interface: 0.0.0.0
# The Request/Reply port
ret_port: 4506
# The port minions bind to for commands, aka the publish port
publish_port: 4505
EOF
echo "===>thread_options.conf"
cat <<EOF | sudo nano /etc/salt/master.d/thread_options.conf
# Set the number of worker threads for salt-master
worker_threads: 5
EOF
# Enable and start the Salt Master service
sudo systemctl restart salt-master
sudo systemctl enable salt-master 
sudo systemctl start salt-master
sudo systemctl status salt-master
echo "=====> installing iptables"
sudo yum install -y iptables
sudo iptables -A INPUT -p tcp --dport 4505 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 4506 -j ACCEPT
sudo iptables-save | sudo tee /etc/sysconfig/iptables
sudo service iptables restart
sudo salt-key -L
sudo salt-key
sudo salt-key -A --yes
sudo salt '*' test.version
