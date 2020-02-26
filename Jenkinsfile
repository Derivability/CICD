pipeline {
   
   agent none
   
   stages {
      stage('Build') {
         agent { label 'Build_slave' }
         steps {       
            sh "#!/bin/bash \n"+
            "source /home/ubuntu/Jenkins/env/environment.env && docker-compose build"
         }
      }
      stage('Test') {
         agent { label 'Build_slave' }
         environment {
                ERROR_FILE = 'web/failed.err'
            }
         steps {
            sh "ln web/startup/test.sh web/launch-django"
            sh "#!/bin/bash \n"+
            "source /home/ubuntu/Jenkins/env/environment.env && docker-compose up --abort-on-container-exit"
            sh "if [ -f $ERROR_FILE ]; then exit 1; fi"
         }
      }
      stage('Staging') {
        agent { label 'Stage_slave' }
        steps {
            sh "ln web/startup/runserver.sh web/launch-django"
            sh "docker-compose stop"
            sh "#!/bin/bash \n"+
            "source /home/ubuntu/Jenkins/env/environment.env && docker-compose up -d"
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
