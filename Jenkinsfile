pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr:'3', artifactNumToKeepStr:'3'))
    }
    tools {
        maven 'mvn_3.9.16'
    }
    stages {
        stage("Code compilation") {
            steps {
                echo "Code compilation started"
                sh 'mvn clean compile'
                echo "Code compilation completed!!!"
            }
        }
        stage("Unit testing") {
            steps {
                echo "Unit testing started"
                sh 'mvn test'
                echo "Unit testing completed!!!"
            }
        }
        stage('SonarQube Analysis') {
//             environment {
//                 SONAR_TOKEN = credentials('sonar-token-id') // Jenkins credential ID
//             }
            steps {
                withSonarQubeEnv('SonarQubeServer') {
                    sh '''mvn sonar:sonar \
                          -Dsonar.projectKey=bookmytickets
                    '''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage("Code package") {
            steps {
                echo "Code packaging started"
                sh 'mvn package'
                sh 'cp target/*.jar target/bookmytickets-1.1.${BUILD_NUMBER}.jar'
                echo "Code packaging completed!!!"
            }
        }
        stage("Build docker image") {
            steps {
                echo "Building Docker image"
                sh 'docker build -t bookmytickets -t patilld94/bookmytickets:1.1.${BUILD_NUMBER} .'
                echo "Docker image built!!!"
            }
        }
        stage("Push docker image to Docker hub") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub_cred',
                                                     usernameVariable: 'DOCKER_USER',
                                                     passwordVariable: 'DOCKER_PASS')]) {
                        sh 'docker login docker.io -u ${DOCKER_USER} -p ${DOCKER_PASS}'
                        echo 'Pushing Docker Image to Docker Hub...'
                        sh 'docker push patilld94/bookmytickets:1.1.${BUILD_NUMBER}'
                        echo 'Docker Image Pushed to Docker Hub Successfully!'
                    }
                }
            }
        }
        stage("Deploy docker image to ECR") {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                      credentialsId: 'ecr-credentials']]) {
                        echo 'Pushing docker image to ECR...'
                        sh 'docker tag bookmytickets:latest 554422869155.dkr.ecr.ap-south-1.amazonaws.com/patilld94/bookmytickets:1.1.${BUILD_NUMBER}'
                        sh 'aws ecr get-login-password --region ap-south-1 \
                            | docker login --username AWS --password-stdin 554422869155.dkr.ecr.ap-south-1.amazonaws.com'
                        sh 'docker push 554422869155.dkr.ecr.ap-south-1.amazonaws.com/patilld94/bookmytickets:1.1.${BUILD_NUMBER}'
                        echo 'Docker image pushed to ECR successfully!'
                    }
                }
            }
        }
//         stage("Deploy docker image to Nexus") {
//             steps {
//                 script {
//                     withCredentials([usernamePassword(credentialsId: 'nexus-cred',
//                                                      usernameVariable: 'USERNAME',
//                                                      passwordVariable: 'PASSWORD')]) {
//                         echo 'Pushing docker image to Nexus...'
//                         sh 'docker tag bookmytickets:latest 65.0.168.23:8085/bookmytickets/bookmytickets:1.1.${BUILD_NUMBER}'
//                         sh 'docker login 65.0.168.23:8085/ -u ${USERNAME} -p ${PASSWORD}'
//                         sh 'docker push 65.0.168.23:8085/bookmytickets/bookmytickets:1.1.${BUILD_NUMBER}'
//                         echo 'Docker image pushed to Nexus successfully!'
//                     }
//                 }
//             }
//         }
        stage("Remove docker images from local machine") {
            steps {
                sh 'docker system prune -af'
            }
        }
    }
}