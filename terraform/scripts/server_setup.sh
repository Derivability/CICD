#!/bin/bash

set -x

function wait_for_jenkins()
{
	while (( 1 )); do
		echo "waiting for Jenkins to launch on port [8080] ..."
		
		nc -zv 127.0.0.1 8080
		if (( $? == 0 )); then
			break
		fi

		sleep 10
	done

	echo "Jenkins launched"
}

function setup_ansible()
{
	cd /etc/ansible
	echo "${PEM}" > /var/lib/jenkins/edu.pem
	chmod 600 /var/lib/jenkins/edu.pem
	cat > hosts <<EOF
[build_servers]
linux_1 ansible_host=ip
[stage_servers]
linux_2 ansible_host=ip
[stage_build:children]
build_servers
stage_servers

[stage_build:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/edu.pem  
EOF
	cat > ansible.cfg <<EOF
[defaults]
host_key_checking = false
EOF

	chown jenkins ./
}

function updating_jenkins_master_password ()
{
	cat > /tmp/jenkinsHash.py <<EOF
import bcrypt
import sys
if not sys.argv[1]:
	sys.exit(10)
plaintext_pwd=sys.argv[1]
encrypted_pwd=bcrypt.hashpw(sys.argv[1], bcrypt.gensalt(rounds=10, prefix=b"2a"))
isCorrect=bcrypt.checkpw(plaintext_pwd, encrypted_pwd)
if not isCorrect:
	sys.exit(20);
print "{}".format(encrypted_pwd)
EOF

	chmod +x /tmp/jenkinsHash.py

	# Wait till /var/lib/jenkins/users/admin* folder gets created
	while (( 1 )); do
		echo "Waiting for Jenkins to generate admin user's directory ..."

		if [ -d /var/lib/jenkins/users/admin* ]; then
			break
		fi

		sleep 10
	done

	cd /var/lib/jenkins/users/admin*
	pwd
	while (( 1 )); do
		echo "Waiting for Jenkins to generate admin user's config file ..."

		if [[ -f "./config.xml" ]]; then
			break
		fi

		sleep 10
	done

	echo "Admin config file created"

	admin_password=$(python /tmp/jenkinsHash.py ${JENKINS_PASS} 2>&1)

	xmlstarlet -q ed --inplace -u "/user/properties/hudson.security.HudsonPrivateSecurityRealm_-Details/passwordHash" -v '#jbcrypt:'"$admin_password" config.xml

	# Restart
	systemctl restart jenkins
	sleep 10
}

function import_data ()
{
	if [ "${DATA}" != "0" ]
	then
		while (( 1 )); do
			echo "Waiting for Terraform to deliver data file ..."

			if [[ -f "/tmp/data.tar.gz" ]]; then
				break
			fi

			sleep 10
		done
		tar -xvzf /tmp/data.tar.gz -C /var/lib/jenkins/
		chown -R jenkins:jenkins /var/lib/jenkins
	
		systemctl restart jenkins
	fi
}

function configure_jenkins_server ()
{
	# Jenkins cli
	echo "installing the Jenkins cli ..."
	cp /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar /var/lib/jenkins/jenkins-cli.jar

	PASSWORD="${JENKINS_PASS}"
	sleep 10

	jenkins_dir="/var/lib/jenkins"
	plugins_dir="$jenkins_dir/plugins"

	mkdir $jenkins_dir/ansible
	setup_ansible

	chown jenkins:jenkins -R $jenkins_dir/ansible

	cd $jenkins_dir

	cd $plugins_dir || { echo "unable to chdir to [$plugins_dir]"; exit 1; }

	# List of plugins that are needed to be installed 
	plugin_list="workflow-cps pipeline-stage-tags-metadata pipeline-model-declarative-agent subversion jdk-tool pipeline-model-api ws-cleanup pam-auth timestamper workflow-api docker-commons script-security workflow-cps-global-lib token-macro command-launcher matrix-auth git jackson2-api gradle docker-workflow momentjs workflow-basic-steps variant workflow-aggregator structs github-branch-source durable-task scm-api pipeline-model-definition telegram-notifications handlebars pipeline-graph-analysis ssh-credentials pipeline-stage-view display-url-api apache-httpcomponents-client-4-api aws-java-sdk workflow-scm-step build-timeout jsch pipeline-milestone-step antisamy-markup-formatter cloudbees-folder ace-editor email-ext pipeline-rest-api workflow-step-api node-iterator-api mapdb-api matrix-project resource-disposer plain-credentials pipeline-model-extensions pipeline-stage-step workflow-multibranch credentials pipeline-input-step ec2 workflow-support ant aws-credentials pipeline-github-lib authentication-tokens junit github pipeline-build-step trilead-api ldap bouncycastle-api github-api git-client branch-api workflow-job workflow-durable-task-step mailer credentials-binding jquery-detached git-server ssh-slaves lockable-resources"

	ret=1
	while [ $ret = 1 ]
	do
		sleep 10
		ret=0
		for plugin in $plugin_list; do
			echo "installing plugin [$plugin] ..."
			java -jar $jenkins_dir/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth admin:$PASSWORD install-plugin $plugin || ret=1
			if [ $ret == 1 ]; then
				break
			fi
		done
	done

	# Restart jenkins after installing plugins
	java -jar $jenkins_dir/jenkins-cli.jar -s http://127.0.0.1:8080 -auth admin:$PASSWORD safe-restart
}

function install_packages ()
{
	wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
	echo "deb https://pkg.jenkins.io/debian-stable binary/" >> /etc/apt/sources.list
	apt-get update
	apt-get install -y jenkins openjdk-8-jre-headless python python-pip xmlstarlet ansible unzip
	pip install bcrypt

	echo "@reboot sleep 37 ; wget --no-check-certificate -O - https://freedns.afraid.org/dynamic/update.php?${DNS_TOKEN} >> /tmp/freedns_jenkins-aws_strangled_net.log 2>&1" >> /tmp/newcron
	crontab /tmp/newcron
	rm /tmp/newcron

	systemctl enable jenkins
	systemctl restart jenkins
	sleep 10
}

function sendTgNotification ()
{
	curl -s -X POST https://api.telegram.org/bot${TG_TOKEN}/sendMessage -d chat_id=${TG_CHAT_ID} -d text="$1"
}

### script starts here ###

install_packages

wait_for_jenkins

updating_jenkins_master_password

sendTgNotification "Jenkins password setup finished"

wait_for_jenkins

configure_jenkins_server

sendTgNotification "Jenkins configuration finished"

wait_for_jenkins

import_data

sendTgNotification "Jenkins data import finished"

wait_for_jenkins

sendTgNotification "Jenkins server setup finished"

echo "Done"
exit 0 
