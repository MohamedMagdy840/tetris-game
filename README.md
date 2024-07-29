
  # Tetris Game Deployment 

  ### This project aims to automate the deployment of a Tetris game application using a CI/CD pipeline with Jenkins, Docker, Amazon EC2, ECR, EKS, SonarQube, OWASP Dependency-Check, Trivy, and ArgoCD. 
  
  # Prerequisites  
  #### 1. AWS CLI: Installed and configured on the local machine.
  #### 2. Terraform: Installed on the local machine.
  #### 3. Jenkins: Installed and running on an EC2 instance.
  #### 4. Docker: Installed on the Jenkins server.
  #### 5. SonarQube: Integrated with Jenkins for code analysis.
  #### 6. OWASP Dependency-Check: Integrated with Jenkins for security vulnerability scanning.
  #### 7. Trivy: Integrated with Jenkins for container image scanning.
  #### 8. ArgoCD: Installed in the EKS cluster for continuous deployment.
  
# Workflow Steps
#### 1. AWS IAM Setup
  * Configure AWS IAM roles and policies for provisioning resources and accessing services.

#### 2. Terraform for Infrastructure Provisioning
* **EC2 Instance Provisioning**: Use Terraform to provision an EC2 instance where Jenkins will be installed.
* **EKS Cluster Provisioning**: Use Terraform to provision an EKS cluster for deploying the Tetris game application.

#### 3. Jenkins Setup
* **Install Jenkins**: On the provisioned EC2 instance.
* **Configure Jenkins**: Set up required plugins and credentials.

#### 4. Code Repository
* **Tetris Repo:** Host the application code in a repository (e.g., GitHub).

* **Pull Code**: Jenkins pulls the latest code from the Tetris repository.

#### 5. CI/CD Pipeline Stages in Jenkins
* **SonarQube Analysis**: Analyze the code for quality and security issues.
* **OWASP Dependency-Check**: Scan the project dependencies for known vulnerabilities.
* **Trivy FS Scan**: Scan the filesystem for vulnerabilities.
* **Docker Build and Push**:
   * Build Docker images for the application.
   * Tag the images and push them to Docker Hub.
* **Trivy Image Scan**: Scan the Docker images for vulnerabilities.
* Deployment Repo Update: Update the deployment repository with the new image tags.

#### 6. Deployment Stage
* **ArgoCD Installation**: Install ArgoCD in the EKS cluster using Helm.
* **Deploy Application**: Deploy the Tetris game application using ArgoCD.

# Detailed Steps
#### AWS CLI Configuration
1. Install AWS CLI on your local machine.
2. Configure AWS CLI with your credentials:

```bash
  aws configure
```

```bash
#### Terraform for EC2 and EKS Provisioning
EC2 Instance:

* Create a Terraform script to provision an EC2 instance.
* Example main.tf:

# AWS plugin  
provider "aws" {
  region = "eu-north-1"
}


resource "aws_instance" "jenkins_instance" {
  ami                         = "ami-07c8c1b18ca66bb07"                 # "ami-080e1f13689e07408"
  instance_type               = "t3.medium"
  #subnet_id                   = aws_subnet.public_subnet_01.id
  key_name                    = "keypair"  
  associate_public_ip_address = true
  root_block_device {
    volume_size = 30
  }
 # Read the local install_jenkins.sh script and set it as user data
  user_data = file("jenkins.sh")

  tags = {
    Name = "jenkins_instance"

  }
  security_groups = [aws_security_group.jenkins_instance_sg.id]

}

resource "local_file" "public_ip_file" {
  filename = "jenkins_IP"
  content  = aws_instance.jenkins_instance.public_ip
}





resource "aws_security_group" "jenkins_instance_sg" {
  name        = "jenkins_instance_sg"
  description = "security group for jenkins instance"
  vpc_id      = aws_vpc.node_vpc.id



  # Define ingress rules
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }


  # Define egress rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#tls
#key-pair
#tls-private-key to add in locall
#in userdata of bastion echo command add the file of private key in bastion file

resource "tls_private_key" "keys" {
  algorithm   = "RSA"
  rsa_bits    = 2048
}

resource "aws_key_pair" "keypair" {
  key_name   = "keypair"
  public_key = tls_private_key.keys.public_key_openssh
}

resource "local_file" "private_key" {
  filename = "./private_key.pem"
  content  = tls_private_key.keys.private_key_pem
}

```
