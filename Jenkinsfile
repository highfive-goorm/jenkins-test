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

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = env.BUILD_NUMBER
                    // BuildKit 활성화 + progress=plain 하려면 prefix 추가 가능
                    sh """
                        export DOCKER_BUILDKIT=1
                        docker build \
                          --progress=plain \
                          -t ${DOCKER_IMAGE_NAME}:${imageTag} \
                          -f ${DOCKERFILE_PATH} .
                    """
                }
            }
        }

        stage('Verify Docker Image Content') {
            steps {
                script {
                    def imageTag = env.BUILD_NUMBER
                    // 컨테이너를 잠시 띄워서 /usr/share/nginx/html/index.html 존재 여부 확인
                    sh """
                        echo "===== Verify Index.html in Image ====="
                        docker run --rm ${DOCKER_IMAGE_NAME}:${imageTag} \
                          cat /usr/share/nginx/html/index.html | head -n 1
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    def imageTag = env.BUILD_NUMBER
                    // Jenkins에 저장된 DockerHub Token ID: 'highfive_dockerhub_token'
                    docker.withRegistry('https://index.docker.io/v1/', 'highfive_dockerhub_token') {
                        docker.image("${DOCKER_IMAGE_NAME}:${imageTag}").push()
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${imageTag} ${DOCKER_IMAGE_NAME}:latest"
                        docker.image("${DOCKER_IMAGE_NAME}:latest").push()
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
            echo '🎉 Frontend CI/CD Pipeline Complete. 🎉'
        }
    }
}
