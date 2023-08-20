pipeline {

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    agent any

       
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
        stage('Fetch Local IP and Docker-Compose') {
            steps {
                script {
                  def localIP = bat(script: 'terraform output local_ip', returnStdout: true).trim()
            
            // Clone the GitHub repository containing docker-compose.yml
                  dir('temp_repo') {
                  git 'https://github.com/sumitbhatia101/InfraAlsCode.git'
                
                // Modify docker-compose.yml with local IP
                  powershell '''
                    $filePath = "temp_repo/docker-compose.yml"
                    $content = Get-Content $filePath
                    $content = $content -replace "HOST_IP=PLACEHOLDER", "HOST_IP=${localIP}"
                    $content | Set-Content $filePath
                '''
            }
        }
    }
}
        stage('Run Docker Compose') {
    steps {
        script {
            
            sshagent(['AWS_SSH_KEY']) {
                sh "scp -o StrictHostKeyChecking=no temp_repo/docker-compose.yml ec2-user@${ec2InstanceIP}:~/"
                sh "ssh -o StrictHostKeyChecking=no ec2-user@${ec2InstanceIP} 'cd ~/ && docker-compose up -d'"
            }
        }
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
