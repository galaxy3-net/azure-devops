#!/bin/sh

exec > /tmp/korben 2>&1
sudo apt update
sudo apt install -y docker.io