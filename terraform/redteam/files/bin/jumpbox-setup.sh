#!/usr/bin/env bash

exec > ~/jumpbox-setup.log
exec 2>&1
  chmod 0400 /home/azureuser/.ssh/id_rsa*
  sleep 120
  sudo apt update && sleep 120 && sudo apt install -y docker.io && \
  sleep 120 && \
  sudo systemctl enable docker && sudo systemctl start docker
  sleep 120
  sudo docker pull cyberxsecurity/ansible && \
  sudo docker run --detach --hostname ansible --name ansible --mount type=bind,src=/home/azureuser/.ssh,dst=/root/.ssh --mount type=bind,src=/home/azureuser/ansible,dst=/etc/ansible cyberxsecurity/ansible

