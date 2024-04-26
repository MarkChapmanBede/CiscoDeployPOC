pipeline {
    agent any
    environment {
        TF_VERSION = '1.7.4'
    }
    tools {
        terraform 'Terraform'
    }
    stages {
        stage('Initialize') {
            steps {
                script {
                    terraform.init()
                }
            }
        }
        stage('Validate') {
            steps {
                script {
                    terraform.validate()
                }
            }
        }
        stage('Plan') {
            steps {
                script {
                    terraform.plan()
                }
            }
        }
        stage('Apply') {
            steps {
                script {
                    input(message: "Do you want to apply the changes?", ok: "Yes")
                    terraform.apply(autoApprove: true)
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
