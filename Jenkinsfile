pipeline {
    agent any
    environment {
        PATH = "${env.PATH}:/usr/local/bin"
    }
    stages {
        stage('Check Environment Variables') {
            steps {
                script {
                    sh 'printenv | grep TF_VAR_ | cut -d"=" -f1'
                }
            }
        }
        stage('Initialize') {
            steps {
                script {
                    sh 'terraform init'
                }
            }
        }
        stage('Validate') {
            steps {
                script {
                    sh 'terraform validate'
                }
            }
        }
        stage('Plan') {
            steps {
                script {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
        stage('Apply') {
            steps {
                script {
                    input(message: "Do you want to apply the changes?", ok: "Yes")
                    sh 'terraform apply -auto-approve tfplan'
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
