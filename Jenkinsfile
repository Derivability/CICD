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
                TEST= 'true'
            }
         steps {
            sh "docker-compose up --abort-on-container-exit"
            sh "if [ -f $ERROR_FILE ]; then exit 1; fi"
         }
      }
   }
   post {
      success {
        telegramSend "Job \"${JOB_NAME}\": Build №${BUILD_NUMBER} Succeed. More info: ${BUILD_URL}"
      }
      failure {
         telegramSend "Job \"${JOB_NAME}\": Build №${BUILD_NUMBER} Failed. More info: ${BUILD_URL}"
      }
   }
}
