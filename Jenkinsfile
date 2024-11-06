pipeline {
    agent any
    options {
        timeout(time: 15, unit: 'MINUTES')
    }

    parameters {
        string(name: 'ECRURL', defaultValue: 'your-ecr-url', description: 'ECR repository URL')
        string(name: 'REPO', defaultValue: 'wezvabaseimage', description: 'Name of the Docker repository')
        string(name: 'REGION', defaultValue: 'ap-south-1', description: 'AWS region')
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_credentials')
        AWS_SECRET_ACCESS_KEY = credentials('aws_credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/Mohit722/demosetup.git'
            }
        }

        stage('Build Image') {
            steps {
                script {
                    dockerTag = "${params.REPO}:${env.BUILD_ID}"
                    sh "docker info"
                    sh "docker build -t ${dockerTag} ."
                    sh "aws ecr get-login-password --region ${params.REGION} | docker login --username AWS --password-stdin ${params.ECRURL}"
                    sh "docker tag ${dockerTag} ${params.ECRURL}/${dockerTag}"
                    sh "docker push ${params.ECRURL}/${dockerTag}"
                }
            }
        }

        stage('Scan Image') {
            steps {
                script { 
                    // Ensure the script has execute permissions 
                    sh "chmod +x ./getimagescan.sh"
                }
                withAWS(credentials: env.AWS_CREDENTIALS) {
                    sh "./getimagescan.sh ${params.REPO} ${env.BUILD_ID} ${params.REGION}"
                }
            }
            post {
                always {
                    sh "docker rmi ${params.ECRURL}/${dockerTag}"
                }
            }
        }
    }
}
