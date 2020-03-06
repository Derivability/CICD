pipeline {
   
   agent none
   
   stages {
      stage('Build') {
         agent { label 'Build_slave' }
         steps {
            withCredentials([[$class: 'FileBinding', credentialsId: 'django_db_init', variable: 'SQL_FILE']]) {
                sh "cp ${SQL_FILE} db/init.sql"
            }
            withCredentials([[$class: 'FileBinding', credentialsId: 'django_db', variable: 'ENV_FILE']]) {
                sh "#!/bin/bash \n"+
                '''
                tags=$(docker images | grep opsworks | awk '{print $2}')
                for tag in $tags
                do
                    if [ $tag != "latest" ] && [ "$tag" -lt "$((${BUILD_NUMBER}-2))" ]
                    then
                        docker rmi $(docker images | grep opsworks | grep $tag | awk '{print $1}'):$tag || true
                    fi
                done
                source ${ENV_FILE} && docker-compose build
                '''
            }
         }
      }
      stage('Test') {
         agent { label 'Build_slave' }
         environment {
                ERROR_FILE = 'web/failed.err'
            }
         steps {
            sh "ln web/startup/test.sh web/launch-django"
            withCredentials([[$class: 'FileBinding', credentialsId: 'django_db_init', variable: 'SQL_FILE']]) {
                sh "cp ${SQL_FILE} db/init.sql"
            }
            withCredentials([[$class: 'FileBinding', credentialsId: 'django_db', variable: 'ENV_FILE']]) {
                sh "#!/bin/bash \n"+
                "source ${ENV_FILE} && docker-compose up --abort-on-container-exit"
                sh "if [ -f $ERROR_FILE ]; then exit 1; fi"
            }
         }
      }
      stage('Staging') {
        agent { label 'Stage_slave' }
        steps {
            sh "ln web/startup/runserver.sh web/launch-django"
            withCredentials([[$class: 'FileBinding', credentialsId: 'django_db_init', variable: 'SQL_FILE']]) {
                sh "cp ${SQL_FILE} db/init.sql"
            }
            withCredentials([[$class: 'FileBinding', credentialsId: 'django_db', variable: 'ENV_FILE']]) {
                sh "#!/bin/bash \n"+
                '''
                tags=$(docker images | grep opsworks | awk '{print $2}')
                for tag in $tags
                do
                    if [ $tag != "latest" ] && [ "$tag" -lt "$((${BUILD_NUMBER}-2))" ]
                    then
                        docker rmi $(docker images | grep opsworks | grep $tag | awk '{print $1}'):$tag || true
                    fi
                done
                source ${ENV_FILE} && docker-compose build
                '''
            }
            sh "docker-compose stop"
            withCredentials([usernamePassword(credentialsId: 'django_web_creds', passwordVariable: 'DJANGO_ADMIN_PASS', usernameVariable: 'DJANGO_ADMIN'), file(credentialsId: 'django_db', variable: 'ENV_FILE')]) {
                sh "#!/bin/bash \n"+
                "source ${ENV_FILE} && docker-compose up -d"
            }
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
