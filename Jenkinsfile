pipeline {
    agent none
    options {
        timeout(time: 15, unit: 'MINUTES')
    }

    parameters {
        string(name: 'ECR_URL', defaultValue: 'your-ecr-url', description: 'ECR repository URL')
        string(name: 'REPO', defaultValue: 'myapp', description: 'Docker repository name')
        string(name: 'REGION', defaultValue: 'ap-south-1', description: 'AWS region')
    }

    environment {
        AWS_CREDS = credentials('aws-credentials-id')
    }

    stages {
        stage('Checkout') {
            agent { label 'demo' }
            steps {
                git branch: 'main', url: 'https://github.com/your-org/your-repo.git'
            }
        }

        stage('Build Image') {
            agent { label 'demo' }
            steps {
                script {
                    dockerTag = "${params.REPO}:${env.BUILD_ID}"
                    myImage = docker.build(dockerTag)
                }
            }
        }

        stage('Quality Gate') {
            agent { label 'demo' }
            steps {
                echo "Checking image quality gates..."
                // Placeholder for integrating a quality gate check (e.g., SonarQube, security scan)
                // Add quality check logic here
            }
        }

        stage('Push Image') {
            agent { label 'demo' }
            steps {
                script {
                    docker.withRegistry("https://${params.ECR_URL}", AWS_CREDS) {
                        myImage.push()
                    }
                }
            }
            post {
                success {
                    echo "Docker image pushed successfully."
                }
            }
        }

        stage('Scan Image') {
            agent { label 'demo' }
            steps {
                sh "./ecr_scan.sh ${params.REPO} ${env.BUILD_ID} ${params.REGION}"
            }
            post {
                always {
                    sh "docker rmi ${params.REPO}:${env.BUILD_ID}"
                }
            }
        }
    }
}
