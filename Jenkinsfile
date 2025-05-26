pipeline {
    agent any

    triggers {
        githubPush()  // GitHub Webhook을 통해 push 이벤트 감지
    }

    stages {
        stage('🔍 준비 단계') {
            steps {
                echo '워크스페이스 클린업 및 환경 준비 중...'
                sh 'rm -rf * || true'
            }
        }

        stage('🛠️ 빌드 단계') {
            steps {
                echo '빌드 스크립트 실행 중...'
                sh 'echo "Build 완료 (의미 없음)"'
            }
        }

        stage('✅ 테스트 단계') {
            steps {
                echo '테스트 코드 실행 중...'
                sh '''
                echo "테스트 1 통과"
                echo "테스트 2 통과"
                '''
            }
        }

        stage('🚀 배포 단계') {
            steps {
                echo '임시 배포 로직 실행 중...'
                sh 'echo "배포 완료 (모의)"'
            }
        }
    }

    post {
        success {
            echo '🎉 파이프라인 성공!!'
        }
        failure {
            echo '❌ 파이프라인 실패!!'
        }
    }
}
