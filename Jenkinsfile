pipeline {
    agent any

    stages {
        stage('Build with Maven') {
            steps {
                script {
                    // Clean and build Java project with Maven
                    sh '''
                    cd $WORKSPACE/spring-petclinic
                    ./gradlew build copyJar -x test
                    '''
                }
            }
        }

        stage('Build Golden Image with Packer') {
            steps {
                script {
                    // Run Packer to create a golden image
                    sh '''
                    cd $WORKSPACE/packer
                    packer build
                    cd $WORKSPACE
                    '''
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                script {
                    sh '''
                    // Initialize Terraform
                    cd $WORKSPACE/terraform
                    terraform init

                    // Apply Terraform changes
                    terraform apply -auto-approve
                    '''
                }
            }
        }
    }

    post {
        always {
            // Cleanup (optional)
            script {
                // Cleanup resources or artifacts if needed
                sh '''
                cd $WORKSPACE
                rm -rf packer/*.jar
                '''
            }
        }
    }
}
