# cloudera-assessment
#! /bin/bash
set -x

echo " Provision the CDP Public Cloud Infrastructure on AWS using Terraform"
cd terraform-cloudera-cdp/examples/ex01-minimal_inputs/
echo " Running Terraform init:::::::"
terraform init | tee terraform-init-output.log
echo " Running Terraform plan:::::::"
terraform plan -var-file terraform.tfvars -out terraform-plan.output | tee terraform-plan-output.log
echo " Running Terraform apply:::::::"
terraform apply -var-file=terraform.tfvars  -auto-approve | tee terraform-apply-output.log

echo " Deploy the Data Service(CDE) using Ansible on CDP Public Cloud Infrastructure on AWS created previously using Terraform"
cd ~/cloudera-deploy/public-cloud/aws/cde/
echo " Running ansible-navigator:::::::"
ansible-navigator run main.yml -e @definition.yml --tags deploy_ds,de

set +x