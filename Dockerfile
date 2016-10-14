FROM java:8-jre-alpine

ENV RDECK_BASE=/opt/rundeck RDECK_VERSION=2.6.9 RDECK_SHA=8879caf623465902cb039921ce157d77e8e0592f
ENV RDECK_EC2_PLUGIN=1.5.2 RDECK_ANSIBLE_PLUGIN=2.0.0 RDECK_SLACK_PLUGIN=v0.6.dev

RUN apk add --no-cache py-pip python-dev musl-dev gcc libffi-dev openssl-dev git openssh-client ca-certificates wget \
  && update-ca-certificates \
  && mkdir -p ${RDECK_BASE}/libext \
  && wget -O ${RDECK_BASE}/rundeck.jar http://dl.bintray.com/rundeck/rundeck-maven/rundeck-launcher-${RDECK_VERSION}.jar \
  && echo "${RDECK_SHA}  ${RDECK_BASE}/rundeck.jar" | sha1sum -c \
  && wget -P ${RDECK_BASE}/libext https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/releases/download/v${RDECK_EC2_PLUGIN}/rundeck-ec2-nodes-plugin-${RDECK_EC2_PLUGIN}.jar \
  && wget -P ${RDECK_BASE}/libext https://github.com/Batix/rundeck-ansible-plugin/releases/download/${RDECK_ANSIBLE_PLUGIN}/ansible-plugin-${RDECK_ANSIBLE_PLUGIN}.jar \
  && wget -P ${RDECK_BASE}/libext https://github.com/higanworks/rundeck-slack-incoming-webhook-plugin/releases/download/v0.6.dev/rundeck-slack-incoming-webhook-plugin-0.6.jar \

  # Without this kostylj Rundeck fails to start if db encryption is enabled.
  && unzip -p ${RDECK_BASE}/rundeck.jar pkgs/webapp/WEB-INF/rundeck/plugins/rundeck-jasypt-encryption-plugin-${RDECK_VERSION}.jar > ${RDECK_BASE}/libext/rundeck-jasypt-encryption-plugin-${RDECK_VERSION}.jar \

  # Install Ansible
  && pip install boto paramiko PyYAML Jinja2 httplib2 six ansible awscli

EXPOSE 4440

VOLUME [ "/etc/ansible", \
         "${RDECK_BASE}/etc", \
         "${RDECK_BASE}/var/logs", \
         "${RDECK_BASE}/server/logs", \
         "${RDECK_BASE}/server/config" ]

ENTRYPOINT [ "java","-jar","/opt/rundeck/rundeck.jar" ]
