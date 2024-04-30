pipeline {
    agent any
    stages {
        stage('Initialize') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'TF_VAR_admin_username', variable: 'TF_VAR_admin_username'),
                        string(credentialsId: 'TF_VAR_admin_password', variable: 'TF_VAR_admin_password')
                    ]) {
                        sh '''
                        echo "Initializing Terraform"
                        terraform init
                        '''
                    }
                }
            }
        }
        stage('Validate') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'TF_VAR_admin_username', variable: 'TF_VAR_admin_username'),
                        string(credentialsId: 'TF_VAR_admin_password', variable: 'TF_VAR_admin_password')
                    ]) {
                        sh '''
                        echo "Validating Terraform configurations"
                        terraform validate
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
                        string(credentialsId: 'TF_VAR_admin_password', variable: 'TF_VAR_admin_password')
                    ]) {
                        sh '''
                        echo "Generating Terraform plan"
                        terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }
        stage('Apply') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'TF_VAR_admin_username', variable: 'TF_VAR_admin_username'),
                        string(credentialsId: 'TF_VAR_admin_password', variable: 'TF_VAR_admin_password')
                    ]) {
                        input(message: "Do you want to apply the changes?", ok: "Yes")
                        sh '''
                        echo "Applying Terraform plan"
                        terraform apply -auto-approve tfplan
                        '''
                    }
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
