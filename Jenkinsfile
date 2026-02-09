pipeline {
    agent any

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Fetch EC2 Public IP') {
            steps {
                dir('terraform') {
                    script {
                        def ip = sh(script: "terraform output -raw web_public_ip", returnStdout: true).trim()
                        env.EC2_IP = ip
                        echo "EC2 Public IP: ${env.EC2_IP}"
                    }
                }
            }
        }

        stage('Wait for SSH') {
            steps {
                  sh '''
                  echo "Waiting for SSH to be ready on ${EC2_IP}..."
                  for i in {1..20}; do
                  nc -z ${EC2_IP} 22 && echo "SSH is now available!" && exit 0
                  echo "SSH not ready yet... retrying in 10 seconds"
                  sleep 10
                  done
                  echo "SSH not available after waiting"
                  exit 1
                  '''
                 }
         }   


        stage('Update Ansible Inventory') {
            steps {
                dir('ansible') {
                    sh '''
                    echo "[web]" > inventory.ini
                    echo "${EC2_IP} ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/devops-key" >> inventory.ini
                    cat inventory.ini
                    '''
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    sh 'ansible-playbook -i inventory.ini playbook.yml'
                }
            }
        }
    }
}
