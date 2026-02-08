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

        stage('Update Ansible Inventory') {
            steps {
                dir('ansible') {
                    sh '''
                    echo "[web]" > inventory.ini
                    echo " ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/devops-key" >> inventory.ini
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
