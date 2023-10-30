# cloudera-assessment
#!/usr/bin/env groovy

pipeline{

	agent any;
	options {
		timeout(time: 10, unit: 'HOURS') // Timeout job after 10 HOURS
		timestamps() // Use Timestamper plugin to add timestamp to build log
		disableConcurrentBuilds() 
		buildDiscarder(logRotator(numToKeepStr: '15')) // Discard builds older than 15 builds
	}
	//triggers { upstream(upstreamProjects: 'c7', threshold: hudson.model.Result.SUCCESS) }
	//triggers { cron('H/15 * * * *') }
	parameters {
		string(defaultValue: 'default', description: 'Provide AWS and CDP Profile name to use account', name: 'PROFILE')
		booleanParam(name: 'DEPLOY_PC', defaultValue: true, description: 'Run Terraform apply to provision the CDP PC Infrastructure on AWS')
		booleanParam(name: 'DEPLOY_DS', defaultValue: false, description: 'Run ansible-navigator to deploy the data service (CDE) on CDP PC Infrastructure on AWS')
		booleanParam(name: 'TEARDOWN_DS', defaultValue: false, description: 'Destroy (Teardown) the Data Service deployed on CDP using Ansible')
		booleanParam(name: 'DESTROY_CDP', defaultValue: false, description: 'Run Terraform Detsroy to cleanup the CDP PC Infrastructure on AWS')
		choice(name: 'DELETE_WORKDIR', choices: ['false','true'], description: 'Delete the Work directory at the end of the job. This will cause the job to re-download all ansible-galaxy roles on next run.')
		booleanParam(name: 'REFRESH_JENKINSFILE', defaultValue: false, description: 'Reload changes from Jenkinsfile and exit.')
	}
	
	environment{
		A269159_CREDS = credentials('kuldeep-jnks-creds')
	}
	stages {
		stage("\u2776 RELOAD Jenkinsfile") {
			when { expression { return params.REFRESH_JENKINSFILE ==~ /(?i)(Y|YES|T|TRUE|ON|RUN)/ } }
			steps {
				sh 'echo "\u2776 RELOAD Jenkinsfile into Jenkins Project: Job ${JOB_NAME} [${BUILD_NUMBER}] (${BUILD_URL})"'
				script {
					currentBuild.result = 'ABORTED'
					error('DRY RUN COMPLETED. JOB PARAMETERIZED.')
				}
			}
		} // END stage
		
		stage("\u2776 Deploy CDP PC ENV") {
			when { expression { return params.DEPLOY_PC ==~ /(?i)(Y|YES|T|TRUE|ON|RUN)/ } }
			steps {
				sh 'echo "\u2776 Provision the CDP Public Cloud Infrastructure ENV on AWS using Terraform"'
				dir('~/terraform-cloudera-cdp/examples/ex01-minimal_inputs/') {
				    sh 'echo " Running Terraform init:::::::"'
					sh 'terraform init | tee terraform-init-output.log'
					sh 'echo " Running Terraform plan:::::::"'
					sh 'terraform plan  -var-file terraform.tfvars -out terraform-plan.output | tee terraform-plan-output.log'
					sh 'echo " Running Terraform apply:::::::"'
					sh 'terraform apply  -var-file=terraform.tfvars  -auto-approve | tee terraform-apply-output.log'
				}
			}
		} // END stage

		// Run ansible Playbook
		stage ('\u2779 ANSIBLE: Prestaging') {
		when { expression { return params.DEPLOY_DS ==~ /(?i)(Y|YES|T|TRUE|ON|RUN)/ } }
			steps {
				dir('~/cloudera-deploy/public-cloud/aws/cde/') {
					ansiColor('xterm') {
						sh 'echo "Running ansible-navigator to deploy data service:::::::"'
						sh 'ansible-navigator run main.yml -e @definition.yml --tags deploy_ds,de'
					}
				}
			} // END steps
		}	// END stage
		
		// Run ansible Playbook
		stage ('\u2779 ANSIBLE: Prestaging') {
		when { expression { return params.TEARDOWN_DS ==~ /(?i)(Y|YES|T|TRUE|ON|RUN)/ } }
			steps {
				dir('~/cloudera-deploy/public-cloud/aws/cde/') {
					ansiColor('xterm') {
						sh 'echo "Running ansible-navigator to delete data service:::::::"'
						sh 'ansible-navigator run teradown.yml -e @definition.yml --tags deploy_ds,de'
					}
				}
			} // END steps
		}	// END stage
		
		stage("\u2776 Destroy the CDP PC ENV") {
		    when { expression { return params.DESTROY_CDP ==~ /(?i)(Y|YES|T|TRUE|ON|RUN)/ } }
			steps {
				sh 'echo "\u2776 Cleanup the CDP Public Cloud Infrastructure ENV on AWS using Terraform"'
					dir('~/terraform-cloudera-cdp/examples/ex01-minimal_inputs/') {
						sh 'echo " Running Terraform destroy:::::::"'
						sh 'terraform destroy  -var-file=terraform.tfvars  -auto-approve | tee terraform-destroy-output.log'
					}
				}
		} // END stage
	} // END stages

	post {
		success {
			sh 'echo "SUCCESS: Deployment : Job ${JOB_NAME} [${BUILD_NUMBER}] (${BUILD_URL})"'
		}
		failure {
			sh 'echo "FAILURE: Deployment : Job ${JOB_NAME} [${BUILD_NUMBER}] (${BUILD_URL})"'
		}
		cleanup {
			script {
				if (params.DELETE_WORKDIR ==~ /(?i)(Y|YES|T|TRUE|ON|RUN)/) {
					sh 'echo "CLEANUP: Deleting the Workdir"'
					deleteDir()
				} else {
					sh 'echo "CLEANUP: DELETE_WORKDIR Not Selected in Job Parameters"'
				}
			}
		}
	} // END post
} // END pipeline