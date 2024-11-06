pipeline {
    agent none
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

                    dir("${WORKSPACE}") {
                        // Ensure Docker is running and the user has permissions
                        sh "docker info" // Check Docker daemon status

                        // Authenticate with ECR and build the Docker image
                        docker.withRegistry(params.ECRURL, env.AWS_CREDENTIALS) {
                            myImage = docker.build(dockerTag)

                            // Push the Image to ECR
                            try {
                                myImage.push()
                            } catch (e) {
                                currentBuild.result = 'FAILURE'
                                throw e // Fail the build if push fails
                            }
                        }
                    }
                }
            }
        }

        stage('Scan Image') {
            agent { label 'demo' }
            steps {
                withAWS(credentials: env.AWS_CREDENTIALS) {
                    sh "./getimagescan.sh ${params.REPO} ${env.BUILD_ID} ${params.REGION}"
                }
            }
            post {
                always {
                    // Clean up the Docker image after the scan
                    sh "docker rmi ${params.REPO}:${env.BUILD_ID}"
                }
            }
        }
    }
}
