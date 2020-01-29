pipeline {
   
   agent none
   
   stages {
      stage('Build') {
         agent { label 'Wraith_slave' }
         steps {
            sh "docker-compose build"
         }
      }
      stage('Test') {
         agent { label 'Wraith_slave' }
         environment {
                ERROR_FILE = 'web/failed.err'
            }
         steps {
            sh "ln web/startup/test.sh web/launch-django"
            sh "docker-compose up --abort-on-container-exit"
            sh "if [ -f $ERROR_FILE ]; then exit 1; fi"
         }
      }
      stage('Deploy') {
        agent { label 'Deploy_slave' }
        steps {
            sh "ln web/startup/runserver.sh web/launch-django"
            sh "docker-compose up -d"
        }
      }
   }

   post {
      success {
        node('master') {
           telegramSend "Job \"${JOB_NAME}\": Build №${BUILD_NUMBER} Succeed. More info: ${BUILD_URL}"
         }
      }
      failure {
        node('master') {
           telegramSend "Job \"${JOB_NAME}\": Build №${BUILD_NUMBER} Failed. More info: ${BUILD_URL}"
         }
      }
   }
}
