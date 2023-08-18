pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    agent any
    stages {
        stage('checkout') {
            steps {
                script {
                    dir("terraform") {
                        git "https://github.com/sumitbhatia101/InfraAlsCode.git"
                    }
                }
            }
        }

        stage('Plan') {
            steps {
                bat 'cd terraform/ && terraform init'
                bat 'cd terraform/ && terraform plan -out tfplan'
                bat 'cd terraform/ && terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Approval') {
            when {
                not {
                    expression { params.autoApprove == true }
                }
            }

            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                          parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
            steps {
                bat 'cd terraform/ && terraform apply -input=false tfplan'
            }
        }

        stage('Install Docker') {
            steps {
                script {
                    def instanceIp = bat(script: "cd terraform/ && terraform output instance_ip", returnStatus: true).trim()

                    bat "ssh -o StrictHostKeyChecking=no ec2-user@${instanceIp} 'sudo yum update -y && sudo yum install -y docker'"
                    bat "ssh -o StrictHostKeyChecking=no ec2-user@${instanceIp} 'sudo service docker start && sudo usermod -a -G docker ec2-user'"
                }
            }
        }

        stage('Terminate EC2') {
            // Sleep for 5 minutes before terminating the EC2 instance
            sleep time: 300, unit: 'SECONDS'

            steps {
                script {
                    def instanceId = bat(script: "cd terraform/ && terraform output instance_id", returnStatus: true).trim()
                    bat "aws ec2 terminate-instances --instance-ids ${instanceId}"
                }
            }
        }

    }
}
