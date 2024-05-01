pipeline {
    agent any
    environment {
        PATH = "${env.PATH}:/usr/local/bin"
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
                        sh 'echo "Initializing Terraform"'
                        sh 'terraform init'
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
                        sh 'echo "Generating Terraform plan"'
                        sh 'terraform plan -out=tfplan'
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
                        sh 'echo "Applying Terraform plan"'
                        sh 'terraform apply -auto-approve tfplan'
                        sh 'echo "Waiting for 30 seconds before refreshing state to capture Public IP..."'
                        sh 'sleep 30'
                        script {
                            env.PUBLIC_IPS_JSON = sh(script: 'bash -c "terraform output -json asa_vm_public_ips"', returnStdout: true).trim()
                            echo "Debug: JSON Output - ${env.PUBLIC_IPS_JSON}"
                            env.PUBLIC_IPS = readJSON text: env.PUBLIC_IPS_JSON
                            echo "Debug: IPs - ${env.PUBLIC_IPS}"
                            sh "echo 'VM Public IPs: ${env.PUBLIC_IPS.join(', ')}'"
                        }
                    }
                }
            }
        }

        stage('Ping Test') {
            steps {
                script {
                    sh 'sleep 120'
                    echo "Pinging IPs: ${env.PUBLIC_IPS}"
                    env.PUBLIC_IPS.each { ip ->
                        echo "About to ping IP: $ip"
                        sh """
                        bash -c '
                        echo "Pinging VM at $ip"
                        ping -c 1 $ip || echo "Ping failed for IP $ip"
                        '
                        """
                    }
                }
            }
        }
    }
}
