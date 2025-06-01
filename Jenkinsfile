pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = 'seowooo3117/highfive-test'
        DOCKERFILE_PATH = 'Dockerfile'
        AWS_REGION = 'ap-northeast-2'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-token', url: 'https://github.com/highfive-goorm/jenkins-test.git'
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm install'
                sh 'npm run build'
                sh 'ls -la build'  // 결과물 확인용 (선택)
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = env.BUILD_NUMBER
                    docker.build("${DOCKER_IMAGE_NAME}:${imageTag}", "--file ${DOCKERFILE_PATH} .")
                }
            }
        }

        stage('Verify Docker Image Content') {
            steps {
                script {
                    def imageTag = env.BUILD_NUMBER
                    sh "docker run --rm ${DOCKER_IMAGE_NAME}:${imageTag} ls -la /usr/share/nginx/html"
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    def imageTag = env.BUILD_NUMBER
                    docker.withRegistry('https://index.docker.io/v1/', 'highfive_dockerhub_token') {
                        docker.image("${DOCKER_IMAGE_NAME}:${imageTag}").push()
                    }
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    script {
                        def imageTag = env.BUILD_NUMBER

                        sh """
                            export AWS_DEFAULT_REGION=${AWS_REGION}
                            export DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME}
                            export BUILD_NUMBER=${imageTag}

                            envsubst < ecs-task-template.json > ecs-task.json

                            NEW_TASK_DEF_ARN=\$(aws ecs register-task-definition \
                              --cli-input-json file://ecs-task.json \
                              --query 'taskDefinition.taskDefinitionArn' --output text)

                            aws ecs update-service \
                              --cluster highfive-cluster \
                              --service highfive-frontend-service \
                              --task-definition \$NEW_TASK_DEF_ARN \
                              --force-new-deployment
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Frontend CI/CD Pipeline Complete.'
        }
    }
}
