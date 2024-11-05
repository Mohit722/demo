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

  stages {
    stage('Checkout') {
      agent { label 'demo' }
      steps {
        git branch: 'master', url: 'https://gitlab.com/scmlearningcentre/demo.git'
      }
    }
    
    stage('Build Image') {

      agent { label 'demo' }
      steps {
        script {
          // Prepare the Tag name for the image
          dockerTag = "${params.REPO}:${env.BUILD_ID}"
          docker.withRegistry(params.ECRURL, 'ecr:ap-south-1:AWSCred') {
            /* Build docker image locally */
            myImage = docker.build(dockerTag)

            /* Push the Image to the Registry */
            myImage.push()
          }
        }
      }
    }

    stage('Scan Image') {
      steps {
        withAWS(credentials: 'AWSCred') {
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
