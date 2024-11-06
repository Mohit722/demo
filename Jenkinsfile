pipeline {
    agent { label 'demo' } // Runs on the 'demo' Docker node in Jenkins

    parameters {
        string(name: 'AWS_ACCOUNT_ID', defaultValue: '<aws_account_id>', description: 'AWS Account ID')
        string(name: 'REGION', defaultValue: 'us-west-2', description: 'AWS Region')
        string(name: 'ECR_REPO', defaultValue: 'my-docker-repo', description: 'ECR Repository Name')
        string(name: 'GIT_REPO_URL', defaultValue: 'https://github.com/your-repo/my-docker-app.git', description: 'Git Repository URL')
    }

    environment {
        AWS_CREDENTIALS_ID = 'aws-credentials'  // Jenkins-stored AWS credentials ID
    }

    stages {
        stage('Checkout') {
            steps {
                git "${params.GIT_REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("my-docker-app:latest", ".")
                }
            }
        }

        stage('Push to ECR') {
            environment {
                DOCKER_IMAGE_TAG = "${params.AWS_ACCOUNT_ID}.dkr.ecr.${params.REGION}.amazonaws.com/${params.ECR_REPO}:latest"
            }
            steps {
                withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${params.REGION}") {
                    script {
                        // Login to ECR
                        sh 'aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${params.AWS_ACCOUNT_ID}.dkr.ecr.${params.REGION}.amazonaws.com'
                        
                        // Tag and push the Docker image to ECR
                        sh 'docker tag my-docker-app:latest $DOCKER_IMAGE_TAG'
                        sh 'docker push $DOCKER_IMAGE_TAG'
                    }
                }
            }
        }

        stage('Vulnerability Scan') {
            steps {
                withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${params.REGION}") {
                    sh './vulnerability_scan.sh latest ${params.ECR_REPO} ${params.REGION}'
                }
            }
        }

        stage('Quality Gates') {
            steps {
                script {
                    def scanResults = readJSON file: 'scan-results.json'
                    def criticalVulns = scanResults.findingSeverityCounts.CRITICAL ?: 0
                    def highVulns = scanResults.findingSeverityCounts.HIGH ?: 0

                    if (criticalVulns > 0 || highVulns > 15) {
                        error("Build failed due to vulnerability thresholds being exceeded")
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker images...'
            sh 'docker rmi my-docker-app:latest || true'
        }
    }
}
