# cloudera-assessment
#! /bin/bash
echo "For CDP Public Cloud Infra creation on AWS, setting up execution environment and Pre-requisites:::::::"
set -x

echo "Installing Python Pre-requisites:::::::"
yum update –y
yum install python3.11 python3.11-pip –y
pip3 install --upgrade 'requests<2.28.1'

echo "Installing Docker Pre-requisites:::::::"
yum install docker
newgrp docker
sudo usermod -a -G docker ec2-user
systemctl start docker
systemctl enable docker
systemctl status docker
docker version
pip3 install docker docker-compose
docker-compose version

echo "Installing AWS Pre-requisites:::::::"
pip3 install awscli
aws version
aws configure
aws s3 ls

echo "Installing Terraform Pre-requisites:::::::"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
terraform –version

echo "Installing Ansible Pre-requisites:::::::"
pip3 install ansible ansible-navigator
ansible --version

echo "Installing CDP Pre-requisites:::::::"
pip3 install cdpcli
cdp configure
cat ~/.cdp/credentials
cat > ~/.cdp/config
cdp iam get-user

echo "Cloning the Terraform CDP PC Provisioning repo:::::::"
git clone https://github.com/aws-ia/terraform-cloudera-cdp.git
cd terraform-cloudera-cdp/examples/ex01-minimal_inputs/
cp terraform.tfvars.sample terraform.tfvars

echo "Cloning the Ansible CDP PC Data Service Deployment repo:::::::"
git clone https://github.com/cloudera-labs/cloudera-deploy.git
git clone https://github.com/cloudera-labs/cloudera.exe.git

cp ~/cloudera.exe/playbooks/pbc_setup.yml ~/cloudera-deploy/public-cloud/aws/cde/
mkdir -p ~/cloudera-deploy/public-cloud/aws/cde/roles/
cp -r ~/cloudera.exe/roles/runtime ~/cloudera-deploy/public-cloud/aws/cde/roles/
cd cloudera-deploy/public-cloud/aws/cde/

echo "Setting up the AWS and CDP Profile to select the account:::::::"
echo 'export AWS_PROFILE=default' >> ~/.bashrc 
echo 'export AWS_PROFILE=default' >> ~/.bashrc 
source ~/.bashrc 
cat ~/.bashrc | tail -2
export AWS_PROFILE=default
export CDP_PROFILE=default

echo "Test the ansible-navigator environment:::::::"
ansible-navigator exec -- cdp iam get-user
ansible-navigator exec -- aws iam get-user
ansible-navigator exec -- aws s3 ls

set +x
