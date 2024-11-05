pipeline {
    agent none

    options {
        timeout(time: 15, unit: 'MINUTES')
    }

    parameters {
        string(name: 'ECRURL', defaultValue: 'https://211125447612.dkr.ecr.ap-south-1.amazonaws.com', description: 'ECR repository URL')
        string(name: 'REPO', defaultValue: 'wezvabaseimage', description: 'Name of the Docker repository')
        string(name: 'REGION', defaultValue: 'ap-south-1', description: 'AWS region')
    }

    environment {
        AWS_CREDENTIALS_ID = 'aws_credentials' // Replace with your AWS credentials ID in Jenkins
    }

    stages {
        stage('Checkout') {
            agent { label 'demo' }
            steps {
                git branch: 'master', url: 'https://github.com/Mohit722/demosetup.git'
            }
        }

        stage('Build Image') {
            agent { label 'demo' }
            steps {
                script {
                    // Prepare the Tag name for the image
                    dockerTag = "${params.REPO}:${env.BUILD_ID}"

                    echo "Docker Tag: ${dockerTag}"

                    // Debugging: Check Docker version and info
                    sh 'docker --version'
                    sh 'docker info'

                    // Login to ECR using AWS CLI with Jenkins credentials
                    withAWS(credentials: AWS_CREDENTIALS_ID, region: "${params.REGION}") {
                        sh '''
                            aws ecr get-login-password --region ${params.REGION} | docker login --username AWS --password-stdin ${params.ECRURL}
                        '''
                    }

                    // Build Docker image
                    sh "docker build -t ${dockerTag} ."

                    // Push the Image to the Registry
                    sh "docker push ${dockerTag}"
                }
            }
        }

        stage('Scan Image') {
            agent { label 'demo' }
            steps {
                withAWS(credentials: AWS_CREDENTIALS_ID, region: "${params.REGION}") {
                    sh "./getimagescan.sh ${params.REPO} ${env.BUILD_ID} ${params.REGION}"
                }
            }
            post {
                always {
                    sh "docker rmi ${params.REPO}:${env.BUILD_ID}"
                }
            }
        }
    }
}
