pipeline {
   agent any

   stages {
      stage('Build') {
         steps {
            sh "POSTGRES_DATA=/var/lib/postgresql/data docker-compose build"
         }
      }
      stage('Test') {
         environment {
                ERROR_FILE = 'web/failed.err'
            }
         steps {
            sh "TEST=true POSTGRES_DATA=/var/lib/postgresql/data docker-compose up --build --abort-on-container-exit"
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
