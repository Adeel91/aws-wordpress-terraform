#!/bin/bash

# Update system packages
sudo yum update -y

# Install httpd (webserver), start and enable it
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd