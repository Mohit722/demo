pipeline {
    agent none
    parameters {
        choice(name: 'ACTION', choices: ['create', 'destroy'], description: 'Choose whether to create or destroy the Terraform instance.')
    }
    stages {
        stage('Terraform Setup and Plan') {
            agent { label 'IAC' }
            when {
                expression { params.ACTION == 'create' } // Only run if ACTION is 'create'
            }
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform validate'
                }
            }
        }
        stage('Terraform Apply or Destroy') {
            agent { label 'IAC' }
            steps {
                dir('terraform') {
                    script {
                        if (params.ACTION == 'create') {
                            sh 'terraform apply -auto-approve'
                            // Retrieve the public IP immediately after applying
                            env.INSTANCE_PUBLIC_IP = sh(script: 'terraform output -raw instance_public_ip', returnStdout: true).trim()
                            echo "Public IP Retrieved: ${env.INSTANCE_PUBLIC_IP}"
                        } else if (params.ACTION == 'destroy') {
                            sh 'terraform destroy -auto-approve'
                            echo "Resources destroyed successfully."
                            currentBuild.result = 'SUCCESS' // Mark the build as successful
                            return // Exit the stage and skip subsequent stages
                        } else {
                            error("Invalid ACTION parameter")
                        }
                    }
                }
            }
        }
