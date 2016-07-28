FROM java:8-jre-alpine

ENV RDECK_BASE=/opt/rundeck RDECK_VERSION=2.6.8 RDECK_SHA=5a5976ac3b76e64ac5296e1e62576f762869b9be

RUN mkdir -p ${RDECK_BASE}/libext \
  && wget -O ${RDECK_BASE}/rundeck.jar http://dl.bintray.com/rundeck/rundeck-maven/rundeck-launcher-${RDECK_VERSION}.jar \
  && echo "${RDECK_SHA}  ${RDECK_BASE}/rundeck.jar" | sha1sum -c \
  && wget -P ${RDECK_BASE}/libext https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/releases/download/v1.5.2/rundeck-ec2-nodes-plugin-1.5.2.jar \
  && wget -P ${RDECK_BASE}/libext https://github.com/Batix/rundeck-ansible-plugin/releases/download/1.3.2/ansible-plugin-1.3.2.jar \
  && wget -P ${RDECK_BASE}/libext https://github.com/higanworks/rundeck-slack-incoming-webhook-plugin/releases/download/v0.6.dev/rundeck-slack-incoming-webhook-plugin-0.6.jar \

  # Without this kostylj Rundeck fails to start if db encryption is enabled.
  && unzip -p ${RDECK_BASE}/rundeck.jar pkgs/webapp/WEB-INF/rundeck/plugins/rundeck-jasypt-encryption-plugin-${RDECK_VERSION}.jar > ${RDECK_BASE}/libext/rundeck-jasypt-encryption-plugin-${RDECK_VERSION}.jar \

  # Install Ansible
  && apk add --no-cache py-pip python-dev musl-dev gcc libffi-dev openssl-dev git openssh-client \
  && pip install boto paramiko PyYAML Jinja2 httplib2 six ansible awscli

EXPOSE 4440

VOLUME ["/etc/ansible", \
        "${RDECK_BASE}/etc", \
	    "${RDECK_BASE}/var/logs", \
	    "${RDECK_BASE}/server/logs", \
        "${RDECK_BASE}/server/config"]

ENTRYPOINT ["java","-jar","/opt/rundeck/rundeck.jar"]
