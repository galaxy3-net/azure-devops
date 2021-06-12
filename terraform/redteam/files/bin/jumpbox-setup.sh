#!/usr/bin/env bash

exec > ~/jumpbox-setup.log
exec 2>&1
  # chmod 0400 /home/azureuser/.ssh/id_rsa*
  sleep 120
  sudo apt update && sleep 120 && sudo apt install -y docker.io && \
  sudo systemctl enable docker && sudo systemctl start docker

  #sudo docker pull cyberxsecurity/ansible && \
  #sudo docker run --name ansible --mount type=bind,src=/home/vagrant/.ssh,dst=/root/.ssh --mount type=bind,src=/home/vagrant/ansible,dst=/etc/ansible  -d -t cyberxsecurity/ansible sleep infinity

