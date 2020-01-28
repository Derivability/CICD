pipeline {
   agent none

   stages {
      stage('Build') {
         agent { label 'Wraith_slave'}
         steps {
            sh "docker-compose build --force"
         }
      }
      stage('Test') {
         agent { label 'Wraith_slave'}
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
