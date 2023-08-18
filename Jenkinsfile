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
                script {
                    bat label: 'Terraform Init', script: 'cd terraform/ && terraform init'
                    bat label: 'Terraform Plan', script: 'cd terraform/ && terraform plan -out tfplan'
                    bat label: 'Save Plan Output', script: 'cd terraform/ && terraform show -no-color tfplan > tfplan.txt'
                }
            }
        }

        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
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
                bat label: 'Terraform Apply', script: 'cd terraform/ && terraform apply -input=false tfplan'
            }
        }

        stage('Terminate EC2') {
            steps {
                script {
                    def instanceId = bat(script: 'cd terraform/ && terraform output instance_id', returnStdout: true).trim()
                    echo "Terminating EC2 instance with ID: ${instanceId}"
                    bat "aws ec2 terminate-instances --instance-ids \"${instanceId}\""
                }
            }
        }
    }
}
