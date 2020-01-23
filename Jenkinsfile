pipeline {
   agent any

   stages {
      stage('Build') {
         steps {
            sh "docker-compose build"
         }
      }
      stage('Test') {
         environment {
                ERROR_FILE = 'web/failed.err'
            }
         steps {
            sh "docker-compose up --abort-on-container-exit"
            sh "if [ -f $ERROR_FILE ]; then exit 1; fi"
         }
      }
   }
   post {
      failure {
         telegramSend "Job \"${JOB_NAME}\": Build №${BUILD_NUMBER} Failed. \
         Commit author: \"${GIT_COMMITTER_NAME} ${GIT_COMMITTER_EMAIL}\" \
         More info: ${BUILD_URL}"
      }
   }
}
