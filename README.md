<p align="center">
  <img src="logo.png" alt="Project Logo" style="background-color:white; padding: 10px; border-radius: 8px;" />
</p>


# 🚀 Automated WordPress Setup on AWS with Terraform

This project sets up the infrastructure needed to deploy a WordPress website on AWS using Terraform. It provisions the required resources like VPC, subnets, EC2 instances, security groups, and an Application Load Balancer (ALB). The goal is to provide a scalable, secure, and cost-efficient environment to run WordPress.

[![WordPress on AWS with Terraform](https://img.shields.io/badge/🚀_WordPress-AWS_+_Terraform-FF6C37?style=for-the-badge&logo=wordpress&logoColor=white&labelColor=21759B&color=FF9900)](https://github.com/Adeel91/aws-wordpress-terraform)

---

## 🛠️ Modules Used (not finalized yet)

The following Terraform modules are used in this project:

### 1. **VPC Module** 🌍
- **What it does**: Creates a Virtual Private Cloud (VPC) with public and private subnets across **2 Availability Zones (AZs)**.
- **Purpose**: Isolate resources and provide network security.

### 2. **Security Group Module** 🔐
- **What it does**: Configures security groups for EC2 instances and other AWS resources.
- **Purpose**: Defines rules to ensure secure communication between resources and prevent unauthorized access.

### 3. **EC2 Module** 💻
- **What it does**: Launches EC2 instances for WordPress and a Bastion Host.
- **Purpose**: Deploys WordPress instances in private subnets and a Bastion Host in the public subnet for SSH access.

### 4. **ALB (Application Load Balancer) Module** ⚖️
- **What it does**: Sets up an ALB to balance incoming HTTP/HTTPS traffic across WordPress instances.
- **Purpose**: Distribute traffic evenly and ensure high availability.

### 5. **RDS Module (Coming Soon)** 🗄️
- **What it does**: Will set up a managed relational database (like MySQL) for WordPress.
- **Purpose**: Secure storage for WordPress data, with scaling and backup options.

---

## 🌍 Infrastructure Overview

This project creates and configures the following key AWS resources:

- **VPC** 🌐: A custom VPC with **public** and **private** subnets spread across two Availability Zones (AZs).
- **Internet Gateway (IGW)** 🌎: Provides internet access to resources in the VPC.
- **NAT Gateway** 🔄: Allows private instances to access the internet while keeping them secure from inbound traffic.
- **Security Groups** 🔒: Configures rules for the Bastion Host (public subnet) and WordPress instances (private subnet).
- **EC2 Instances** 💻: 
  - **Bastion Host** 🔑: A public instance for secure SSH access to private instances.
  - **WordPress Instances** 📝: Deployed in private subnets, ensuring the application is protected from direct access.

- **ALB (Application Load Balancer)** ⚖️: Balances traffic between WordPress instances for high availability and fault tolerance.

---

## ⚙️ How It Works

### 1. **VPC and Networking** 🌍
- A **VPC** is created with both **public** and **private** subnets across **2 Availability Zones (AZs)**.
- Public subnets have internet access via an **Internet Gateway**, while private subnets use a **NAT Gateway** for secure outbound access.

### 2. **EC2 Instances** 💻
- **Bastion Host** 🔑: A secure EC2 instance in the public subnet, allowing SSH access to private instances.
- **WordPress Instances** 📝: Deployed in private subnets for added security.

### 3. **Load Balancer (ALB)** ⚖️
- An **Application Load Balancer (ALB)** is configured to route HTTP traffic to the WordPress EC2 instances, ensuring high availability and efficient traffic distribution.

---

## 📋 How to Use

### Prerequisites
- **Terraform 1.x** or later
- **AWS CLI** installed and configured
- An **AWS account** with the necessary permissions

### Steps to Deploy

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/aws-wordpress-terraform.git
   cd aws-wordpress-terraform
