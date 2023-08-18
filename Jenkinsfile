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
                sh 'cd terraform/ && terraform init'
                sh 'cd terraform/ && terraform plan -out tfplan'
                sh 'cd terraform/ && terraform show -no-color tfplan > tfplan.txt'
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
                sh 'cd terraform/ && terraform apply -input=false tfplan'
            }
        }

        stage('Install Docker') {
            steps {
                script {
                    def instanceIp = bat(script: 'cd terraform/ && terraform output instance_ip', returnStatus: true).trim()
                    echo "Instance IP: ${instanceIp}"
                    sshagent(credentials: ['SSH_KEY']) {
                        sh "ssh -o StrictHostKeyChecking=no -i path/to/your/ssh/key.pem ec2-user@${instanceIp} 'sudo yum install -y docker'"
                        sh "ssh -o StrictHostKeyChecking=no -i path/to/your/ssh/key.pem ec2-user@${instanceIp} 'sudo systemctl start docker'"
                    }
                }
            }
        }

        stage('Terminate EC2') {
            steps {
                script {
                    def instanceId = bat(script: 'cd terraform/ && terraform output instance_id', returnStatus: true).trim()
                    echo "Terminating EC2 instance with ID: ${instanceId}"
                    bat "aws ec2 terminate-instances --instance-ids ${instanceId}"
                }
            }
        }
    }
}
