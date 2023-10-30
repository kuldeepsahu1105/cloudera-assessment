# cloudera-assessment
#! /bin/bash
set -x

echo " Teardown(cleanup) the Data Service(CDE) using Ansible on CDP Public Cloud Infrastructure on AWS created previously using Terraform"
cd ~/cloudera-deploy/public-cloud/aws/cde/
echo " Running ansible-navigator:::::::"
ansible-navigator run teradown.yml -e @definition.yml --tags deploy_ds,de

echo " Destroy the CDP Public Cloud Infrastructure on AWS using Terraform"
cd terraform-cloudera-cdp/examples/ex01-minimal_inputs/
echo " Running Terraform destroy:::::::"
terraform apply -var-file=terraform.tfvars  -auto-approve | tee terraform-destroy-output.log

set +x