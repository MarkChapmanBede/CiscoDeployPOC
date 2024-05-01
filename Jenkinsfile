pipeline {
    agent any
    environment {
        PATH = "${env.PATH}:/usr/local/bin"
        PUBLIC_IP = ''  // Define PUBLIC_IP at the pipeline level for cross-stage access
    }
    stages {
        stage('Initialize') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'TF_VAR_admin_username', variable: 'TF_VAR_admin_username'),
                        string(credentialsId: 'TF_VAR_admin_password', variable: 'TF_VAR_admin_password'),
                        string(credentialsId: 'TF_VAR_ssh_public_key', variable: 'TF_VAR_ssh_public_key'),
                        string(credentialsId: 'ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                        string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                        string(credentialsId: 'ARM_TENANT_ID', variable: 'ARM_TENANT_ID'),
                        string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID')
                    ]) {
                        sh '''
                        echo "Initializing Terraform"
                        terraform init
                        '''
                    }
                }
            }
        }
        stage('Plan') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'TF_VAR_admin_username', variable: 'TF_VAR_admin_username'),
                        string(credentialsId: 'TF_VAR_admin_password', variable: 'TF_VAR_admin_password'),
                        string(credentialsId: 'TF_VAR_ssh_public_key', variable: 'TF_VAR_ssh_public_key'),
                        string(credentialsId: 'ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                        string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                        string(credentialsId: 'ARM_TENANT_ID', variable: 'ARM_TENANT_ID'),
                        string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID')
                    ]) {
                        sh '''
                        echo "Generating Terraform plan"
                        terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }
        stage('Approval') {
            steps {
                input(message: "Review the plan and approve if it's okay to proceed", ok: "Deploy")
            }
        }
        stage('Apply and Refresh') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'TF_VAR_admin_username', variable: 'TF_VAR_admin_username'),
                        string(credentialsId: 'TF_VAR_admin_password', variable: 'TF_VAR_admin_password'),
                        string(credentialsId: 'TF_VAR_ssh_public_key', variable: 'TF_VAR_ssh_public_key'),
                        string(credentialsId: 'ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                        string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                        string(credentialsId: 'ARM_TENANT_ID', variable: 'ARM_TENANT_ID'),
                        string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID')
                    ]) {
                        sh '''
                        echo "Applying Terraform plan"
                        terraform apply -auto-approve tfplan
                        echo "Waiting for 30 seconds before refreshing state to capture Public IP..."
                        sleep 30
                        terraform refresh
                        PUBLIC_IP=$(terraform output -raw asa_vm_public_ip)
                        echo "VM Public IP: $PUBLIC_IP"
                        '''
                        env.PUBLIC_IP = sh(script: "terraform output -raw asa_vm_public_ip", returnStdout: true).trim()
                    }
                }
            }
        }
        stage('Ping Test') {
            steps {
                script {
                    sh 'sleep 120'  // Wait 2 minutes to ensure the VM is fully operational
                    sh '''
                    echo "Pinging VM at $PUBLIC_IP"
                    for i in {1..5}
                    do
                        ping -c 1 $PUBLIC_IP && break || sleep 10
                    done
                    '''
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: '*.tfstate'
        }
    }
}
